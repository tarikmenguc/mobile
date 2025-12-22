const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function testHealthAnalysis() {
    console.log("Testing Health Analysis with gemini-2.0-flash-exp...");

    try {
        const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-exp" });

        // Mock Image data (1x1 transparent pixel png)
        const base64Image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==";
        const mimeType = "image/png";

        const prompt = `
          Sen uzman bir doktorsun. Yüklenen kan tahlili veya sağlık raporunu analiz et.
          Yanıtı sadece JSON döndür.
        `;

        const imagePart = {
            inlineData: {
                data: base64Image,
                mimeType: mimeType,
            },
        };

        console.log("Sending request...");
        const result = await model.generateContent([prompt, imagePart]);
        const response = await result.response;
        const text = response.text();

        console.log("SUCCESS! Response:");
        console.log(text);

    } catch (error) {
        console.error("ANALYSIS FAILED:");
        console.error(error.message);
        if (error.response) {
            console.error("FULL ERROR DETAILS:", JSON.stringify(error.response, null, 2));
        }
    }
}

testHealthAnalysis();
