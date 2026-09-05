import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  /// Configurable backend API base URL with automatic development host resolution
  static String get baseUrl {
    const customUrl = String.fromEnvironment('JOBVAANI_API_BASE_URL');
    if (customUrl.isNotEmpty) return customUrl;

    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    try {
      if (Platform.isAndroid) {
        // Standard Android emulator loopback to development host
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {}

    return 'http://localhost:5000';
  }

  // Authentication & Password Reset Endpoints
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';
  static const String verifyResetOtpEndpoint = '/api/auth/verify-reset-otp';
  static const String resetPasswordEndpoint = '/api/auth/reset-password';
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String profileEndpoint = '/api/auth/profile';

  // User-Isolated Saved Jobs Endpoints
  static const String savedJobsEndpoint = '/api/saved-jobs';

  // Secure Resume & Document Storage Endpoints (Private GCS/S3 with Signed URLs)
  static const String resumePresignEndpoint = '/api/v1/resumes/upload-presign';
  static const String resumeConfirmEndpoint = '/api/v1/resumes/upload-confirm';
  static const String resumeDownloadEndpoint = '/api/v1/resumes/download-signed';
  static const String resumeMetadataEndpoint = '/api/v1/resumes/metadata';
  static const String resumeDeleteEndpoint = '/api/v1/resumes';

  // AI Recommendation, FastAPI NLP & Semantic Matching Endpoints
  static const String aiJobMatchEndpoint = '/api/v1/ai/match';
  static const String aiRecommendationsEndpoint = '/api/v1/ai/recommendations';
  static const String aiResumeAnalysisEndpoint = '/api/v1/ai/analyze-resume';
  static const String aiExtractSkillsEndpoint = '/api/v1/ai/extract-skills';

  // Push Notifications & Firebase Cloud Messaging Endpoints
  static const String deviceTokenRegisterEndpoint = '/api/v1/notifications/device-token';
  static const String deviceTokenDeleteEndpoint = '/api/v1/notifications/device-token';
  static const String notificationPreferencesEndpoint = '/api/v1/notifications/preferences';

  // Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Development & Mock Configuration
  // When true and live backend is offline, allows resilient multi-user offline persistence
  static const bool enableMockFallbackWhenOffline = true;

  // Standard JSON Headers with mandatory Bearer Token authorization
  static Map<String, String> defaultHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}
