const authService = require('../services/authService');

/**
 * @desc    Yeni kullanıcı kaydı
 * @route   POST /api/auth/register
 * @access  Public
 */
const register = async (req, res) => {
    try {
        const user = await authService.registerUser(req.body);
        res.status(201).json(user);
    } catch (error) {
        // Servis katmanından gelen hataları yakala
        res.status(400).json({ message: error.message });
    }
};

/**
 * @desc    Kullanıcı girişi
 * @route   POST /api/auth/login
 * @access  Public
 */
const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await authService.loginUser(email, password);
        res.status(200).json(user);
    } catch (error) {
        res.status(401).json({ message: error.message });
    }
};

/**
 * @desc    Profil güncelleme (Kilo vb.)
 * @route   PUT /api/auth/update
 */
const updateProfile = async (req, res) => {
    try {
        const { userId, ...updateData } = req.body; // UserId body'den veya token'dan gelebilir
        const updatedUser = await authService.updateUserProfile(userId, updateData);
        res.status(200).json(updatedUser);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = {
    register,
    login,
    updateProfile
};
