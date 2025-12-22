const express = require('express');
const router = express.Router();
const activityController = require('../controllers/activityController');

// POST /api/activity/add
router.post('/add', activityController.addActivity);

module.exports = router;
