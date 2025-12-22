const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config();

// Custom fetch to list models since SDK might filter them or I want raw list
async function listModels() {
    const key = process.env.GEMINI_API_KEY;
    console.log("Listing models for key: " + key.substring(0, 5) + "...");

    // Using raw fetch to v1beta endpoint
    const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${key}`;

    try {
        const response = await fetch(url);
        const data = await response.json();

        if (data.models) {
            console.log("AVAILABLE MODELS:");
            data.models.forEach(m => {
                console.log(`- ${m.name} [${m.supportedGenerationMethods.join(', ')}]`);
            });
        } else {
            console.log("No models found or error:", data);
        }
    } catch (e) {
        console.error("Error listing models:", e);
    }
}

listModels();
