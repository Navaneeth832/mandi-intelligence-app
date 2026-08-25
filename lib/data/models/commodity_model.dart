class Commodity {
  final int id;
  final String name;
  final String? commodityImageUrl;
  final List<CommodityTranslation>? translations;

  Commodity({
    required this.id,
    required this.name,
    this.commodityImageUrl,
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

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'],
      name: json['name'],
      commodityImageUrl: json['commodity_image_url'] as String?,
      translations: (json['translations'] as List?)
          ?.map((t) => CommodityTranslation.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'commodity_image_url': commodityImageUrl,
      'translations': translations?.map((t) => t.toJson()).toList(),
    };
  }
}

class CommodityTranslation {
  final int id;
  final int commodityId;
  final String languageCode;
  final String translatedName;

  CommodityTranslation({
    required this.id,
    required this.commodityId,
    required this.languageCode,
    required this.translatedName,
  });

  factory CommodityTranslation.fromJson(Map<String, dynamic> json) {
    return CommodityTranslation(
      id: json['id'],
      commodityId: json['commodity_id'],
      languageCode: json['language_code'],
      translatedName: json['translated_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commodity_id': commodityId,
      'language_code': languageCode,
      'translated_name': translatedName,
    };
  }
}