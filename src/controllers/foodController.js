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

// ... (mevcut analyzeFood kodu) ...
// Not: Mevcut kodun silinmemesi için analyzeFood fonksiyonunu tekrar tanımlamıyoruz, sadece ekliyoruz ama replace tool ile tüm dosyayı yönetmek daha güvenli olabilir 
// veya sadece export kısmını ve altına eklemeyi yapabiliriz. 
// Burada sadece ekleme yapacağım.

/**
 * @desc    Kullanıcı tarafından onaylanan yemeği kaydeder.
 * @route   POST /api/food/confirm
 * @access  Private
 */
const confirmFood = async (req, res) => {
    try {
        // req.user, authMiddleware'den gelecek (henüz aktif değilse body'den user_id alabiliriz test için, ama doğrusu authMiddleware)
        // Şimdilik test kolaylığı için body'den userId alalım, gerçekte req.user.id olmalı
        const { userId, date, food } = req.body;

        // Basit Validasyon
        if (!userId || !date || !food) {
            return res.status(400).json({ message: 'Eksik veri: userId, date ve food gereklidir.' });
        }

        const updatedLog = await logService.addFoodToLog(userId, date, food);

        res.status(200).json(updatedLog);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Yemek kaydedilemedi.' });
    }
};

module.exports = {
    analyzeFood,
    confirmFood
};
