import '../../services/auth_api_service.dart';
import '../models/auth_models.dart';

abstract class IAuthRepository {
  Future<ForgotPasswordResponse> sendPasswordReset(String email);
}

class AuthRepository implements IAuthRepository {
  final AuthApiService _apiService;

  AuthRepository({AuthApiService? apiService}) : _apiService = apiService ?? AuthApiService();

  @override
  Future<ForgotPasswordResponse> sendPasswordReset(String email) {
    return _apiService.requestPasswordReset(email);
  }
}
