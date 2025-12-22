require('dotenv').config();

const API_KEY = process.env.GEMINI_API_KEY;
const URL = `https://generativelanguage.googleapis.com/v1beta/models?key=${API_KEY}`;

async function listModels() {
    console.log("Querying Gemini API for available models...");
    console.log(`URL: https://generativelanguage.googleapis.com/v1beta/models?key=***`);

    try {
        const response = await fetch(URL);
        const data = await response.json();

        if (data.error) {
            console.error("❌ API ERROR:", data.error.message);
        } else if (data.models) {
            console.log("✅ AVAILABLE MODELS:");
            data.models.forEach(m => {
                if (m.supportedGenerationMethods && m.supportedGenerationMethods.includes("generateContent")) {
                    console.log(`- ${m.name}`);
                }
            });
        } else {
            console.log("⚠️ NO MODELS FOUND (Unknown response format):", data);
        }
    } catch (error) {
        console.error("❌ NETWORK/FETCH ERROR:", error.message);
    }
}

listModels();
