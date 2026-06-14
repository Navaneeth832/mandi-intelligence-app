class PriceHistory {
  final DateTime date;
  final double modalPrice;

  PriceHistory({
    required this.date,
    required this.modalPrice,
  });

  factory PriceHistory.fromJson(
    Map<String, dynamic> json,
  ) {
    return PriceHistory(
      date: DateTime.parse(
        json['arrival_date'],
      ),
      modalPrice:
          (json['modal_price'] as num)
              .toDouble(),
    );
  }
}