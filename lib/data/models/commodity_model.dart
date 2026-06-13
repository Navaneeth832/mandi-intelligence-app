class Commodity {
  final int id;
  final String name;

  Commodity({
    required this.id,
    required this.name,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'],
      name: json['name'],
    );
  }
}