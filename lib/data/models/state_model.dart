class StateModel {
  final int id;
  final String name;
  final List<StateTranslation>? translations;

  StateModel({
    required this.id,
    required this.name,
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

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      name: json['name'],
      translations: (json['translations'] as List?)
          ?.map((t) => StateTranslation.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'translations': translations?.map((t) => t.toJson()).toList(),
    };
  }
}

class StateTranslation {
  final int id;
  final int stateId;
  final String languageCode;
  final String translatedName;

  StateTranslation({
    required this.id,
    required this.stateId,
    required this.languageCode,
    required this.translatedName,
  });

  factory StateTranslation.fromJson(Map<String, dynamic> json) {
    return StateTranslation(
      id: json['id'],
      stateId: json['state_id'],
      languageCode: json['language_code'],
      translatedName: json['translated_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state_id': stateId,
      'language_code': languageCode,
      'translated_name': translatedName,
    };
  }
}