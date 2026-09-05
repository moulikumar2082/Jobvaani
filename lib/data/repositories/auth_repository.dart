import '../../services/auth_api_service.dart';
import '../../services/secure_storage_service.dart';
import '../models/auth_models.dart';

abstract class IAuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? mobile,
    String language = 'en',
  });
  Future<ForgotPasswordResponse> sendPasswordReset(String email);
}

class AuthRepository implements IAuthRepository {
  final AuthApiService _apiService;
  final ISecureStorageService _storageService;

  AuthRepository({
    AuthApiService? apiService,
    ISecureStorageService? storageService,
  })  : _apiService = apiService ?? AuthApiService(),
        _storageService = storageService ?? SecureStorageService();

  @override
  Future<AuthResult> login(String email, String password) async {
    final response = await _apiService.login(
      LoginRequest(email: email, password: password),
    );

    if (response.success && response.token != null) {
      // Store token and authenticated user data securely
      await _storageService.saveToken(response.token!);
      if (response.user != null) {
        await _storageService.saveUserData(response.user!.toJson());
      }

      final user = response.user ??
          AuthUser(
            id: 'usr_${email.hashCode.abs()}',
            name: email.contains('@') ? email.split('@').first : 'Candidate',
            email: email,
          );

      return AuthResult.success(
        response.token!,
        user,
        message: response.message,
      );
    } else {
      return AuthResult.failure(
        response.message,
        errorType: response.errorType,
      );
    }
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? mobile,
    String language = 'en',
  }) async {
    final response = await _apiService.register(
      RegisterRequest(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
        language: language,
      ),
    );

    if (response.success && response.token != null) {
      // Store token and user data securely
      await _storageService.saveToken(response.token!);
      if (response.user != null) {
        await _storageService.saveUserData(response.user!.toJson());
      }

      final user = response.user ??
          AuthUser(
            id: 'usr_${email.hashCode.abs()}',
            name: name,
            email: email,
            phone: mobile,
            language: language,
          );

      return AuthResult.success(
        response.token!,
        user,
        message: response.message,
      );
    } else {
      return AuthResult.failure(
        response.message,
        errorType: response.errorType,
      );
    }
  }

  @override
  Future<ForgotPasswordResponse> sendPasswordReset(String email) {
    return _apiService.requestPasswordReset(email);
  }
}
