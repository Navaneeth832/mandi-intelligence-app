class MarketDirectory {
  final int id;
  final String name;
  final String district;
  final String state;
  final List<String> commodities;
  final int commodityCount;
  final int totalRecords;

  MarketDirectory({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    required this.commodities,
    required this.commodityCount,
    required this.totalRecords,
  });

  factory MarketDirectory.fromJson(Map<String, dynamic> json) {
    return MarketDirectory(
      id: json['id'],
      name: json['name'],
      district: json['district'],
      state: json['state'],
      commodities: List<String>.from(json['commodities']),
      commodityCount: json['commodity_count'],
      totalRecords: json['total_records'],
    );
  }
}
