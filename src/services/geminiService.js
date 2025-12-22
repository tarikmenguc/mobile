const { GoogleGenerativeAI } = require('@google/generative-ai');

// Google Generative AI İstemcisi Başlatılıyor
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * @desc    Resmi Gemini API ile analiz eder ve yemek verilerini JSON olarak döner.
 * @param   {Buffer} imageBuffer - Yüklenen resmin raw buffer verisi
 * @param   {String} mimeType - Resmin mime type'ı (image/jpeg vb.)
 * @returns {Object} - Analiz edilen yemek verisi (isim, kalori, makrolar)
 */
const analyzeImage = async (imageBuffer, mimeType) => {
  try {
    // 1. Model Seçimi (gemini-2.5-flash-lite)
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash-lite" });

    // 2. Basit ve Net Prompt
    const prompt = `
      You are a specialized nutritionist AI.
      Analyze this food image and return ONLY a JSON response in the following format:
      {
        "yemekler": [
          {
            "isim": "Yemek İsmi",
            "kalori": 100,
            "makrolar": {
              "protein": 10,
              "karbonhidrat": 20,
              "yag": 5
            },
            "miktar": "1 Porsiyon"
          }
        ],
        "toplam_kalori": 100
      }
      Do not add any markdown formatting or extra text.
    `;

    // 3. Veri Paketi
    const imagePart = {
      inlineData: {
        data: imageBuffer.toString("base64"),
        mimeType: mimeType || "image/jpeg"
      },
    };

    // 4. İstek Gönderimi
    const result = await model.generateContent([prompt, imagePart]);
    const response = await result.response;
    const text = response.text();

    console.log("GEMINI_RAW_RESPONSE:", text);

    // 5. JSON Temizliği (Markdown bloğu varsa kaldır)
    const cleanJson = text.replace(/```json|```/g, "").trim();

    return JSON.parse(cleanJson);

  } catch (error) {
    console.error("GEMINI_HATASI:", error.message);
    if (error.response) {
      console.error("GEMINI_API_DETAY:", JSON.stringify(error.response, null, 2));
    }
    throw new Error("Yemek analizi başarısız oldu: " + error.message);
  }
};

/**
 * @desc    Metin tabanlı yemek analizi yapar.
 * @param   {String} text - Kullanıcının girdiği yemek tanımı (Örn: "1 kase mercimek çorbası")
 * @returns {Object} - Analiz edilen yemek verisi
 */
const analyzeText = async (text) => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash-lite" });
    const prompt = `
          You are a specialized nutritionist AI.
          Analyze the following food description: "${text}".
          Return ONLY a JSON response in the following format:
          {
            "isim": "Food Name",
            "kalori": 100,
            "makrolar": {
              "protein": 10,
              "karbonhidrat": 20,
              "yag": 5
            },
            "miktar": "1 Portion"
          }
          Do not add any markdown formatting or extra text.
        `;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const responseText = response.text();

    console.log("GEMINI_TEXT_RAW:", responseText);

    const cleanJson = responseText.replace(/```json|```/g, "").trim();
    return JSON.parse(cleanJson);
  } catch (error) {
    console.error("GEMINI_TEXT_ERROR:", error.message);
    throw new Error("Metin analizi başarısız: " + error.message);
  }
};

/**
 * @desc    Özel prompt ile tarif üretir.
 * @param   {String} prompt - Hazırlanan detaylı prompt
 * @returns {Object} - Tarif JSON verisi
 */
const generateRecipe = async (prompt) => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash-lite" });
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    console.log("GEMINI_RECIPE_RAW:", text);

    const cleanJson = text.replace(/```json|```/g, "").trim();
    return JSON.parse(cleanJson);
  } catch (error) {
    console.error("GEMINI_RECIPE_ERROR:", error.message);
    throw new Error("Tarif üretilemedi: " + error.message);
  }
};

module.exports = {
  analyzeImage,
  analyzeText,
  generateRecipe
};
