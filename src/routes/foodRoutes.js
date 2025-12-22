const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');
const upload = require('../middleware/uploadMiddleware');
// const authMiddleware = require('../middleware/authMiddleware'); // Şimdilik kapalı, test için

// Analyze Route
// Dosya upload için 'image' key'ini kullanıyoruz + Hata Yakalayıcı
router.post('/analyze', (req, res, next) => {
    upload.single('image')(req, res, (err) => {
        if (err) {
            console.error("MULTER HATASI:", err.message);
            // Multer hatasını frontend'e 400 olarak dön
            return res.status(400).json({
                success: false,
                message: "Dosya yükleme hatası: " + err.message
            });
        }
        next();
    });
}, foodController.analyzeFood);

// Confirm Route
router.post('/confirm', foodController.confirmFood);

module.exports = router;
