const activityService = require('../services/activityService');
const responseHelper = require('../utils/responseHelper');

/**
 * @desc    Yeni aktivite ekler.
 * @route   POST /api/activity/add
 * @access  Private
 */
const addActivity = async (req, res) => {
    try {
        const { userId, activityName, duration, date } = req.body;

        if (!userId || !activityName || !duration) {
            return responseHelper.error(res, 'Eksik parametreler.', 400);
        }

        const result = await activityService.addActivity(userId, activityName, duration, date);

        return responseHelper.success(res, result, 'Aktivite başarıyla eklendi.');

    } catch (error) {
        console.error("Add Activity Controller Error:", error);
        return responseHelper.error(res, 'Aktivite eklenirken sunucu hatası.', 500);
    }
};

module.exports = {
    addActivity
};
