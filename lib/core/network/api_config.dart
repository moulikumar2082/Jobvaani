class ApiConfig {
  ApiConfig._();

  /// Configurable backend API base URL with fallback for development
  static const String baseUrl = String.fromEnvironment(
    'JOBVAANI_API_BASE_URL',
    defaultValue: 'https://api.jobvaani.in',
  );

  // Authentication & Password Reset Endpoints
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';
  static const String verifyResetOtpEndpoint = '/api/auth/verify-reset-otp';
  static const String resetPasswordEndpoint = '/api/auth/reset-password';
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';

  // Secure Resume & Document Storage Endpoints (Private GCS/S3 with Signed URLs)
  // Architecture strictly forbids public object ACLs. Short-lived signed URLs expire in 15 mins.
  static const String resumePresignEndpoint = '/api/v1/resumes/upload-presign';
  static const String resumeConfirmEndpoint = '/api/v1/resumes/upload-confirm';
  static const String resumeDownloadEndpoint = '/api/v1/resumes/download-signed';
  static const String resumeMetadataEndpoint = '/api/v1/resumes/metadata';
  static const String resumeDeleteEndpoint = '/api/v1/resumes';

  // AI Recommendation, FastAPI NLP & Semantic Matching Endpoints (Steps 20 & 21)
  static const String aiJobMatchEndpoint = '/api/v1/ai/match';
  static const String aiRecommendationsEndpoint = '/api/v1/ai/recommendations';
  static const String aiResumeAnalysisEndpoint = '/api/v1/ai/analyze-resume';
  static const String aiExtractSkillsEndpoint = '/api/v1/ai/extract-skills';

  // Push Notifications & Firebase Cloud Messaging Endpoints (Step 23)
  static const String deviceTokenRegisterEndpoint = '/api/v1/notifications/device-token';
  static const String deviceTokenDeleteEndpoint = '/api/v1/notifications/device-token';
  static const String notificationPreferencesEndpoint = '/api/v1/notifications/preferences';

  // Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Development & Mock Configuration
  // When true and live backend is offline or unreachable, allows graceful development preview
  static const bool enableMockFallbackWhenOffline = true;

  // Standard JSON Headers
  static Map<String, String> defaultHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}
