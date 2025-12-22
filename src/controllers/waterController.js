const DailyLog = require('../models/DailyLog');

/**
 * @desc    Su tüketimini günceller (Ekle veya Çıkar).
 * @route   POST /api/water/update
 * @access  Private
 */
const updateWater = async (req, res) => {
    try {
        const { userId, date, amount } = req.body; // amount: +200 veya -200 olabilir

        if (!userId || !date || amount === undefined) {
            return res.status(400).json({ message: 'Eksik veri.' });
        }

        const updatedLog = await DailyLog.findOneAndUpdate(
            { user_id: userId, tarih: date },
            { $inc: { su_tuketimi_ml: amount } },
            { new: true, upsert: true }
        );

        res.status(200).json(updatedLog);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Su verisi güncellenemedi.' });
    }
};

module.exports = {
    updateWater
};
