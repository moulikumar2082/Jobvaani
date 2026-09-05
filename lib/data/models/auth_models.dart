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
