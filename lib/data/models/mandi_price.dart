class MandiPrice {
  final String commodity;
  final String variety;
  final String market;
  final String district;
  final String state;

  final int modalPrice;
  final int highPrice;
  final int lowPrice;

  final DateTime lastUpdated;

  final double priceChange;

  MandiPrice({
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

      modalPrice: json['modal_price'],
      highPrice: json['max_price'],
      lowPrice: json['min_price'],

      // Backend doesn't provide this yet
      priceChange: 0.0,

      lastUpdated: DateTime.parse(
        json['arrival_date'],
      ),
    );
  }
}