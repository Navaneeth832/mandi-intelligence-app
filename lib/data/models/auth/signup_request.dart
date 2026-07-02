class SignupRequest {
  final String name;
  final String identifier;
  final String password;
  final String verificationToken;

  SignupRequest({
    required this.name,
    required this.identifier,
    required this.password,
    required this.verificationToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'identifier': identifier,
      'password': password,
      'verification_token': verificationToken,
    };
  }
}
