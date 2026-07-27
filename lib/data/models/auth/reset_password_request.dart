class ResetPasswordRequest {
  final String identifier;
  final String verificationToken;
  final String newPassword;

  ResetPasswordRequest({
    required this.identifier,
    required this.verificationToken,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'verification_token': verificationToken,
      'new_password': newPassword,
    };
  }
}
