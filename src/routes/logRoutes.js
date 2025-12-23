const express = require('express');
const router = express.Router();
const logController = require('../controllers/logController');

// GET History (Must be before /:date to avoid conflict if date param is ambiguous, but here :date is typical)
// Better explicit path
router.get('/history', logController.getHistory);

// GET Daily Log
router.get('/:date', logController.getDailyLog);

module.exports = router;
