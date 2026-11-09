const db = require('../config/db');

// POST /api/reports
const createReport = async (req, res) => {
  try {
    const student_id = req.user.student_id;
    const { equipment_id, category, note, image_url } = req.body;

    if (!equipment_id || !category) {
      return res.status(400).json({
        success: false,
        message: 'กรุณาระบุรหัสอุปกรณ์และหมวดหมู่ของปัญหา',
      });
    }

    const result = await db.query(
      `INSERT INTO reports (student_id, equipment_id, category, note, image_url, status)
       VALUES ($1, $2, $3, $4, $5, 'pending')
       RETURNING *`,
      [student_id, equipment_id, category, note || '', image_url || '']
    );

    res.status(201).json({
      success: true,
      message: 'ส่งรายงานปัญหาเรียบร้อยแล้ว เจ้าหน้าที่จะดำเนินการตรวจสอบ',
      data: result.rows[0],
    });
  } catch (err) {
    console.error('Error creating report:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการส่งรายงานปัญหา',
      error: err.message,
    });
  }
};

// GET /api/reports
const getAllReports = async (req, res) => {
  try {
    const { student_id, role } = req.user;
    const { status } = req.query;

    let queryText = `
      SELECT r.report_id, r.student_id, r.equipment_id, r.category, r.note, r.image_url, r.report_date, r.status,
             e.name AS equipment_name, e.image_url AS equipment_thumb,
             u.first_name, u.last_name
      FROM reports r
      JOIN equipments e ON r.equipment_id = e.equipment_id
      JOIN users u ON r.student_id = u.student_id
      WHERE 1=1
    `;
    const params = [];

    // If not admin, only see own reports
    if (role !== 'admin') {
      params.push(student_id);
      queryText += ` AND r.student_id = $${params.length}`;
    }

    if (status) {
      params.push(status);
      queryText += ` AND r.status = $${params.length}`;
    }

    queryText += ' ORDER BY r.report_date DESC';

    const result = await db.query(queryText, params);

    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows,
    });
  } catch (err) {
    console.error('Error getting reports:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงรายงานปัญหา',
      error: err.message,
    });
  }
};

// PUT /api/reports/:id/resolve (Admin only)
const resolveReport = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `UPDATE reports SET status = 'resolved' WHERE report_id = $1 RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'ไม่พบรายงานปัญหานี้',
      });
    }

    res.status(200).json({
      success: true,
      message: 'อัปเดตสถานะการแก้ไขปัญหาเรียบร้อย',
      data: result.rows[0],
    });
  } catch (err) {
    console.error('Error resolving report:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการอัปเดตสถานะ',
      error: err.message,
    });
  }
};

module.exports = {
  createReport,
  getAllReports,
  resolveReport,
};
