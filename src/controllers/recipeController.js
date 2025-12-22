const recipeService = require('../services/recipeService');

/**
 * @desc    AI ile tarif üretir.
 * @route   POST /api/recipes/generate
 * @access  Private
 */
const generateRecipe = async (req, res) => {
    try {
        const { userId, ingredients } = req.body;

        if (!userId) {
            return res.status(400).json({ message: 'User ID gereklidir.' });
        }

        if (!ingredients || ingredients.length === 0) {
            return res.status(400).json({ message: 'En az bir malzeme girmelisiniz.' });
        }

        // Service çağrısı
        const recipe = await recipeService.suggestRecipe(userId, ingredients);

        res.status(200).json({
            success: true,
            data: recipe
        });

    } catch (error) {
        console.error("RECIPE CTRL ERROR:", error);
        res.status(500).json({
            message: 'Tarif üretilemedi.',
            error: error.message
        });
    }
};

module.exports = {
    generateRecipe
};
