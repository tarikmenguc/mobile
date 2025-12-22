const express = require('express');
const router = express.Router();
const waterController = require('../controllers/waterController');

router.post('/update', waterController.updateWater);

module.exports = router;
