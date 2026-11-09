const db = require('../config/db');

// Helper function to calculate distance between two GPS coordinates in meters
function calculateHaversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371e3; // Earth radius in meters
  const phi1 = (lat1 * Math.PI) / 180;
  const phi2 = (lat2 * Math.PI) / 180;
  const deltaPhi = ((lat2 - lat1) * Math.PI) / 180;
  const deltaLambda = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(deltaPhi / 2) * Math.sin(deltaPhi / 2) +
    Math.cos(phi1) * Math.cos(phi2) * Math.sin(deltaLambda / 2) * Math.sin(deltaLambda / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c; // Distance in meters
}

// POST /api/transactions/borrow
const borrowEquipment = async (req, res) => {
  const client = await db.pool.connect();
  try {
    const student_id = req.user.student_id;
    const { equipment_id, days = 7, latitude, longitude } = req.body;

    if (!equipment_id) {
      return res.status(400).json({
        success: false,
        message: 'กรุณาระบุรหัสอุปกรณ์ (equipment_id)',
      });
    }

    await client.query('BEGIN');

    // 1. Check equipment and location
    const eqResult = await client.query(
      `SELECT e.*, l.latitude AS lab_lat, l.longitude AS lab_lon, l.radius_meters, l.name AS lab_name
       FROM equipments e
       LEFT JOIN locations l ON e.location_id = l.location_id
       WHERE e.equipment_id = $1 FOR UPDATE`,
      [equipment_id]
    );

    if (eqResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'ไม่พบอุปกรณ์ที่ต้องการยืม',
      });
    }

    const equipment = eqResult.rows[0];

    if (equipment.status !== 'available') {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        message: `ไม่สามารถยืมได้ เนื่องจากอุปกรณ์อยู่ในสถานะ: ${equipment.status}`,
      });
    }

    // 2. Geofence Verification (If coordinates provided)
    if (latitude !== undefined && longitude !== undefined && equipment.lab_lat && equipment.lab_lon) {
      const distance = calculateHaversineDistance(
        parseFloat(latitude),
        parseFloat(longitude),
        parseFloat(equipment.lab_lat),
        parseFloat(equipment.lab_lon)
      );

      const maxRadius = equipment.radius_meters || 50;
      if (distance > maxRadius) {
        await client.query('ROLLBACK');
        return res.status(403).json({
          success: false,
          message: `คุณอยู่นอกพื้นที่บริการ (${Math.round(distance)} ม.) ต้องอยู่ในรัศมี ${maxRadius} ม. ของ ${equipment.lab_name}`,
          distance: Math.round(distance),
          allowed_radius: maxRadius,
        });
      }
    }

    // 3. Calculate due date
    const borrowDate = new Date();
    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + parseInt(days, 10));

    // 4. Create transaction record
    const txResult = await client.query(
      `INSERT INTO transactions (student_id, equipment_id, borrow_date, due_date, status)
       VALUES ($1, $2, $3, $4, 'active')
       RETURNING *`,
      [student_id, equipment_id, borrowDate, dueDate]
    );

    // 5. Update equipment status to 'borrowed'
    await client.query(
      `UPDATE equipments SET status = 'borrowed' WHERE equipment_id = $1`,
      [equipment_id]
    );

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: `ยืมอุปกรณ์ ${equipment.name} สำเร็จ`,
      transaction: txResult.rows[0],
      due_date: dueDate,
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error during borrowing:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการทำรายการยืม',
      error: err.message,
    });
  } finally {
    client.release();
  }
};

// POST /api/transactions/return
const returnEquipment = async (req, res) => {
  const client = await db.pool.connect();
  try {
    const student_id = req.user.student_id;
    const { equipment_id, latitude, longitude } = req.body;

    if (!equipment_id) {
      return res.status(400).json({
        success: false,
        message: 'กรุณาระบุรหัสอุปกรณ์ (equipment_id)',
      });
    }

    await client.query('BEGIN');

    // 1. Check active transaction
    const txResult = await client.query(
      `SELECT t.*, e.name AS equipment_name, l.latitude AS lab_lat, l.longitude AS lab_lon, l.radius_meters, l.name AS lab_name
       FROM transactions t
       JOIN equipments e ON t.equipment_id = e.equipment_id
       LEFT JOIN locations l ON e.location_id = l.location_id
       WHERE t.equipment_id = $1 AND t.student_id = $2 AND t.status = 'active'
       ORDER BY t.borrow_date DESC LIMIT 1
       FOR UPDATE`,
      [equipment_id, student_id]
    );

    if (txResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'ไม่พบรายการยืมที่ใช้งานอยู่สำหรับอุปกรณ์ชิ้นนี้ของคุณ',
      });
    }

    const tx = txResult.rows[0];

    // 2. Geofence Verification for return
    if (latitude !== undefined && longitude !== undefined && tx.lab_lat && tx.lab_lon) {
      const distance = calculateHaversineDistance(
        parseFloat(latitude),
        parseFloat(longitude),
        parseFloat(tx.lab_lat),
        parseFloat(tx.lab_lon)
      );

      const maxRadius = tx.radius_meters || 50;
      if (distance > maxRadius) {
        await client.query('ROLLBACK');
        return res.status(403).json({
          success: false,
          message: `การคืนต้องทำ ณ จุดบริการ (${Math.round(distance)} ม. นอกรัศมี ${maxRadius} ม. ของ ${tx.lab_name})`,
          distance: Math.round(distance),
          allowed_radius: maxRadius,
        });
      }
    }

    const returnDate = new Date();

    // 3. Update transaction to 'returned'
    await client.query(
      `UPDATE transactions SET status = 'returned', return_date = $1 WHERE transaction_id = $2`,
      [returnDate, tx.transaction_id]
    );

    // 4. Update equipment status to 'available'
    await client.query(
      `UPDATE equipments SET status = 'available' WHERE equipment_id = $1`,
      [equipment_id]
    );

    await client.query('COMMIT');

    res.status(200).json({
      success: true,
      message: `คืนอุปกรณ์ ${tx.equipment_name} เรียบร้อยแล้ว`,
      return_date: returnDate,
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error during return:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการทำรายการคืน',
      error: err.message,
    });
  } finally {
    client.release();
  }
};

// GET /api/transactions/my-active
const getMyActiveLoans = async (req, res) => {
  try {
    const student_id = req.user.student_id;

    const queryText = `
      SELECT t.transaction_id, t.borrow_date, t.due_date, t.status,
             e.equipment_id, e.name AS equipment_name, e.description, e.image_url,
             l.location_id, l.name AS location_name, l.latitude, l.longitude
      FROM transactions t
      JOIN equipments e ON t.equipment_id = e.equipment_id
      LEFT JOIN locations l ON e.location_id = l.location_id
      WHERE t.student_id = $1 AND t.status = 'active'
      ORDER BY t.due_date ASC
    `;

    const result = await db.query(queryText, [student_id]);

    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows,
    });
  } catch (err) {
    console.error('Error getting active loans:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงรายการอุปกรณ์ที่กำลังยืม',
      error: err.message,
    });
  }
};

// GET /api/transactions/my-history
const getMyHistory = async (req, res) => {
  try {
    const student_id = req.user.student_id;

    const queryText = `
      SELECT t.transaction_id, t.borrow_date, t.due_date, t.return_date, t.status,
             e.equipment_id, e.name AS equipment_name, e.description, e.image_url,
             l.name AS location_name
      FROM transactions t
      JOIN equipments e ON t.equipment_id = e.equipment_id
      LEFT JOIN locations l ON e.location_id = l.location_id
      WHERE t.student_id = $1 AND t.status != 'active'
      ORDER BY t.return_date DESC
    `;

    const result = await db.query(queryText, [student_id]);

    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows,
    });
  } catch (err) {
    console.error('Error getting loan history:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงประวัติการยืม-คืน',
      error: err.message,
    });
  }
};

module.exports = {
  borrowEquipment,
  returnEquipment,
  getMyActiveLoans,
  getMyHistory,
  calculateHaversineDistance,
};
