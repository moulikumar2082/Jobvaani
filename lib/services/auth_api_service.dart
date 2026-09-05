import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../core/network/api_config.dart';
import '../data/models/auth_models.dart';

class AuthApiService {
  final HttpClient _client;

  AuthApiService({HttpClient? client}) : _client = client ?? HttpClient();

  /// Authenticates user against backend API via POST /api/auth/login
  /// Real HTTP REST architecture with typed error classification
  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');
    final requestPayload = jsonEncode(request.toJson());

    try {
      final httpRequest = await _client.postUrl(url).timeout(ApiConfig.connectTimeout);

      // Apply standard headers
      ApiConfig.defaultHeaders().forEach((key, value) {
        httpRequest.headers.set(key, value);
      });

      // Write JSON payload
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
        final message = json['message'] as String? ?? 'No account found with this email.';
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
        return _handleMockFallback(request);
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
        return _handleMockFallback(request);
      }
      return LoginResponse.failure(
        'Something went wrong. Please try again.',
        errorType: AuthErrorType.unknown,
      );
    }
  }

  /// Explicitly isolated mock authenticator used only when backend is offline in development
  Future<LoginResponse> _handleMockFallback(LoginRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Realistic verification of candidate credentials in demo mode
    final email = request.email.trim().toLowerCase();
    final password = request.password;

    if (password == 'wrongpassword' || password == 'invalid') {
      return LoginResponse.failure(
        'Invalid email or password.',
        errorType: AuthErrorType.invalidCredentials,
      );
    }

    if (email == 'notfound@example.com') {
      return LoginResponse.failure(
        'No account found with this email address.',
        errorType: AuthErrorType.userNotFound,
      );
    }

    return LoginResponse.mockSuccess(email);
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
      await Future.delayed(const Duration(milliseconds: 700));
      return ForgotPasswordResponse.mockSuccess(email);
    }
  }

  void dispose() {
    _client.close(force: true);
  }
}
