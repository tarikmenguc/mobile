const mongoose = require('mongoose');

// Sağlık Raporu Şeması
// Project Constitution 5.C'ye uygun.
const healthReportSchema = new mongoose.Schema({
    user_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    ai_analiz_metni: {
        type: String,
        required: true
    },
    oneriler: [{
        type: String
    }],
    tarih: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('HealthReport', healthReportSchema);
