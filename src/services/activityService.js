/**
 * Metabolic Equivalent of Task (MET) Değerleri
 * Kaynak: Compendium of Physical Activities
 */
const ACTIVITY_MET_VALUES = {
    "koşu": 8.0,
    "yürüyüş": 3.5,
    "yüzme": 7.0,
    "bisiklet": 6.0,
    "fitness": 5.0,
    "futbol": 7.0,
    "basketbol": 6.0,
    "tenis": 7.0,
    "voleybol": 4.0,
    "dans": 4.5
};

/**
 * Yakılan kaloriyi hesaplar.
 * Formül: (MET * 3.5 * Kilo) / 200 * Süre(dk)
 * Veya basitçe referans: 1 MET = 1 kcal/kg/saat
 * Bizim kullandığımız: Kalori = MET * Kilo * (Süre / 60)
 * 
 * @param {Number} weight - Kullanıcı kilosu (kg)
 * @param {String} activityName - Aktivite adı (TR)
 * @param {Number} durationMinutes - Süre (dk)
 * @returns {Number} Yakılan Kalori
 */
const calculateCalories = (weight, activityName, durationMinutes) => {
    // 1. İsim normalizasyonu (küçük harf ve trim)
    const normalizedName = activityName ? activityName.toLowerCase().trim() : '';

    // 2. MET değeri bulma (Yoksa varsayılan 4.0)
    const met = ACTIVITY_MET_VALUES[normalizedName] || 4.0;

    // Formül: Kalori = MET * Kilo * (Süre/60)
    const burnedCalories = met * weight * (durationMinutes / 60);

    return Math.round(burnedCalories);
};

const getActivityTypes = () => {
    return Object.keys(ACTIVITY_MET_VALUES);
};

module.exports = {
    MET_VALUES: ACTIVITY_MET_VALUES, // Geriye dönük uyumluluk için (varsa)
    calculateCalories,
    getActivityTypes
};
