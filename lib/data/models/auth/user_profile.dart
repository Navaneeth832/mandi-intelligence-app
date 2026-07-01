class UserProfile {
  final String id;
  final String name;
  final String email;
  final int? stateId;
  final int? districtId;
  final String preferredLanguage;
  final bool? profileComplete;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.stateId,
    this.districtId,
    required this.preferredLanguage,
    this.profileComplete,
  });

  static String _normalizeLanguageCode(String? value) {
    switch (value) {
      case 'en':
      case 'English':
      case 'english':
        return 'en';
      case 'ml':
      case 'Malayalam':
      case 'മലയാളം':
        return 'ml';
      case 'hi':
      case 'Hindi':
      case 'हिंदी':
        return 'hi';
      default:
        return 'en';
    }
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      stateId: json['state_id'],
      districtId: json['district_id'],
      preferredLanguage: _normalizeLanguageCode(json['preferred_language']),
      profileComplete: json['is_profile_complete'],
    );
  }

  bool get hasCompletedProfile {
    return profileComplete ?? (stateId != null && districtId != null);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'state_id': stateId,
      'district_id': districtId,
      'preferred_language': preferredLanguage,
      'is_profile_complete': profileComplete,
    };
  }
}
