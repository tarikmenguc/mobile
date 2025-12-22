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
    // 1. Basit Model Tanımı
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    // 2. Basit Prompt
    const prompt = 'Bu yemek fotoğrafını analiz et ve SADECE şu JSON formatında cevap ver: {"yemekler": [{"isim": "Yemek İsmi", "kalori": 100, "makrolar": {"protein": 10, "karbonhidrat": 20, "yag": 5}, "miktar": "1 Porsiyon"}], "toplam_kalori": 100}';

    // 3. Basit Veri Paketi (Her zaman image/jpeg varsayalım veya gelen mimeType'ı kullanalım ama basit olsun)
    const imagePart = {
      inlineData: {
        data: imageBuffer.toString("base64"),
        mimeType: "image/jpeg"
      },
    };

    // 4. İstek
    const result = await model.generateContent([prompt, imagePart]);
    const response = await result.response;
    const text = response.text();

    // 5. Basit Temizlik
    const cleanJson = text.replace(/```json|```/g, "").trim();
    return JSON.parse(cleanJson);

  } catch (error) {
    console.error("Gemini Simple Error:", error);
    throw new Error("Analiz Başarısız");
  }
};

/**
 * @desc    Sağlık tahlilini analiz eder.
 * @param   {Buffer} imageBuffer
 * @param   {String} mimeType
 * @returns {Object} JSON { yorum, oneriler }
 */
const analyzeHealthReport = async (imageBuffer, mimeType) => {
  try {
    // 1. Buffer Kontrolü
    if (!Buffer.isBuffer(imageBuffer)) {
      throw new Error("Gelen veri bir Buffer değil!");
    }

    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    // 2. En Sade Prompt
    const prompt = `Bu bir kan tahlilidir. Sadece JSON formatında yorum ve öneriler döndür.
    Format:
    {
      "yorum": "Özet...",
      "oneriler": ["Öneri 1", "Öneri 2"]
    }
    `;

    // Gemini verisi hazırlığı (Sadece Resim)
    const part = {
      inlineData: {
        data: imageBuffer.toString("base64"),
        mimeType: mimeType // 'image/jpeg' vs.
      }
    };

    const result = await model.generateContent([prompt, part]);
    const response = await result.response;
    const responseText = response.text();

    // Temizlik
    const cleanJson = responseText.replace(/```json|```/g, "").trim();

    try {
      return JSON.parse(cleanJson);
    } catch (parseError) {
      console.log("GEMINI_HAM_YANIT:", responseText);
      throw new Error("AI yanıtı okunamadı (JSON formatı bozuk).");
    }

  } catch (error) {
    console.error("GEMINI_SERVIS_HATASI:", error); // İstenen Log Formatı
    throw error; // Hatayı controller'a fırlat
  }
};

module.exports = {
  analyzeImage,
  analyzeHealthReport
};
