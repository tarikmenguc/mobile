const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

/**
 * @desc    Kullanıcıyı veritabanına kaydeder, BMR hesaplar, şifreyi hashler.
 * @param   {Object} userData - Kullanıcı kayıt verileri
 * @returns {Object} - Oluşturulan kullanıcı nesnesi ve token
 */
const registerUser = async (userData) => {
    const { ad_soyad, email, password, yas, boy, kilo, cinsiyet, aktivite_seviyesi } = userData;

    // 1. Email kontrolü
    const userExists = await User.findOne({ email });
    if (userExists) {
        throw new Error('Bu email adresi ile kayıtlı kullanıcı zaten var.');
    }

    // 2. Şifre Hashleme
    // Not: Model pre-save hook kullanmak yerine explicit olarak burada yapıyoruz (MCS Mimarisi)
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 3. Kalori ve Su Hedefi Hesaplama (Logic)
    let bmr = 0;
    // Mifflin-St Jeor Formülü
    if (cinsiyet === 'erkek') {
        bmr = (10 * kilo) + (6.25 * boy) - (5 * yas) + 5;
    } else {
        bmr = (10 * kilo) + (6.25 * boy) - (5 * yas) - 161;
    }

    // Aktivite Çarpanları
    const activityMultipliers = {
        'sedanter': 1.2,
        'hafif': 1.375,
        'orta': 1.55,
        'yuksek': 1.725,
        'cok_yuksek': 1.9
    };

    const multiplier = activityMultipliers[aktivite_seviyesi] || 1.2;
    const gunluk_kalori = Math.round(bmr * multiplier);

    // 4. Kullanıcıyı Oluşturma
    const user = await User.create({
        ad_soyad,
        email,
        password: hashedPassword,
        profil: {
            yas,
            boy,
            kilo,
            cinsiyet,
            aktivite_seviyesi
        },
        hedefler: {
            gunluk_kalori,
            su_hedefi_ml: 2500 // Varsayılan sabit
        }
    });

    if (user) {
        return {
            _id: user.id,
            ad_soyad: user.ad_soyad,
            email: user.email,
            hedefler: user.hedefler,
            token: generateToken(user._id)
        };
    } else {
        throw new Error('Geçersiz kullanıcı verisi');
    }
};

/**
 * @desc    Kullanıcı girişi yapar ve token döner.
 * @param   {String} email
 * @param   {String} password
 * @returns {Object} User objesi ve token
 */
const loginUser = async (email, password) => {
    // 1. Kullanıcıyı bul
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
        throw new Error('Geçersiz email veya şifre');
    }

    // 2. Şifre kontrolü
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
        throw new Error('Geçersiz email veya şifre');
    }

    return {
        _id: user.id,
        ad_soyad: user.ad_soyad,
        email: user.email,
        hedefler: user.hedefler,
        token: generateToken(user._id)
    };
};

/**
 * @desc    JWT Token üretir.
 * @param   {String} id - Kullanıcı ID'si
 * @returns {String} JWT Token
 */
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d',
    });
};

/**
 * @desc    Kullanıcı profilini (kilo vb.) günceller ve hedefleri yeniden hesaplar.
 * @param   {String} userId
 * @param   {Object} updateData - { kilo: 80, yas: 25 ... }
 */
const updateUserProfile = async (userId, updateData) => {
    const user = await User.findById(userId);

    if (!user) {
        throw new Error('Kullanıcı bulunamadı');
    }

    // Mevcut değerleri al, gelen varsa güncelle
    const profil = user.profil;
    const yeniKilo = updateData.kilo || profil.kilo;
    const yeniBoy = updateData.boy || profil.boy;
    const yeniYas = updateData.yas || profil.yas;
    const cinsiyet = profil.cinsiyet;
    const aktivite = profil.aktivite_seviyesi;

    // Profil objesini güncelle
    user.profil = { ...profil.toObject(), ...updateData };

    // Yeni BMR Hesapla (Mifflin-St Jeor)
    let bmr = 0;
    if (cinsiyet === 'erkek') {
        bmr = (10 * yeniKilo) + (6.25 * yeniBoy) - (5 * yeniYas) + 5;
    } else {
        bmr = (10 * yeniKilo) + (6.25 * yeniBoy) - (5 * yeniYas) - 161;
    }

    // Aktivite çarpanı
    const activityMultipliers = {
        'sedanter': 1.2,
        'hafif': 1.375,
        'orta': 1.55,
        'yuksek': 1.725,
        'cok_yuksek': 1.9
    };
    const multiplier = activityMultipliers[aktivite] || 1.2;

    // Hedefleri güncelle
    user.hedefler.gunluk_kalori = Math.round(bmr * multiplier);

    await user.save();

    return {
        _id: user.id,
        ad_soyad: user.ad_soyad,
        email: user.email,
        profil: user.profil,
        hedefler: user.hedefler,
        token: generateToken(user._id)
    };
};


module.exports = {
    registerUser,
    loginUser,
    updateUserProfile
};
