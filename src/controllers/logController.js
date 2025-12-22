const logService = require('../services/logService');

/**
 * @desc    Belirtilen günün tüm verilerini getirir.
 * @route   GET /api/logs/:date
 * @access  Private
 */
const getDailyLog = async (req, res) => {
    try {
        const { date } = req.params;
        // Auth middleware olmadığı için userId'yi query'den veya body'den almak zorundayız GET isteğinde query mantıklıdır.
        // Ancak kullanıcı standartı olarak Header'da token'dan userId alırız. 
        // Auth middleware şimdilik kapalıysa query string'den alalım.
        const userId = req.query.userId;

        if (!userId) {
            return res.status(400).json({ message: 'User ID gereklidir (Query param olarak).' });
        }

        const log = await logService.getLog(userId, date);

        if (!log) {
            // O gün henüz veri yoksa boş bir yapı dönebiliriz veya 404
            // UI kolaylığı için boş dönmek daha iyidir ama backend mantığı 404 de olabilir.
            // Proje mantığında getOrCreate olmadığı için null dönelim, UI anlasın.
            return res.status(200).json({ message: 'Bu tarih için kayıt bulunamadı', data: null });
        }

        res.status(200).json(log);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Günlük verisi alınamadı.' });
    }
};

module.exports = {
    getDailyLog
};
