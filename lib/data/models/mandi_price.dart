class MandiPrice {
  final String commodity;
  final String variety;
  final String market;
  final String district;
  final String state;

  final double modalPrice;
  final double highPrice;
  final double lowPrice;

  final DateTime lastUpdated;

  final double priceChange;
  final int? commodityId;
  final int? marketId;

  MandiPrice({
    this.commodityId,
    this.marketId,
    required this.commodity,
    required this.variety,
    required this.market,
    required this.district,
    required this.state,
    required this.modalPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.priceChange,
    required this.lastUpdated,
  });

  factory MandiPrice.fromJson(Map<String, dynamic> json) {
    return MandiPrice(
      commodity: json['commodity'],
      variety: json['variety'],
      market: json['market'],
      district: json['district'],
      state: json['state'],
      commodityId: json['commodity_id'] as int?,
      marketId: json['market_id'] as int?,

      modalPrice: (json['modal_price'] as num).toDouble(),
      highPrice: (json['max_price'] as num).toDouble(),
      lowPrice: (json['min_price'] as num).toDouble(),

      // Backend doesn't provide this yet
      priceChange: 0.0,

      lastUpdated: DateTime.parse(
        json['arrival_date'],
      ),
    );
  }
}