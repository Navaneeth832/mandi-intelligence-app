class MarketDirectory {
  final int id;
  final String name;
  final String district;
  final String state;

  MarketDirectory({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
  });

  factory MarketDirectory.fromJson(Map<String, dynamic> json) {
    return MarketDirectory(
      id: json['id'],
      name: json['name'],
      district: json['district'],
      state: json['state'],
    );
  }
}
