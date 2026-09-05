const express = require('express');
const router = express.Router();
const User = require('../models/User');
const authMiddleware = require('../middleware/auth');

/**
 * @route   GET /api/saved-jobs
 * @desc    Get saved jobs for authenticated user (isolated strictly by JWT)
 * @access  Private
 */
router.get('/', authMiddleware, async (req, res) => {
  try {
    // Note: req.user.id is extracted directly from the verified JWT token.
    // Client-provided query parameters like ?userId=... are deliberately ignored.
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.status(200).json({
      success: true,
      savedJobs: user.savedJobs || [],
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving saved jobs',
    });
  }
});

/**
 * @route   POST /api/saved-jobs
 * @desc    Toggle or save a job for authenticated user
 * @access  Private
 */
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { jobId } = req.body;
    if (!jobId) {
      return res.status(400).json({ success: false, message: 'jobId is required' });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const index = user.savedJobs.indexOf(jobId);
    let isSaved = false;

    if (index > -1) {
      user.savedJobs.splice(index, 1);
      isSaved = false;
    } else {
      user.savedJobs.push(jobId);
      isSaved = true;
    }

    await user.save();

    return res.status(200).json({
      success: true,
      isSaved,
      savedJobs: user.savedJobs,
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Server error saving job',
    });
  }
});

/**
 * @route   DELETE /api/saved-jobs/:jobId
 * @desc    Remove a saved job for authenticated user
 * @access  Private
 */
router.delete('/:jobId', authMiddleware, async (req, res) => {
  try {
    const { jobId } = req.params;

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.savedJobs = user.savedJobs.filter((id) => id !== jobId);
    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Job removed from saved jobs',
      savedJobs: user.savedJobs,
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Server error removing saved job',
    });
  }
});

module.exports = router;
