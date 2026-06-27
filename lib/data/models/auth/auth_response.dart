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
