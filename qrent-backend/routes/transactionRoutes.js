const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.post('/borrow', verifyToken, transactionController.borrowEquipment);
router.post('/return', verifyToken, transactionController.returnEquipment);
router.get('/my-active', verifyToken, transactionController.getMyActiveLoans);
router.get('/my-history', verifyToken, transactionController.getMyHistory);

module.exports = router;
