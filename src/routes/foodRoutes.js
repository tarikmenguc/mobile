const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');
const upload = require('../middleware/uploadMiddleware');
// const authMiddleware = require('../middleware/authMiddleware'); // Şimdilik kapalı, test için

// Analyze Route
// Dosya upload için 'image' key'ini kullanıyoruz.
router.post('/analyze', upload.single('image'), foodController.analyzeFood);

// Confirm Route
router.post('/confirm', foodController.confirmFood);

module.exports = router;
