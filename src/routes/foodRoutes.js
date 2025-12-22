const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');
const upload = require('../middleware/uploadMiddleware');
// const authMiddleware = require('../middleware/authMiddleware'); // Şimdilik kapalı, test için

// Analyze Route
// Dosya upload için 'image' key'ini kullanıyoruz.
router.post('/add', (req, res) => {
    // Manuel ekleme (şimdilik confirm kullanılıyor, ayrı endpoint istenirse buraya)
    res.status(501).json({ message: 'Not Implemented' });
});

// Yeni Endpointler
router.post('/search', foodController.searchFood);
router.get('/favorites', foodController.getFavorites);
router.post('/favorites', foodController.addFavorite);
router.delete('/favorites/:id', foodController.removeFavorite);

router.post('/analyze', upload.single('image'), foodController.analyzeFood);

// Confirm Route
router.post('/confirm', foodController.confirmFood);

module.exports = router;
