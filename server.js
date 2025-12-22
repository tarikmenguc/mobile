const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./src/config/db');

// Load env vars
dotenv.config();

// Connect to database
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/food', require('./src/routes/foodRoutes'));
app.use('/api/logs', require('./src/routes/logRoutes'));
app.use('/api/health', require('./src/routes/healthRoutes'));
app.use('/api/water', require('./src/routes/waterRoutes'));
app.use('/api/activity', require('./src/routes/activityRoutes'));

// Basic Route for Testing
app.get('/', (req, res) => {
    res.send('API is running...');
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
