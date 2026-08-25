class MandiPrice {
  final String commodity;
  final String? translatedName;
  final String variety;
  final String grade;
  final String market;
  final String district;
  final String state;

  final double modalPrice;
  final double highPrice;
  final double lowPrice;

  final DateTime lastUpdated;
  final DateTime createdAt;

  final double priceChange;
  final int? commodityId;
  final int? marketId;
  final String? commodityImageUrl;

  MandiPrice({
    this.commodityId,
    this.marketId,
    this.commodityImageUrl,
    required this.commodity,
    this.translatedName,
    required this.variety,
    required this.grade,
    required this.market,
    required this.district,
    required this.state,
    required this.modalPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.priceChange,
    required this.lastUpdated,
    required this.createdAt,
  });

  /// Get the display name based on whether translation is available
  String getDisplayCommodity() {
    return translatedName ?? commodity;
  }

  factory MandiPrice.fromJson(Map<String, dynamic> json) {
    return MandiPrice(
      commodity: json['commodity'],
      translatedName: json['translated_name'] as String?,
      variety: json['variety'],
      grade: json['grade'] ?? '',
      market: json['market'],
      district: json['district'],
      state: json['state'],
      commodityId: json['commodity_id'] as int?,
      marketId: json['market_id'] as int?,
      commodityImageUrl: json['commodity_image_url'] as String?,
      modalPrice: (json['modal_price'] as num).toDouble(),
      highPrice: (json['max_price'] as num).toDouble(),
      lowPrice: (json['min_price'] as num).toDouble(),

      // Backend doesn't provide this yet
      priceChange: 0.0,

      lastUpdated: DateTime.parse(
        json['arrival_date'],
      ),
      createdAt: DateTime.parse(
        json['created_at'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commodity': commodity,
      'translated_name': translatedName,
      'variety': variety,
      'grade': grade,
      'market': market,
      'district': district,
      'state': state,
      'commodity_id': commodityId,
      'market_id': marketId,
      'commodity_image_url': commodityImageUrl,
      'modal_price': modalPrice,
      'max_price': highPrice,
      'min_price': lowPrice,
      'arrival_date': lastUpdated.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}