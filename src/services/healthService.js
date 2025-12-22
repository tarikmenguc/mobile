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
        // 1. Gemini Modeli (API Key Listesinde Var Olan: gemini-2.5-flash)
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

        // 2. Revize Edilmiş "Kısa ve Öz" Prompt
        const prompt = `
      Sen bir sağlık veri analistisin. Yüklenen tahlili incele.
      
      GÖREVLERİN:
      1. Sadece REFERANS DIŞI (Anormal) değerleri tespit et. Normal değerleri yazma.
      2. Anormal değerleri madde imiyle (•) kısaca listele (Örn: "Demir: 216 (Yüksek) - Referans: 33-193").
      3. Bu anormallikler için 3-4 adet çok somut, uygulanabilir beslenme veya yaşam tarzı önerisi ver (Örn: "Kahvaltıda yumurta ye", "Günde 2.5L su iç").
      4. Uzun paragraflar yazma. Az laf, çok iş.

      ÇIKTI FORMATI (JSON):
      {
        "ai_analiz_metni": "⚠️ YASAL UYARI: Bu bir doktor tavsiyesi değildir, sadece veri analizidir.\n\nANORMAL DEĞERLER:\n• ...\n• ...",
        "oneriler": ["Öneri 1", "Öneri 2", "Öneri 3"]
      }
      Sadece JSON döndür. Markdown etiketi kullanma.
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
        let parsedData;
        try {
            parsedData = JSON.parse(cleanedText);
        } catch (e) {
            console.error("JSON PARSE ERROR. Raw Text:", text);
            throw new Error("AI yanıtı okunamadı.");
        }

        // 6. Veritabanına Kayıt
        const report = await HealthReport.create({
            user_id: userId,
            ai_analiz_metni: parsedData.ai_analiz_metni,
            oneriler: parsedData.oneriler
        });

        return report;

    } catch (error) {
        console.error("FULL API ERROR:", JSON.stringify(error, null, 2));
        if (error.response) {
            console.error("Gemini Error Details:", error.response);
        }
        throw new Error(`Sağlık raporu analiz edilemedi: ${error.message}`);
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
