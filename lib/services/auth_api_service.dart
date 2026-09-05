import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_config.dart';
import '../data/models/auth_models.dart';

class AuthApiService {
  final HttpClient _client;
  static const String _userRegistryKey = 'jobvaani_offline_user_registry_v1';

  AuthApiService({HttpClient? client}) : _client = client ?? HttpClient();

  /// Authenticates user against backend API via POST /api/auth/login
  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');
    final requestPayload = jsonEncode(request.toJson());

    try {
      final httpRequest = await _client.postUrl(url).timeout(ApiConfig.connectTimeout);

      ApiConfig.defaultHeaders().forEach((key, value) {
        httpRequest.headers.set(key, value);
      });

      httpRequest.write(requestPayload);
      final response = await httpRequest.close().timeout(ApiConfig.receiveTimeout);

      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return LoginResponse.fromJson(json);
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        final message = json['message'] as String? ?? 'Invalid email or password.';
        return LoginResponse.failure(
          message,
          errorType: AuthErrorType.invalidCredentials,
        );
      } else if (response.statusCode == 404) {
        final message = json['message'] as String? ?? 'No account found with this email address.';
        return LoginResponse.failure(
          message,
          errorType: AuthErrorType.userNotFound,
        );
      } else if (response.statusCode >= 500) {
        return LoginResponse.failure(
          'Server is currently unavailable. Please try again later.',
          errorType: AuthErrorType.serverUnavailable,
        );
      } else {
        final message = json['message'] as String? ?? 'Authentication failed.';
        return LoginResponse.failure(
          message,
          errorType: AuthErrorType.unknown,
        );
      }
    } on SocketException {
      if (ApiConfig.enableMockFallbackWhenOffline) {
        return _handleMultiUserMockLogin(request);
      }
      return LoginResponse.failure(
        'Unable to connect to the server. Please check your internet connection.',
        errorType: AuthErrorType.noInternet,
      );
    } on TimeoutException {
      return LoginResponse.failure(
        'Connection timed out. Please try again.',
        errorType: AuthErrorType.timeout,
      );
    } on FormatException {
      return LoginResponse.failure(
        'Invalid response received from server.',
        errorType: AuthErrorType.invalidResponse,
      );
    } catch (_) {
      if (ApiConfig.enableMockFallbackWhenOffline) {
        return _handleMultiUserMockLogin(request);
      }
      return LoginResponse.failure(
        'Unable to connect to the server. Please check your internet connection.',
        errorType: AuthErrorType.noInternet,
      );
    }
  }

  /// Registers a new user account via POST /api/auth/register
  Future<RegisterResponse> register(RegisterRequest request) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
    final requestPayload = jsonEncode(request.toJson());

    try {
      final httpRequest = await _client.postUrl(url).timeout(ApiConfig.connectTimeout);

      ApiConfig.defaultHeaders().forEach((key, value) {
        httpRequest.headers.set(key, value);
      });

      httpRequest.write(requestPayload);
      final response = await httpRequest.close().timeout(ApiConfig.receiveTimeout);

      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return RegisterResponse.fromJson(json);
      } else if (response.statusCode == 409 ||
          (response.statusCode == 400 &&
              (json['message']?.toString().toLowerCase().contains('already exists') ?? false))) {
        final message = json['message'] as String? ?? 'An account with this email already exists. Please login.';
        return RegisterResponse.duplicateEmail(message);
      } else {
        final message = json['message'] as String? ?? 'Registration failed. Please try again.';
        return RegisterResponse.failure(message);
      }
    } on SocketException {
      if (ApiConfig.enableMockFallbackWhenOffline) {
        return _handleMultiUserMockRegister(request);
      }
      return RegisterResponse.failure(
        'Unable to connect to the server. Please check your internet connection.',
        errorType: AuthErrorType.noInternet,
      );
    } on TimeoutException {
      return RegisterResponse.failure(
        'Connection timed out. Please try again.',
        errorType: AuthErrorType.timeout,
      );
    } catch (_) {
      if (ApiConfig.enableMockFallbackWhenOffline) {
        return _handleMultiUserMockRegister(request);
      }
      return RegisterResponse.failure(
        'Unable to connect to the server. Please check your internet connection.',
        errorType: AuthErrorType.noInternet,
      );
    }
  }

  /// Requests password reset from backend API via POST /api/auth/forgot-password
  Future<ForgotPasswordResponse> requestPasswordReset(String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.forgotPasswordEndpoint}');
    final requestBody = jsonEncode(ForgotPasswordRequest(email: email).toJson());

    try {
      final request = await _client.postUrl(url).timeout(ApiConfig.connectTimeout);

      ApiConfig.defaultHeaders().forEach((key, value) {
        request.headers.set(key, value);
      });

      request.write(requestBody);
      final response = await request.close().timeout(ApiConfig.receiveTimeout);

      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ForgotPasswordResponse.fromJson(json);
      } else {
        final message = json['message'] as String? ?? 'Failed to send password reset request';
        return ForgotPasswordResponse.failure(message);
      }
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 600));
      return ForgotPasswordResponse.mockSuccess(email);
    }
  }

  // =========================================================================
  // MULTI-USER LOCAL REGISTRY FALLBACK
  // Provides true multi-user isolation even when local dev server is offline
  // =========================================================================

  Future<Map<String, dynamic>> _loadOfflineRegistry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userRegistryKey);
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  Future<void> _saveOfflineRegistry(Map<String, dynamic> registry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userRegistryKey, jsonEncode(registry));
    } catch (_) {}
  }

  String _hashPassword(String password) {
    // Salted simple hash representation for offline multi-user verification
    final bytes = utf8.encode('salt_jv_2026_$password');
    var hash = 0xcbf29ce484222325;
    for (var b in bytes) {
      hash ^= b;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  Future<RegisterResponse> _handleMultiUserMockRegister(RegisterRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final email = request.email.trim().toLowerCase();
    final registry = await _loadOfflineRegistry();

    // Prevent duplicate email registration
    if (registry.containsKey(email)) {
      return RegisterResponse.duplicateEmail(
        'An account with this email already exists. Please login.',
      );
    }

    final userId = 'usr_${email.hashCode.abs()}_${DateTime.now().millisecondsSinceEpoch}';
    final token = 'jwt_${userId}_auth_${DateTime.now().millisecondsSinceEpoch}';

    final user = AuthUser(
      id: userId,
      name: request.name.trim(),
      email: email,
      phone: request.mobile,
      language: request.language,
      education: 'Graduate Degree',
      skills: ['Communication', 'Computer Fundamentals'],
      locations: ['Hyderabad', 'Bengaluru', 'Remote'],
    );

    // Store in persistent user registry
    registry[email] = {
      'id': userId,
      'name': request.name.trim(),
      'email': email,
      'passwordHash': _hashPassword(request.password),
      'phone': request.mobile,
      'language': request.language,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _saveOfflineRegistry(registry);

    return RegisterResponse(
      success: true,
      message: 'Account created successfully',
      token: token,
      user: user,
    );
  }

  Future<LoginResponse> _handleMultiUserMockLogin(LoginRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final email = request.email.trim().toLowerCase();
    final password = request.password;
    final registry = await _loadOfflineRegistry();

    if (registry.containsKey(email)) {
      final record = registry[email] as Map<String, dynamic>;
      final expectedHash = record['passwordHash'] as String?;

      if (expectedHash == _hashPassword(password)) {
        final userId = record['id'] as String? ?? 'usr_${email.hashCode.abs()}';
        final token = 'jwt_${userId}_auth_${DateTime.now().millisecondsSinceEpoch}';
        final user = AuthUser(
          id: userId,
          name: record['name'] as String? ?? 'Candidate',
          email: email,
          phone: record['phone'] as String?,
          language: record['language'] as String? ?? 'en',
          education: record['education'] as String? ?? 'B.Tech / Degree',
          skills: ['Flutter', 'Python', 'Dart', 'Problem Solving'],
          locations: ['Hyderabad', 'Bengaluru', 'Delhi NCR'],
        );

        return LoginResponse(
          success: true,
          message: 'Login successful',
          token: token,
          user: user,
        );
      } else {
        return LoginResponse.failure(
          'Incorrect email or password.',
          errorType: AuthErrorType.invalidCredentials,
        );
      }
    }

    // Default demo account support
    if (email == 'mowli@jobvaani.in' && password == 'Password@123') {
      return LoginResponse.mockSuccess(email, name: 'Mowli Kumar');
    }

    // If user is neither in registry nor demo
    return LoginResponse.failure(
      'No account found with this email address.',
      errorType: AuthErrorType.userNotFound,
    );
  }

  void dispose() {
    _client.close(force: true);
  }
}
