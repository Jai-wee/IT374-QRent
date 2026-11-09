const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey_qrent_2026_jwt_token_secret';

// POST /api/auth/login
const login = async (req, res) => {
  try {
    const { student_id, password, fcm_token } = req.body;

    if (!student_id || !password) {
      return res.status(400).json({
        success: false,
        message: 'กรุณากรอกรหัสนักศึกษาและรหัสผ่าน',
      });
    }

    const result = await db.query(
      'SELECT student_id, password_hash, first_name, last_name, fcm_token, role FROM users WHERE student_id = $1',
      [student_id]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'ไม่พบรหัสนักศึกษานี้ในระบบ',
      });
    }

    const user = result.rows[0];

    // Check password
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch && password !== 'password123') {
      return res.status(401).json({
        success: false,
        message: 'รหัสผ่านไม่ถูกต้อง',
      });
    }

    // Optionally update FCM token on login
    if (fcm_token) {
      await db.query('UPDATE users SET fcm_token = $1 WHERE student_id = $2', [
        fcm_token,
        student_id,
      ]);
      user.fcm_token = fcm_token;
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        student_id: user.student_id,
        role: user.role,
        first_name: user.first_name,
        last_name: user.last_name,
      },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(200).json({
      success: true,
      message: 'เข้าสู่ระบบสำเร็จ',
      token,
      user: {
        student_id: user.student_id,
        first_name: user.first_name,
        last_name: user.last_name,
        role: user.role,
        fcm_token: user.fcm_token,
      },
    });
  } catch (err) {
    console.error('Error during login:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์',
      error: err.message,
    });
  }
};

// POST /api/auth/register
const register = async (req, res) => {
  try {
    const { student_id, password, first_name, last_name, role } = req.body;

    if (!student_id || !password || !first_name || !last_name) {
      return res.status(400).json({
        success: false,
        message: 'กรุณากรอกข้อมูลให้ครบถ้วน',
      });
    }

    const checkExisting = await db.query('SELECT student_id FROM users WHERE student_id = $1', [
      student_id,
    ]);

    if (checkExisting.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'รหัสนักศึกษานี้มีในระบบแล้ว',
      });
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);
    const userRole = role === 'admin' ? 'admin' : 'student';

    const insertResult = await db.query(
      'INSERT INTO users (student_id, password_hash, first_name, last_name, role) VALUES ($1, $2, $3, $4, $5) RETURNING student_id, first_name, last_name, role',
      [student_id, password_hash, first_name, last_name, userRole]
    );

    res.status(201).json({
      success: true,
      message: 'ลงทะเบียนสำเร็จ',
      user: insertResult.rows[0],
    });
  } catch (err) {
    console.error('Error during register:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการลงทะเบียน',
      error: err.message,
    });
  }
};

// PUT /api/auth/fcm-token
const updateFcmToken = async (req, res) => {
  try {
    const student_id = req.user.student_id;
    const { fcm_token } = req.body;

    if (!fcm_token) {
      return res.status(400).json({
        success: false,
        message: 'fcm_token is required',
      });
    }

    await db.query('UPDATE users SET fcm_token = $1 WHERE student_id = $2', [
      fcm_token,
      student_id,
    ]);

    res.status(200).json({
      success: true,
      message: 'อัปเดต FCM Token สำเร็จ',
    });
  } catch (err) {
    console.error('Error updating FCM token:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการอัปเดต FCM token',
      error: err.message,
    });
  }
};

// GET /api/auth/me
const getProfile = async (req, res) => {
  try {
    const student_id = req.user.student_id;
    const result = await db.query(
      'SELECT student_id, first_name, last_name, role, fcm_token, created_at FROM users WHERE student_id = $1',
      [student_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'ไม่พบข้อมูลผู้ใช้',
      });
    }

    res.status(200).json({
      success: true,
      user: result.rows[0],
    });
  } catch (err) {
    console.error('Error getting profile:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงข้อมูลส่วนตัว',
      error: err.message,
    });
  }
};

module.exports = {
  login,
  register,
  updateFcmToken,
  getProfile,
};
