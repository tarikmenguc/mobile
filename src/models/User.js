const mongoose = require('mongoose');

// Kullanıcı Şeması
// Project Constitution 5.A'ya uygun olarak tanımlanmıştır.
const userSchema = new mongoose.Schema({
    ad_soyad: {
        type: String,
        required: [true, 'Ad soyad zorunludur']
    },
    email: {
        type: String,
        required: [true, 'Email zorunludur'],
        unique: true,
        match: [
            /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
            'Lütfen geçerli bir email adresi giriniz'
        ]
    },
    password: {
        type: String,
        required: [true, 'Şifre zorunludur'],
        minlength: 6,
        select: false // Sorgularda varsayılan olarak gelmesin
    },
    profil: {
        yas: { type: Number, required: true },
        boy: { type: Number, required: true }, // cm cinsinden
        kilo: { type: Number, required: true }, // kg cinsinden
        cinsiyet: {
            type: String,
            enum: ['erkek', 'kadın'],
            required: true
        },
        aktivite_seviyesi: {
            type: String,
            enum: ['sedanter', 'hafif', 'orta', 'yuksek', 'cok_yuksek'],
            required: true
        }
    },
    hedefler: {
        gunluk_kalori: {
            type: Number,
            default: 2000 // Varsayılan, kayıt sırasında hesaplanıp güncellenecek
        },
        su_hedefi_ml: {
            type: Number,
            default: 2500 // Project Constitution 5.A -> Default: 2500ml
        }
    },
    // Kilo Geçmişi (Yeni Özellik)
    kilo_gecmisi: [{
        kilo: Number,
        tarih: {
            type: Date,
            default: Date.now
        }
    }],
    favoriler: [{
        isim: String,
        kalori: Number,
        makrolar: {
            protein: Number,
            karbonhidrat: Number,
            yag: Number
        },
        miktar: String
    }],
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Middleware kaldırıldı, Service katmanında handle ediliyor.

module.exports = mongoose.model('User', userSchema);
