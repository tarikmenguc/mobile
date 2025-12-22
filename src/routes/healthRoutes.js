const express = require('express');
const router = express.Router();
const healthController = require('../controllers/healthController');
const upload = require('../middleware/uploadMiddleware');

router.post('/analyze', upload.single('file'), healthController.analyze); // file key'i ile yükle
router.get('/history', healthController.getHistory);
router.get('/tip', healthController.getLatestTip);

module.exports = router;
