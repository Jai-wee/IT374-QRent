const db = require('../config/db');

// GET /api/equipments
const getAllEquipments = async (req, res) => {
  try {
    const { status, search, location_id } = req.query;

    let queryText = `
      SELECT e.equipment_id, e.name, e.description, e.image_url, e.status, e.location_id,
             l.name AS location_name, l.latitude, l.longitude, l.radius_meters
      FROM equipments e
      LEFT JOIN locations l ON e.location_id = l.location_id
      WHERE 1=1
    `;
    const params = [];

    if (status) {
      params.push(status);
      queryText += ` AND e.status = $${params.length}`;
    }

    if (location_id) {
      params.push(location_id);
      queryText += ` AND e.location_id = $${params.length}`;
    }

    if (search) {
      params.push(`%${search}%`);
      queryText += ` AND (e.name ILIKE $${params.length} OR e.equipment_id ILIKE $${params.length} OR e.description ILIKE $${params.length})`;
    }

    queryText += ' ORDER BY e.equipment_id ASC';

    const result = await db.query(queryText, params);

    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows,
    });
  } catch (err) {
    console.error('Error getting equipments:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงรายการอุปกรณ์',
      error: err.message,
    });
  }
};

// GET /api/equipments/:id (Used by QR Code Scanner)
const getEquipmentById = async (req, res) => {
  try {
    const { id } = req.params;

    const queryText = `
      SELECT e.equipment_id, e.name, e.description, e.image_url, e.status, e.location_id,
             l.name AS location_name, l.latitude, l.longitude, l.radius_meters,
             t.transaction_id, t.student_id AS borrower_id, t.borrow_date, t.due_date,
             u.first_name AS borrower_first_name, u.last_name AS borrower_last_name
      FROM equipments e
      LEFT JOIN locations l ON e.location_id = l.location_id
      LEFT JOIN transactions t ON e.equipment_id = t.equipment_id AND t.status = 'active'
      LEFT JOIN users u ON t.student_id = u.student_id
      WHERE e.equipment_id = $1
    `;

    const result = await db.query(queryText, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: `ไม่พบอุปกรณ์รหัส ${id}`,
      });
    }

    res.status(200).json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error('Error getting equipment by id:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงข้อมูลอุปกรณ์',
      error: err.message,
    });
  }
};

// POST /api/equipments (Admin only)
const createEquipment = async (req, res) => {
  try {
    const { equipment_id, name, description, image_url, location_id } = req.body;

    if (!equipment_id || !name) {
      return res.status(400).json({
        success: false,
        message: 'equipment_id และ name จำเป็นต้องระบุ',
      });
    }

    const result = await db.query(
      `INSERT INTO equipments (equipment_id, name, description, image_url, status, location_id)
       VALUES ($1, $2, $3, $4, 'available', $5)
       RETURNING *`,
      [equipment_id, name, description, image_url, location_id]
    );

    res.status(201).json({
      success: true,
      message: 'เพิ่มอุปกรณ์ใหม่เรียบร้อย',
      data: result.rows[0],
    });
  } catch (err) {
    console.error('Error creating equipment:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการเพิ่มอุปกรณ์',
      error: err.message,
    });
  }
};

module.exports = {
  getAllEquipments,
  getEquipmentById,
  createEquipment,
};
