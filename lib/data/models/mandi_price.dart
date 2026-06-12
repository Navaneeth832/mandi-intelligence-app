class MandiPrice {
  final String commodity;
  final String variety;
  final String market;
  final String district;
  final String state;
  final int modalPrice;
  final int highPrice;
  final int lowPrice;
  final double priceChange;
  final DateTime lastUpdated;

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
}