const DailyLog = require('../models/DailyLog');

/**
 * @desc    Belirtilen tarih için kullanıcının günlüğünü getirir veya oluşturur.
 * @param   {String} userId
 * @param   {String} dateString "YYYY-MM-DD"
 */
const getOrCreateLog = async (userId, dateString) => {
    let log = await DailyLog.findOne({ user_id: userId, tarih: dateString });

    if (!log) {
        log = await DailyLog.create({
            user_id: userId,
            tarih: dateString,
            yemekler: [],
            aktiviteler: []
        });
    }
    return log;
};

/**
 * @desc    Onaylanan yemeği günlüğe ekler ve toplam kaloriyi günceller.
 * @param   {String} userId
 * @param   {String} dateString
 * @param   {Object} foodData
 */
const addFoodToLog = async (userId, dateString, foodData) => {
    // Atomik güncelleme ile verimlilik ve tutarlılık
    const updatedLog = await DailyLog.findOneAndUpdate(
        { user_id: userId, tarih: dateString },
        {
            $push: { yemekler: foodData },
            $inc: { toplam_alinan_kalori: foodData.kalori }
        },
        { new: true, upsert: true } // Yoksa oluştur, yeniyi dön
    );

    return updatedLog;
};

/**
 * @desc    Belirtilen günün logunu getirir.
 */
const getLog = async (userId, dateString) => {
    return await DailyLog.findOne({ user_id: userId, tarih: dateString });
};

/**
 * @desc    Son X günün verilerini getirir (Haftalık Özet için)
 */
const getWeeklyLog = async (userId, days = 7) => {
    // MongoDB aggregation ile daha şık olur ama basitçe find ile yapalım.
    // Tarih string olduğu için string karşılaştırması "YYYY-MM-DD" formatında çalışır.

    // Basit bir yaklaşım: Son 7 günün tarihlerini oluşturup $in ile çekmek veya string range kullanmak.
    // Tarih "YYYY-MM-DD" standardındaysa string sort çalışır.

    const logs = await DailyLog.find({ user_id: userId })
        .sort({ tarih: -1 }) // En yeni en üstte
        .limit(days);

    return logs;
};

module.exports = {
    getOrCreateLog,
    addFoodToLog,
    getLog,
    getWeeklyLog
};
