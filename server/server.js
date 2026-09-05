require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const authRoutes = require('./routes/auth');
const jobRoutes = require('./routes/jobs');

const app = express();
const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/jobvaani';

// Middleware
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'JobVaani Auth & Recruiter API',
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/saved-jobs', jobRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal server error occurred.',
  });
});

// Connect to MongoDB & Start Server
if (process.env.NODE_ENV !== 'test') {
  mongoose
    .connect(MONGODB_URI)
    .then(() => {
      console.log('✅ Connected to MongoDB Database successfully');
      app.listen(PORT, () => {
        console.log(`🚀 JobVaani Authentication Server running on port ${PORT}`);
      });
    })
    .catch((err) => {
      console.warn('⚠️ MongoDB connection failed:', err.message);
      console.warn('⚡ Starting server in standalone HTTP mode for testing & dev...');
      app.listen(PORT, () => {
        console.log(`🚀 JobVaani Authentication Server running on port ${PORT} (Standalone mode)`);
      });
    });
}

module.exports = app;
