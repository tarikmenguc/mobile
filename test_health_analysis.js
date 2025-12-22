require('dotenv').config();
const healthService = require('./src/services/healthService');
const mongoose = require('mongoose');

// Mock User ID (Replace with a real one from your DB if needed, or use a dummy ObjectId)
const mockUserId = new mongoose.Types.ObjectId();

// Connect to DB (Mock or Real) - We need real connection for 'analyzeAndSaveReport' because it saves to DB
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log(`MongoDB Connected: ${mongoose.connection.host}`);
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};

const runTest = async () => {
    await connectDB();

    try {
        // Create a dummy mostly empty buffer to simulate a file (Gemini might complain about content, but we test the connection first)
        // Better: Use a small base64 valid image string converted to buffer
        const base64Image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="; // 1x1 red pixel
        const fileBuffer = Buffer.from(base64Image, 'base64');
        const mimeType = "image/png";

        console.log("Starting Analysis...");
        const result = await healthService.analyzeAndSaveReport(mockUserId, fileBuffer, mimeType);

        console.log("Analysis Result:", JSON.stringify(result, null, 2));

    } catch (error) {
        console.error("TEST FAILED:", error);
    } finally {
        await mongoose.disconnect();
    }
};

runTest();
