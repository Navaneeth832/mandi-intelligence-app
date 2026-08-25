class Market {
  final int id;
  final String name;
  final int districtId;
  final List<MarketTranslation>? translations;

  Market({
    required this.id,
    required this.name,
    required this.districtId,
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

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'],
      name: json['name'],
      districtId: json['district_id'] ?? 0,
      translations: (json['translations'] as List?)
          ?.map((t) => MarketTranslation.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district_id': districtId,
      'translations': translations?.map((t) => t.toJson()).toList(),
    };
  }
}

class MarketTranslation {
  final int id;
  final int marketId;
  final String languageCode;
  final String translatedName;

  MarketTranslation({
    required this.id,
    required this.marketId,
    required this.languageCode,
    required this.translatedName,
  });

  factory MarketTranslation.fromJson(Map<String, dynamic> json) {
    return MarketTranslation(
      id: json['id'],
      marketId: json['market_id'],
      languageCode: json['language_code'],
      translatedName: json['translated_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'market_id': marketId,
      'language_code': languageCode,
      'translated_name': translatedName,
    };
  }
}
