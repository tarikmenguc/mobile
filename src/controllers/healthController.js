const healthService = require('../services/healthService');

/**
 * @desc    Sağlık raporu yükler ve analiz ettirir.
 * @route   POST /api/health/analyze
 * @access  Private
 */
const analyze = async (req, res) => {
    try {
        console.log('--- HEALTH ANALYSIS REQUEST ---');
        if (!req.file) {
            console.error('HATA: Dosya yok.');
            return res.status(400).json({ message: 'Lütfen bir dosya yükleyin.' });
        }
        console.log(`Dosya Alındı: ${req.file.originalname} (${req.file.mimetype})`);

        // Auth middleware aktifleşince req.user.id
        const userId = req.body.userId;

        if (!userId) {
            return res.status(400).json({ message: 'User ID gereklidir.' });
        }

        const report = await healthService.analyzeAndSaveReport(
            userId,
            req.file.buffer,
            req.file.mimetype
        );

        res.status(200).json(report);

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

/**
 * @desc    Geçmiş raporları listeler.
 * @route   GET /api/health/history
 * @access  Private
 */
const getHistory = async (req, res) => {
    try {
        const userId = req.query.userId;
        if (!userId) {
            return res.status(400).json({ message: 'User ID gereklidir.' });
        }
        const reports = await healthService.getUserReports(userId);
        res.status(200).json(reports);
    } catch (error) {
        res.status(500).json({ message: 'Rapor geçmişi alınamadı.' });
    }
};

/**
 * @desc    En son rapordan AI tavsiyesini döner.
 * @route   GET /api/health/tip
 * @access  Private
 */
const getLatestTip = async (req, res) => {
    try {
        const userId = req.query.userId;
        if (!userId) {
            return res.status(400).json({ message: 'User ID gereklidir.' });
        }

        // Servisteki mevcut fonksiyonu kullan (Tarihe göre sıralı gelir)
        const reports = await healthService.getUserReports(userId);

        if (reports && reports.length > 0) {
            const lastReport = reports[0];
            // Eğer öneri varsa ilkini, yoksa genel bir mesaj dön
            const tip = (lastReport.oneriler && lastReport.oneriler.length > 0)
                ? lastReport.oneriler[0]
                : "Sağlıklı yaşam için bol su içmeyi unutmayın!";

            res.status(200).json({ tip });
        } else {
            // Hiç rapor yoksa
            res.status(200).json({ tip: "Henüz bir tahlil yüklemediniz. İlk analizinizden sonra size özel tavsiyeler vereceğim." });
        }
    } catch (error) {
        res.status(500).json({ message: 'Tavsiye alınamadı.' });
    }
};

module.exports = {
    analyze,
    getHistory,
    getLatestTip
};
