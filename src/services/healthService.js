const HealthReport = require('../models/HealthReport');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Gemini instance'ı buraya da alabiliriz veya geminiService'i kullanabiliriz.
// Ancak geminiService şu an sadece yemek odaklı JSON dönüyor.
// Sağlık analizi için farklı bir prompt ve yapı gerektiğinden buraya özel bir fonksiyon ekleyeceğiz.

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * @desc    Sağlık raporunu (resim/pdf) analiz eder ve kaydeder.
 * @param   {String} userId
 * @param   {Buffer} fileBuffer
 * @param   {String} mimeType
 */
const analyzeAndSaveReport = async (userId, fileBuffer, mimeType) => {
    try {
        // 1. Gemini Modeli Hazırla
        // 1. Gemini Modeli Hazırla
        // 1. Gemini Modeli Hazırla
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" }); // Working model from Food Service

        // 2. Prompt
        const prompt = `
      Sen uzman bir doktorsun. Yüklenen kan tahlili veya sağlık raporunu analiz et.
      Önemli bulguları ve varsa anormal değerleri açıkla.
      Ayrıca kullanıcının sağlığını iyileştirmesi için önerilerde bulun.
      
      Yanıtı şu JSON formatında ver:
      {
        "ai_analiz_metni": "Genel değerlendirme metni buraya...",
        "oneriler": ["Öneri 1", "Öneri 2", "Öneri 3"]
      }
      Sadece JSON döndür.
    `;

        // 3. Dosya Hazırlığı
        const imagePart = {
            inlineData: {
                data: fileBuffer.toString("base64"),
                mimeType: mimeType,
            },
        };

        // 4. AI İsteği
        const result = await model.generateContent([prompt, imagePart]);
        const response = await result.response;
        const text = response.text();

        // 5. JSON Temizliği
        const cleanedText = text.replace(/```json|```/g, "").trim();
        const parsedData = JSON.parse(cleanedText);

        // 6. Veritabanına Kayıt
        const report = await HealthReport.create({
            user_id: userId,
            ai_analiz_metni: parsedData.ai_analiz_metni,
            oneriler: parsedData.oneriler
        });

        return report;

    } catch (error) {
        console.log("FULL API ERROR:", JSON.stringify(error, null, 2));
        console.error("Health Analysis Error:", error);
        throw new Error('Sağlık raporu analiz edilemedi.');
    }
};

/**
 * @desc    Kullanıcının geçmiş raporlarını getirir.
 */
const getUserReports = async (userId) => {
    return await HealthReport.find({ user_id: userId }).sort({ tarih: -1 });
};

module.exports = {
    analyzeAndSaveReport,
    getUserReports
};
