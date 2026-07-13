class CommodityForecast {
  final String commodity;
  final double currentPrice;
  final List<ForecastDay> forecast;
  final String trend; // e.g., "RISING", "FALLING", "STABLE"
  final String bestSellDate;
  final double expectedPeakPrice;
  final String recommendation; // e.g., "WAIT", "SELL TODAY", "HOLD"

  CommodityForecast({
    required this.commodity,
    required this.currentPrice,
    required this.forecast,
    required this.trend,
    required this.bestSellDate,
    required this.expectedPeakPrice,
    required this.recommendation,
  });

  factory CommodityForecast.fromJson(Map<String, dynamic> json) {
    return CommodityForecast(
      commodity: json['commodity'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      forecast: (json['forecast'] as List<dynamic>)
          .map((item) => ForecastDay.fromJson(item as Map<String, dynamic>))
          .toList(),
      trend: json['trend'] as String,
      bestSellDate: json['best_sell_date'] as String,
      expectedPeakPrice: (json['expected_peak_price'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commodity': commodity,
      'current_price': currentPrice,
      'forecast': forecast.map((f) => f.toJson()).toList(),
      'trend': trend,
      'best_sell_date': bestSellDate,
      'expected_peak_price': expectedPeakPrice,
      'recommendation': recommendation,
    };
  }
}

class ForecastDay {
  final String date;
  final double price;

  ForecastDay({
    required this.date,
    required this.price,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'price': price,
    };
  }
}
