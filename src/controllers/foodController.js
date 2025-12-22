const geminiService = require('../services/geminiService');

/**
 * @desc    Yüklenen yemek fotoğrafını analiz eder.
 * @route   POST /api/food/analyze
 * @access  Private (Giriş yapmış kullanıcılar)
 */
const analyzeFood = async (req, res) => {
    try {
        // 1. Dosya kontrolü
        if (!req.file) {
            return res.status(400).json({ message: 'Lütfen bir resim yükleyin.' });
        }

        const path = require('path'); // En tepeye ekle

        // ...

        // 2. Mime Type Düzeltme (Emulator octet-stream gönderirse)
        let mimeType = req.file.mimetype;
        if (mimeType === 'application/octet-stream') {
            const ext = path.extname(req.file.originalname).toLowerCase();
            if (ext === '.jpg' || ext === '.jpeg') mimeType = 'image/jpeg';
            else if (ext === '.png') mimeType = 'image/png';
            else if (ext === '.webp') mimeType = 'image/webp';
            else if (ext === '.heic') mimeType = 'image/heic';
        }

        // 3. Buffer verisini servise gönder
        const analyzedData = await geminiService.analyzeImage(
            req.file.buffer,
            mimeType
        );

        // 3. Sonucu dön
        res.status(200).json({
            success: true,
            data: analyzedData
        });

    } catch (error) {
        console.error("ANALYSIS ERROR DETAILED:", error);
        res.status(500).json({
            message: 'Yemek analizi sırasında bir hata oluştu.',
            error: error.message
        });
    }
};

const logService = require('../services/logService');
const User = require('../models/User'); // User modelini ekle

/**
 * @desc    Kullanıcı tarafından onaylanan yemeği kaydeder.
 * @route   POST /api/food/confirm
 * @access  Private
 */
const confirmFood = async (req, res) => {
    try {
        const { userId, date, food } = req.body;
        if (!userId || !date || !food) {
            return res.status(400).json({ message: 'Eksik veri.' });
        }
        const updatedLog = await logService.addFoodToLog(userId, date, food);
        res.status(200).json(updatedLog);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Yemek kaydedilemedi.' });
    }
};

/**
 * @desc    Metin tabanlı yemek araması yapar (Gemini AI).
 * @route   POST /api/food/search
 * @access  Private
 */
const searchFood = async (req, res) => {
    try {
        const { text } = req.body;
        if (!text) return res.status(400).json({ message: 'Arama metni gereklidir.' });

        const result = await geminiService.analyzeText(text);
        res.status(200).json({ success: true, data: result });
    } catch (error) {
        console.error("SEARCH ERROR:", error);
        res.status(500).json({ message: 'Arama yapılamadı.', error: error.message });
    }
};

/**
 * @desc    Favorilere yemek ekler.
 * @route   POST /api/food/favorites
 */
const addFavorite = async (req, res) => {
    try {
        const { userId, food } = req.body;
        if (!userId || !food) return res.status(400).json({ message: 'Eksik veri.' });

        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: 'Kullanıcı bulunamadı.' });

        user.favoriler.push(food);
        await user.save();

        res.status(200).json(user.favoriler);
    } catch (error) {
        res.status(500).json({ message: 'Favori eklenemedi.' });
    }
};

/**
 * @desc    Favorilerden yemek siler.
 * @route   DELETE /api/food/favorites/:id
 */
const removeFavorite = async (req, res) => {
    try {
        const { userId } = req.body; // Body'den alıyoruz (GET/DELETE fark etmeksizin)
        const favoriteId = req.params.id;

        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: 'Kullanıcı bulunamadı.' });

        user.favoriler = user.favoriler.filter(fav => fav._id.toString() !== favoriteId);
        await user.save();

        res.status(200).json(user.favoriler);
    } catch (error) {
        res.status(500).json({ message: 'Favori silinemedi.' });
    }
};

/**
 * @desc    Favorileri listeler.
 * @route   GET /api/food/favorites
 */
const getFavorites = async (req, res) => {
    try {
        const { userId } = req.query;
        if (!userId) return res.status(400).json({ message: 'User ID gerekli.' });

        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: 'Kullanıcı bulunamadı.' });

        res.status(200).json(user.favoriler);
    } catch (error) {
        res.status(500).json({ message: 'Favoriler alınamadı.' });
    }
};

module.exports = {
    analyzeFood,
    confirmFood,
    searchFood,
    addFavorite,
    removeFavorite,
    getFavorites
};
