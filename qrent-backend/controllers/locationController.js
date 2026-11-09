const db = require('../config/db');
const { calculateHaversineDistance } = require('./transactionController');

// GET /api/locations
const getAllLocations = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM locations ORDER BY location_id ASC');
    res.status(200).json({
      success: true,
      count: result.rows.length,
      data: result.rows,
    });
  } catch (err) {
    console.error('Error getting locations:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงข้อมูลสถานที่',
      error: err.message,
    });
  }
};

// GET /api/locations/:id
const getLocationById = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query('SELECT * FROM locations WHERE location_id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'ไม่พบสถานที่นี้',
      });
    }

    res.status(200).json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error('Error getting location by id:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการดึงข้อมูลสถานที่',
      error: err.message,
    });
  }
};

// POST /api/locations/verify
// Body: { latitude, longitude, location_id }
const verifyUserLocation = async (req, res) => {
  try {
    const { latitude, longitude, location_id = 1 } = req.body;

    if (latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        message: 'กรุณาระบุพิกัด latitude และ longitude',
      });
    }

    const locResult = await db.query('SELECT * FROM locations WHERE location_id = $1', [
      location_id,
    ]);

    if (locResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'ไม่พบสถานที่ที่ระบุ',
      });
    }

    const lab = locResult.rows[0];
    const distanceMeters = calculateHaversineDistance(
      parseFloat(latitude),
      parseFloat(longitude),
      parseFloat(lab.latitude),
      parseFloat(lab.longitude)
    );

    const isInside = distanceMeters <= lab.radius_meters;

    res.status(200).json({
      success: true,
      is_inside: isInside,
      distance_meters: Math.round(distanceMeters),
      allowed_radius: lab.radius_meters,
      location: {
        id: lab.location_id,
        name: lab.name,
        latitude: lab.latitude,
        longitude: lab.longitude,
      },
      message: isInside
        ? `คุณอยู่ในพื้นที่ให้บริการ (${Math.round(distanceMeters)} ม.) สามารถทำรายการได้`
        : `คุณอยู่นอกพื้นที่ (${Math.round(distanceMeters)} ม.) กรุณาเข้ามาในรัศมี ${lab.radius_meters} ม. ของ ${lab.name}`,
    });
  } catch (err) {
    console.error('Error verifying location:', err);
    res.status(500).json({
      success: false,
      message: 'เกิดข้อผิดพลาดในการตรวจสอบพิกัด',
      error: err.message,
    });
  }
};

module.exports = {
  getAllLocations,
  getLocationById,
  verifyUserLocation,
};
