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

module.exports = {
    getOrCreateLog,
    addFoodToLog,
    getLog
};
