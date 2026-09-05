const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Full Name is required'],
      trim: true,
      minlength: [2, 'Full Name must be at least 2 characters'],
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/, 'Invalid email format'],
    },
    passwordHash: {
      type: String,
      required: [true, 'Password hash is required'],
    },
    mobile: {
      type: String,
      trim: true,
      default: '',
    },
    language: {
      type: String,
      enum: ['en', 'te', 'hi', 'pa'],
      default: 'en',
    },
    profileImage: {
      type: String,
      default: '',
    },
    skills: {
      type: [String],
      default: [],
    },
    education: {
      type: String,
      default: '',
    },
    experience: {
      type: String,
      default: '',
    },
    location: {
      type: String,
      default: '',
    },
    jobPreferences: {
      locations: { type: [String], default: [] },
      categories: { type: [String], default: [] },
      jobTypes: { type: [String], default: [] },
      minSalaryLpa: { type: Number, default: 0 },
    },
    savedJobs: {
      type: [String],
      default: [],
    },
    resumeUrl: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

// Method to return sanitized user object without passwordHash
userSchema.methods.toSafeObject = function () {
  return {
    id: this._id.toString(),
    name: this.name,
    email: this.email,
    mobile: this.mobile,
    language: this.language,
    profileImage: this.profileImage,
    skills: this.skills,
    education: this.education,
    experience: this.experience,
    location: this.location,
    jobPreferences: this.jobPreferences,
    savedJobs: this.savedJobs,
    resumeUrl: this.resumeUrl,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt,
  };
};

module.exports = mongoose.model('User', userSchema);
