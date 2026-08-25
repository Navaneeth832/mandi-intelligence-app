class District {
  final int id;
  final String name;
  final int stateId;
  final List<DistrictTranslation>? translations;

  District({
    required this.id,
    required this.name,
    required this.stateId,
    this.translations,
  });

  /// Get translated name for a specific language code
  String? getTranslation(String languageCode) {
    if (translations == null) return null;
    try {
      return translations!
          .firstWhere((t) => t.languageCode == languageCode)
          .translatedName;
    } catch (e) {
      return null;
    }
  }

  /// Get the display name based on language code
  /// Returns translated name if available, otherwise returns English name
  String getDisplayName(String languageCode) {
    final translation = getTranslation(languageCode);
    return translation ?? name;
  }

  factory District.fromJson(
    Map<String, dynamic> json,
  ) {
    return District(
      id: json['id'],
      name: json['name'],
      stateId: json['state_id'] ?? 0,
      translations: (json['translations'] as List?)
          ?.map((t) => DistrictTranslation.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state_id': stateId,
      'translations': translations?.map((t) => t.toJson()).toList(),
    };
  }
}

class DistrictTranslation {
  final int id;
  final int districtId;
  final String languageCode;
  final String translatedName;

  DistrictTranslation({
    required this.id,
    required this.districtId,
    required this.languageCode,
    required this.translatedName,
  });

  factory DistrictTranslation.fromJson(Map<String, dynamic> json) {
    return DistrictTranslation(
      id: json['id'],
      districtId: json['district_id'],
      languageCode: json['language_code'],
      translatedName: json['translated_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'district_id': districtId,
      'language_code': languageCode,
      'translated_name': translatedName,
    };
  }
}