const DailyLog = require('../models/DailyLog');
const User = require('../models/User');
const activityService = require('../services/activityService');

/**
 * @desc    Aktivite ekler ve kaloriyi hesaplar.
 * @route   POST /api/activity/add
 * @access  Private
 */
const addActivity = async (req, res) => {
    try {
        const { userId, date, activity } = req.body;
        // activity: { isim, sure_dk } -> calorie hesaplanacak

        if (!userId || !date || !activity || !activity.isim || !activity.sure_dk) {
            return res.status(400).json({ message: 'Eksik veri: userId, date, activity.name, activity.duration required.' });
        }

        // 1. Kullanıcı kilosunu al
        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: "Kullanıcı bulunamadı" });

        const userWeight = user.profil.kilo || 70; // Varsayılan 70kg

        // 2. Kalori Hesapla
        const burnedCal = activityService.calculateCalories(userWeight, activity.isim, activity.sure_dk);

        // 3. Log'a ekle
        const newActivity = {
            isim: activity.isim,
            sure_dk: activity.sure_dk,
            yakilan_kalori: burnedCal
        };

        const updatedLog = await DailyLog.findOneAndUpdate(
            { user_id: userId, tarih: date },
            {
                $push: { aktiviteler: newActivity },
                $inc: { toplam_yakilan_kalori: burnedCal }
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
