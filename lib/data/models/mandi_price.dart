/// Model representing a Mandi price entry.
class MandiPrice {
  final String commodity;
  final String market;
  final String district;
  final String state;
  final String variety;
  final double minPrice;
  final double modalPrice;
  final double maxPrice;
  final DateTime arrivalDate;

  MandiPrice({
    required this.commodity,
    required this.market,
    required this.district,
    required this.state,
    required this.variety,
    required this.minPrice,
    required this.modalPrice,
    required this.maxPrice,
    required this.arrivalDate,
  });

  factory MandiPrice.fromJson(Map<String, dynamic> json) {
    return MandiPrice(
      commodity: json['commodity'],
      market: json['market'],
      district: json['district'],
      state: json['state'],
      variety: json['variety'],
      minPrice: (json['min_price'] as num).toDouble(),
      modalPrice: (json['modal_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
      arrivalDate: DateTime.parse(json['arrival_date']),
    );
  }
}
