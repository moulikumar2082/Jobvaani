const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const authMiddleware = require('../middleware/auth');

const JWT_SECRET = process.env.JWT_SECRET || 'jobvaani_jwt_secret_key_prod_2026_super_secure';
const JWT_EXPIRES_IN = '7d';

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user account with hashed password
 * @access  Public
 */
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, mobile, language } = req.body;

    // 1. Validate required fields
    if (!name || name.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Full Name is required and must be at least 2 characters.',
      });
    }

    if (!email || !/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(email.trim())) {
      return res.status(400).json({
        success: false,
        message: 'Please enter a valid email address.',
      });
    }

    if (!password || password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    // 2. Prevent duplicate email registration
    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'An account with this email already exists. Please login.',
      });
    }

    // 3. Hash password using bcrypt (10 rounds)
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // 4. Create and persist user
    const newUser = new User({
      name: name.trim(),
      email: normalizedEmail,
      passwordHash,
      mobile: mobile ? mobile.trim() : '',
      language: ['en', 'te', 'hi', 'pa'].includes(language) ? language : 'en',
    });

    await newUser.save();

    // 5. Generate JWT token
    const token = jwt.sign(
      { userId: newUser._id.toString(), email: newUser.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    return res.status(201).json({
      success: true,
      message: 'Account created successfully',
      token,
      user: newUser.toSafeObject(),
    });
  } catch (err) {
    console.error('Registration error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error during registration. Please try again.',
    });
  }
});

/**
 * @route   POST /api/auth/login
 * @desc    Authenticate user credentials and return JWT
 * @access  Public
 */
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide both email and password.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    // 1. Locate user by email
    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Incorrect email or password.',
      });
    }

    // 2. Verify password with bcrypt
    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Incorrect email or password.',
      });
    }

    // 3. Generate signed JWT token
    const token = jwt.sign(
      { userId: user._id.toString(), email: user.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: user.toSafeObject(),
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({
      success: false,
      message: 'Server error during login. Please try again.',
    });
  }
});

/**
 * @route   POST /api/auth/forgot-password
 * @desc    Initiate password reset request
 * @access  Public
 */
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Please provide an email address.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const user = await User.findOne({ email: normalizedEmail });

    // Always respond with neutral success message to prevent user enumeration
    return res.status(200).json({
      success: true,
      message: 'If an account exists with this email, password reset instructions have been sent.',
      expiresInMinutes: 15,
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Unable to process password reset at this time.',
    });
  }
});

/**
 * @route   GET /api/auth/profile
 * @desc    Retrieve authenticated user profile
 * @access  Private (JWT required)
 */
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User profile not found.',
      });
    }

    return res.status(200).json({
      success: true,
      user: user.toSafeObject(),
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving profile.',
    });
  }
});

/**
 * @route   PUT /api/auth/profile
 * @desc    Update authenticated user profile
 * @access  Private (JWT required)
 */
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const { name, mobile, language, skills, education, experience, location, jobPreferences } = req.body;

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (name) user.name = name.trim();
    if (mobile !== undefined) user.mobile = mobile.trim();
    if (language && ['en', 'te', 'hi', 'pa'].includes(language)) user.language = language;
    if (skills) user.skills = skills;
    if (education) user.education = education;
    if (experience) user.experience = experience;
    if (location) user.location = location;
    if (jobPreferences) user.jobPreferences = jobPreferences;

    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      user: user.toSafeObject(),
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Server error updating profile.',
    });
  }
});

module.exports = router;
