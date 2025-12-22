const { GoogleGenerativeAI } = require("@google/generative-ai");

// SDK Başlatma - En sade hali (Otomatik Stable Sürüm)
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * @desc    Resmi Gemini API ile analiz eder (SADE VE KARARLI VERSİYON)
 */
const analyzeImage = async (imageBuffer, mimeType) => {
  try {
    // 1. Model Tanımı (Sabit: gemini-1.5-flash)
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    // 2. Basit Prompt
    const prompt = `
      You are a nutritionist AI.
      Analyze this image and return ONLY JSON:
      {
        "yemekler": [
          {
            "isim": "Food Name",
            "kalori": 100,
            "makrolar": { "protein": 10, "karbonhidrat": 20, "yag": 5 },
            "miktar": "1 Portion"
          }
        ],
        "toplam_kalori": 100
      }
    `;

    // 3. Veri Paketi (Base64)
    const imagePart = {
      inlineData: {
        data: imageBuffer.toString("base64"),
        mimeType: mimeType || "image/jpeg"
      },
    };

    // 4. İstek ve Yanıt
    const result = await model.generateContent([prompt, imagePart]);
    const response = await result.response;
    const text = response.text();

    // 5. Temizlik ve Parse
    const cleanJson = text.replace(/```json|```/g, "").trim();
    return JSON.parse(cleanJson);

  } catch (error) {
    console.error("GEMINI_CRITICAL_ERROR:", error);
    throw new Error("AI Analizi Başarısız.");
  }
};

module.exports = {
  analyzeImage
};
