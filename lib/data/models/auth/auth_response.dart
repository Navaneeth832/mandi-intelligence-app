import 'user_profile.dart';

class AuthResponse {
  final String? accessToken;
  final String? tokenType;
  final UserProfile user;

  AuthResponse({
    this.accessToken,
    this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: UserProfile.fromJson(json['user'] ?? json),
    );
  }
}

class SendOtpResponse {
  final String identifier;
  final String registrationMethod;

  SendOtpResponse({
    required this.identifier,
    required this.registrationMethod,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      identifier: (json['identifier'] ?? '').toString(),
      registrationMethod: (json['registration_method'] ?? '').toString(),
    );
  }
}

class VerifyOtpResponse {
  final String verificationToken;
  final String tokenType;
  final int expiresInSeconds;

  VerifyOtpResponse({
    required this.verificationToken,
    required this.tokenType,
    required this.expiresInSeconds,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      verificationToken: (json['verification_token'] ?? '').toString(),
      tokenType: (json['token_type'] ?? '').toString(),
      expiresInSeconds: (json['expires_in_seconds'] as int?) ?? 0,
    );
  }
}
