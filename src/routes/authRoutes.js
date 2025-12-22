const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Register Route
router.post('/register', authController.register);

// Login Route
router.post('/login', authController.login);
router.put('/update', authController.updateProfile); // Yeni endpoint

module.exports = router;
