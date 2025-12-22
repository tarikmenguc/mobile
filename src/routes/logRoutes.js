const express = require('express');
const router = express.Router();
const logController = require('../controllers/logController');

// GET Daily Log
router.get('/:date', logController.getDailyLog);

module.exports = router;
