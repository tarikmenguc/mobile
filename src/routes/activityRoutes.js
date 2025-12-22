const express = require('express');
const router = express.Router();
const activityController = require('../controllers/activityController');

router.post('/add', activityController.addActivity);

module.exports = router;
