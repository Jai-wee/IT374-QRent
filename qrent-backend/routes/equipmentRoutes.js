const express = require('express');
const router = express.Router();
const equipmentController = require('../controllers/equipmentController');
const { verifyToken, requireAdmin } = require('../middlewares/authMiddleware');

router.get('/', equipmentController.getAllEquipments);
router.get('/:id', equipmentController.getEquipmentById);
router.post('/', verifyToken, requireAdmin, equipmentController.createEquipment);

module.exports = router;
