/**
 * @desc    API Yanıtlarını standartlaştırır.
 */
const success = (res, data, message = 'İşlem başarılı.', statusCode = 200) => {
    return res.status(statusCode).json({
        success: true,
        message,
        data
    });
};

const error = (res, message = 'Bir hata oluştu.', statusCode = 500, errorDetails = null) => {
    return res.status(statusCode).json({
        success: false,
        message,
        error: errorDetails
    });
};

module.exports = {
    success,
    error
};
