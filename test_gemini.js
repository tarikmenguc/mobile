require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const candidateModels = [
    "gemini-1.5-flash",
    "gemini-1.5-flash-001",
    "gemini-1.5-flash-002",
    "gemini-1.5-flash-latest",
    "gemini-pro-vision"
];

async function testModels() {
    console.log("Testing Gemini Models...");
    console.log("API KEY Length:", process.env.GEMINI_API_KEY ? process.env.GEMINI_API_KEY.length : "MISSING");

    for (const modelName of candidateModels) {
        console.log(`\nTesting: ${modelName}`);
        try {
            const model = genAI.getGenerativeModel({ model: modelName });
            const result = await model.generateContent("Hello, are you there?");
            const response = await result.response;
            console.log(`✅ SUCCESS: ${modelName} is working!`);
            console.log("Response:", response.text ? response.text() : "No text");
            return; // Stop after first success
        } catch (error) {
            console.log(`❌ FAILED: ${modelName}`);
            console.log("Error:", error.message.split('[')[0]); // Print short error
        }
    }
}

testModels();
