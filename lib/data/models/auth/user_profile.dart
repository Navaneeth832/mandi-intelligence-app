class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String registrationMethod;
  final bool isVerified;
  final int? stateId;
  final int? districtId;
  final String preferredLanguage;
  final bool? profileComplete;
  final String? stateName;
  final String? districtName;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    required this.registrationMethod,
    required this.isVerified,
    this.stateId,
    this.districtId,
    required this.preferredLanguage,
    this.profileComplete,
    this.stateName,
    this.districtName
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
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      registrationMethod: (json['registration_method'] ?? '').toString(),
      isVerified: json['is_verified'] == true,
      stateId: json['state_id'],
      districtId: json['district_id'],
      preferredLanguage: _normalizeLanguageCode(json['preferred_language']),
      profileComplete: json['is_profile_complete'],
      stateName: json['state_name'],
      districtName: json['district_name']
    );
  }

  String get primaryIdentifier {
    if (registrationMethod == 'phone') {
      return phoneNumber ?? email ?? '';
    }
    return email ?? phoneNumber ?? '';
  }

  bool get hasCompletedProfile {
    return profileComplete ?? (stateId != null && districtId != null);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'registration_method': registrationMethod,
      'is_verified': isVerified,
      'state_id': stateId,
      'district_id': districtId,
      'state_name': stateName,
      'district_name': districtName,
      'preferred_language': preferredLanguage,
      'is_profile_complete': profileComplete,
    };
  }
}
