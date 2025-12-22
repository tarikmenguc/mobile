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
    // Modeli seç (Available: gemini-2.5-flash)
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    // Prompt Hazırlığı: Kesinlikle JSON formatında yanıt istiyoruz.
    const prompt = `
      Sen uzman bir diyetisyensin. Sana gönderilen yemek fotoğrafını analiz et.
      Şu formatta SADECE JSON verisi döndür, başka hiçbir metin ekleme:
      {
        "yemekler": [
          {
            "isim": "Yemeğin Türkçe Adı",
            "kalori": 100 (tahmini kalori, sayı),
            "makrolar": {
              "protein": 10 (gr),
              "karbonhidrat": 20 (gr),
              "yag": 5 (gr)
            },
            "miktar": "1 Porsiyon"
          }
        ],
        "toplam_kalori": 100
      }
      Eğer resimde yemek yoksa boş bir dizi dönebilirsin.
    `;

    // Buffer verisini Google'ın istediği formata çevir
    const imagePart = {
      inlineData: {
        data: imageBuffer.toString("base64"),
        mimeType: mimeType,
      },
    };

    // İsteği gönder
    const result = await model.generateContent([prompt, imagePart]);
    const response = await result.response;
    const text = response.text();

    // Markdown temizliği (Bazen ```json ... ``` bloğu içinde gelebilir)
    const cleanedText = text.replace(/```json/g, '').replace(/```/g, '').trim();

    return JSON.parse(cleanedText);

  } catch (error) {
    console.error("Gemini AI Hatası:", error);
    // Gerçek hatayı fırlat ki frontend ne olduğunu anlasın (API Key, Quota, vs.)
    throw new Error(error.message || 'Bilinmeyen AI Hatası');
  }
};

module.exports = {
  analyzeImage
};
