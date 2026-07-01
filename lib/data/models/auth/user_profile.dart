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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      stateId: json['state_id'],
      districtId: json['district_id'],
      preferredLanguage: json['preferred_language'] ?? 'English',
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
