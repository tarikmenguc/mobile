const DailyLog = require('../models/DailyLog');
const User = require('../models/User');

// MET Değerleri (Metabolic Equivalent of Task)
// Kaynak: Compendium of Physical Activities
const MET_VALUES = {
    'Koşu': 8.0,
    'Yürüyüş': 3.5,
    'Bisiklet': 6.0,
    'Fitness': 5.0,
    'Futbol': 7.0,
    'Yüzme': 7.0
};

/**
 * @desc    Kullanıcının aktivite kalorisini hesaplar ve günlüğe ekler.
 * @param   {String} userId - Kullanıcı ID
 * @param   {String} activityName - Aktivite Adı (Örn: 'Koşu')
 * @param   {Number} durationMinutes - Süre (Dakika)
 * @returns {Object} Güncellenmiş Günlük Kaydı
 */
const addActivity = async (userId, activityName, durationMinutes, dateString) => {
    try {
        // 1. Kullanıcının Kilosunu Bul
        const user = await User.findById(userId);
        if (!user) throw new Error('Kullanıcı bulunamadı.');

        const weight = user.profil.kilo || 70; // Varsayılan 70kg (Eğer profil boşsa)

        // 2. MET Değerini Al
        const met = MET_VALUES[activityName] || 4.0; // Varsayılan orta şiddet

        // 3. Kalori Hesabı: Kalori = MET * Kilo * (Süre / 60)
        const burnedCalories = Math.round(met * weight * (durationMinutes / 60));

        // 4. Günlük Kaydı Bul veya Oluştur
        // Eğer client tarih göndermezse bugünü kullan (Fallback)
        const targetDate = dateString || new Date().toISOString().split('T')[0];
        let dailyLog = await DailyLog.findOne({ user_id: userId, tarih: targetDate });

        if (!dailyLog) {
            dailyLog = new DailyLog({
                user_id: userId,
                tarih: targetDate,
                toplam_alinan_kalori: 0,
                toplam_yakilan_kalori: 0,
                su_tuketimi_ml: 0,
                yemekler: [],
                aktiviteler: []
            });
        }

        // 5. Aktiviteyi Listeye Ekle
        dailyLog.aktiviteler.push({
            isim: activityName,
            sure_dk: durationMinutes,
            yakilan_kalori: burnedCalories
        });

        // 6. Toplam Yakılanı Güncelle
        dailyLog.toplam_yakilan_kalori += burnedCalories;

        await dailyLog.save();

        return {
            log: dailyLog,
            addedActivity: {
                name: activityName,
                duration: durationMinutes,
                burned: burnedCalories
            }
        };

    } catch (error) {
        console.error("Activity Service Error:", error);
        throw error;
    }
};

module.exports = {
    addActivity,
    MET_VALUES
};
