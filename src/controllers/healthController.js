const healthService = require('../services/healthService');

/**
 * @desc    Sağlık raporu yükler ve analiz ettirir.
 * @route   POST /api/health/analyze
 * @access  Private
 */
const analyze = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, message: 'Lütfen bir dosya yükleyin.' });
        }

        const userId = req.body.userId;
        if (!userId) {
            return res.status(400).json({ success: false, message: 'User ID gereklidir.' });
        }

        console.log('Gemini analizi başladı...');

        const report = await healthService.analyzeAndSaveReport(
            userId,
            req.file.buffer,
            req.file.mimetype
        );

        console.log('Gemini yanıtı geldi.');

        res.status(200).json({ success: true, data: report });

    } catch (error) {
        console.error("DETAYLI_HATA_ANALIZI:", {
            mesaj: error.message,
            stack: error.stack,
            dosyaVarMi: !!req.file,
            dosyaTipi: req.file?.mimetype
        });
        return res.status(500).json({ success: false, error: error.message });
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

module.exports = {
    analyze,
    getHistory
};
