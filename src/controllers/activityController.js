const DailyLog = require('../models/DailyLog');

/**
 * @desc    Aktivite ekler.
 * @route   POST /api/activity/add
 * @access  Private
 */
const addActivity = async (req, res) => {
    try {
        const { userId, date, activity } = req.body;
        // activity: { isim, sure_dk, yakilan_kalori }

        if (!userId || !date || !activity) {
            return res.status(400).json({ message: 'Eksik veri.' });
        }

        const updatedLog = await DailyLog.findOneAndUpdate(
            { user_id: userId, tarih: date },
            {
                $push: { aktiviteler: activity },
                $inc: { toplam_yakilan_kalori: activity.yakilan_kalori }
            },
            { new: true, upsert: true }
        );

        res.status(200).json(updatedLog);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Aktivite eklenemedi.' });
    }
};

module.exports = {
    addActivity
};
