// Native fetch in Node 18+
require('dotenv').config();

async function checkApiKey() {
    const key = process.env.GEMINI_API_KEY;
    console.log("Checking API Key directly...");

    const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${key}`;

    try {
        const response = await fetch(url);
        const data = await response.json();

        if (response.ok) {
            console.log("SUCCESS! Available Models:");
            if (data.models) {
                data.models.forEach(m => console.log(` - ${m.name}`));
            } else {
                console.log("No models found in list (Empty array).");
            }
        } else {
            console.error("API Request Failed:", response.status, response.statusText);
            console.error("Error Body:", JSON.stringify(data, null, 2));
        }
    } catch (error) {
        console.error("Network Error:", error.message);
    }
}

checkApiKey();
