const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { verifyToken } = require('../middlewares/authMiddleware');

router.post('/login', authController.login);
router.post('/register', authController.register);
router.put('/fcm-token', verifyToken, authController.updateFcmToken);
router.get('/me', verifyToken, authController.getProfile);

module.exports = router;
