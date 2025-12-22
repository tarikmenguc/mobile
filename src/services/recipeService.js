const DailyLog = require('../models/DailyLog');
const User = require('../models/User');
const geminiService = require('./geminiService');

/**
 * Kullanıcının elindeki malzemelere ve kalan kalori hakkına göre tarif önerir.
 * @param {String} userId - Kullanıcı ID
 * @param {Array<String>} ingredients - Malzeme listesi
 * @returns {Object} - Önerilen tarif JSON verisi
 */
const suggestRecipe = async (userId, ingredients) => {
    try {
        // 1. Kullanıcı Hedeflerini ve Bugünün Logunu Çek
        const user = await User.findById(userId);
        if (!user) throw new Error("Kullanıcı bulunamadı.");

        const today = new Date().toISOString().split('T')[0];
        let dailyLog = await DailyLog.findOne({ user_id: userId, tarih: today });

        // Eğer log yoksa boş başlat
        if (!dailyLog) {
            dailyLog = {
                toplam_alinan_kalori: 0,
                toplam_yakilan_kalori: 0
            };
        }

        // 2. Kalan Kaloriyi Hesapla: (Hedef + Yakılan) - Alınan
        // Eğer hedef henüz hesaplanmadıysa varsayılan 2000 al.
        const gunlukHedef = user.hedefler ? user.hedefler.gunluk_kalori : 2000;
        let remainingCalories = (gunlukHedef + dailyLog.toplam_yakilan_kalori) - dailyLog.toplam_alinan_kalori;

        // Eksiye düştüyse veya çok azsa minimum bir değer belirle (Örn: 300 kcal)
        // Kişi aç kalmasın, hafif bir öneri sunalım.
        if (remainingCalories < 200) {
            remainingCalories = 300;
        }

        console.log(`RECIPE AI: User=${userId}, Remaining=${remainingCalories}, Ingredients=${ingredients}`);

        // 3. Gemini Prompt Hazırla
        const prompt = `
            Sen uzman bir şef ve diyetisyensin.
            Kullanıcının elinde şu malzemeler var: ${ingredients.join(', ')}.
            Kullanıcının bugünkü kalori limitini aşmaması için en fazla ${Math.floor(remainingCalories)} kcal değerinde, sağlıklı ve pratik bir tarif üret.
            
            Yanıtı SADECE şu JSON formatında dön:
            {
                "tarif_adi": "Yemeğin Adı",
                "kalori": 250,
                "makrolar": {
                    "protein": 15,
                    "karbonhidrat": 30,
                    "yag": 10
                },
                "hazirlanis_suresi": "20 dk",
                "malzemeler": ["...", "..."],
                "adimlar": ["1. Adım...", "2. Adım..."]
            }
            Do not add any markdown formatting or extra text.
        `;

        // 4. Gemini'yi Çağır
        // geminiService.analyzeText fonksiyonunu kullanabiliriz çünkü aynı text-to-json mantığı.
        // Ancak prompt farklı olduğu için burada doğrudan model çağrısı yapmak daha temiz olabilir
        // VEYA geminiService içine genel bir 'generateText(prompt)' metodu ekleyebiliriz.
        // Hızlı çözüm: geminiService.analyzeText sadece food description bekliyor, promptu içinde hardcode ediyor.
        // Bu yüzden burada kendi model çağrımızı yapalım veya geminiService'e yeni metod ekleyelim.
        // PROJECT CONTEXT Kuralı: Logic Service katmanında olmalı. geminiService bu işi yapmalı.

        // Let's modify geminiService slightly to accept a custom prompt OR import genAI here.
        // Importing genAI here violates separation of concerns slightly but is pragmatic.
        // Better: Add 'generateRecipeFromPrompt' to geminiService.

        // For now, let's call a new method we will add to geminiService.
        const recipeData = await geminiService.generateRecipe(prompt);
        return recipeData;

    } catch (error) {
        console.error("RECIPE SERVICE ERROR:", error);
        throw error;
    }
};

module.exports = {
    suggestRecipe
};
