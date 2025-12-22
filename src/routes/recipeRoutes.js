const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');

router.post('/generate', recipeController.generateRecipe);

module.exports = router;
