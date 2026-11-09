const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const { verifyToken, requireAdmin } = require('../middlewares/authMiddleware');

router.post('/', verifyToken, reportController.createReport);
router.get('/', verifyToken, reportController.getAllReports);
router.put('/:id/resolve', verifyToken, requireAdmin, reportController.resolveReport);

module.exports = router;
