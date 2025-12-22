const mongoose = require('mongoose');

// Günlük Kayıt Şeması
// Project Constitution 5.B'ye uygun.
const dailyLogSchema = new mongoose.Schema({
    user_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    tarih: {
        type: String, // "YYYY-MM-DD" formatında
        required: true
    },
    toplam_alinan_kalori: { type: Number, default: 0 },
    toplam_yakilan_kalori: { type: Number, default: 0 },
    su_tuketimi_ml: { type: Number, default: 0 },

    yemekler: [{
        isim: String,
        kalori: Number,
        makrolar: {
            protein: Number,
            karbonhidrat: Number,
            yag: Number
        },
        miktar: String, // "1 Porsiyon" vb.
        kaynak: {
            type: String,
            enum: ['ai', 'barkod', 'manuel'],
            default: 'manuel'
        },
        saat: {
            type: Date,
            default: Date.now
        }
    }],

    aktiviteler: [{
        isim: String,
        sure_dk: Number, // dakika
        yakilan_kalori: Number,
        saat: {
            type: Date,
            default: Date.now
        }
    }]
}, { timestamps: true });

// Kritik Kural: Bir kullanıcının aynı tarih için sadece 1 kaydı olabilir.
dailyLogSchema.index({ user_id: 1, tarih: 1 }, { unique: true });

module.exports = mongoose.model('DailyLog', dailyLogSchema);
