enum AuthErrorType {
  none,
  invalidCredentials,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  serverUnavailable,
  noInternet,
  timeout,
  invalidResponse,
  unknown,
}

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String language;
  final String? education;
  final List<String>? skills;
  final List<String>? locations;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.language = 'en',
    this.education,
    this.skills,
    this.locations,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Candidate',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['mobile'] as String?,
      language: json['language'] as String? ?? 'en',
      education: json['education'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      locations: (json['locations'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        'language': language,
        if (education != null) 'education': education,
        if (skills != null) 'skills': skills,
        if (locations != null) 'locations': locations,
      };
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'password': password,
      };
}

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final AuthUser? user;
  final AuthErrorType errorType;

  const LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.errorType = AuthErrorType.none,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String? ?? (success ? 'Login successful' : 'Login failed');
    final token = json['token'] as String?;
    final userData = json['user'] as Map<String, dynamic>?;

    return LoginResponse(
      success: success,
      message: message,
      token: token,
      user: userData != null ? AuthUser.fromJson(userData) : null,
      errorType: success ? AuthErrorType.none : AuthErrorType.invalidCredentials,
    );
  }

  factory LoginResponse.failure(
    String message, {
    AuthErrorType errorType = AuthErrorType.invalidCredentials,
  }) {
    return LoginResponse(
      success: false,
      message: message,
      errorType: errorType,
    );
  }

  factory LoginResponse.mockSuccess(String email, {String? name, String language = 'en'}) {
    final displayName = name ??
        (email.contains('@')
            ? email.split('@').first.replaceAll('.', ' ')
            : 'Candidate');
    final formattedName = displayName.isNotEmpty
        ? displayName[0].toUpperCase() + displayName.substring(1)
        : 'Candidate';

    return LoginResponse(
      success: true,
      message: 'Login successful',
      token: 'jwt_sec_tok_${email.hashCode.abs()}_${DateTime.now().millisecondsSinceEpoch}',
      user: AuthUser(
        id: 'usr_${email.hashCode.abs()}',
        name: formattedName,
        email: email.trim().toLowerCase(),
        language: language,
        phone: '+91 98765 43210',
        education: 'B.Tech in Computer Science & Engineering',
        skills: ['Flutter', 'Dart', 'Python', 'Cybersecurity', 'Cloud / AWS', 'SQL', 'Linux'],
        locations: ['Bengaluru', 'Hyderabad', 'Remote', 'Delhi NCR'],
      ),
      errorType: AuthErrorType.none,
    );
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? mobile;
  final String language;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.mobile,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        if (mobile != null && mobile!.isNotEmpty) 'mobile': mobile!.trim(),
        'language': language,
      };
}

class RegisterResponse {
  final bool success;
  final String message;
  final String? token;
  final AuthUser? user;
  final AuthErrorType errorType;

  const RegisterResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.errorType = AuthErrorType.none,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String? ?? (success ? 'Account created successfully' : 'Registration failed');
    final token = json['token'] as String?;
    final userData = json['user'] as Map<String, dynamic>?;

    return RegisterResponse(
      success: success,
      message: message,
      token: token,
      user: userData != null ? AuthUser.fromJson(userData) : null,
      errorType: success ? AuthErrorType.none : AuthErrorType.unknown,
    );
  }

  factory RegisterResponse.failure(
    String message, {
    AuthErrorType errorType = AuthErrorType.unknown,
  }) {
    return RegisterResponse(
      success: false,
      message: message,
      errorType: errorType,
    );
  }

  factory RegisterResponse.duplicateEmail([String? message]) {
    return RegisterResponse(
      success: false,
      message: message ?? 'An account with this email already exists. Please login.',
      errorType: AuthErrorType.emailAlreadyInUse,
    );
  }
}

class AuthResult {
  final bool isSuccess;
  final String? token;
  final AuthUser? user;
  final String? errorMessage;
  final AuthErrorType errorType;

  const AuthResult({
    required this.isSuccess,
    this.token,
    this.user,
    this.errorMessage,
    this.errorType = AuthErrorType.none,
  });

  factory AuthResult.success(String token, AuthUser user, {String? message}) {
    return AuthResult(
      isSuccess: true,
      token: token,
      user: user,
      errorMessage: message,
      errorType: AuthErrorType.none,
    );
  }

  factory AuthResult.failure(
    String errorMessage, {
    AuthErrorType errorType = AuthErrorType.invalidCredentials,
  }) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
      errorType: errorType,
    );
  }
}

class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email.trim().toLowerCase()};
}

class ForgotPasswordResponse {
  final bool success;
  final String message;
  final String? resetToken;
  final int? expiresInMinutes;

  const ForgotPasswordResponse({
    required this.success,
    required this.message,
    this.resetToken,
    this.expiresInMinutes,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      resetToken: json['resetToken'] as String?,
      expiresInMinutes: json['expiresInMinutes'] as int? ?? 15,
    );
  }

  factory ForgotPasswordResponse.mockSuccess(String email) {
    return ForgotPasswordResponse(
      success: true,
      message: 'Password reset link sent to $email',
      resetToken: 'reset_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresInMinutes: 15,
    );
  }

  factory ForgotPasswordResponse.failure(String message) {
    return ForgotPasswordResponse(
      success: false,
      message: message,
    );
  }
}

class ResetPasswordRequest {
  final String email;
  final String resetToken;
  final String newPassword;

  const ResetPasswordRequest({
    required this.email,
    required this.resetToken,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'resetToken': resetToken,
        'newPassword': newPassword,
      };
}
