class CommodityForecast {
  final int commodityId;
  final String commodityName; // Display name
  final String predictionDate;
  final String predictionTime;
  final double currentPrice;
  final List<ForecastDay> forecast;
  final String trend; // e.g., "RISING", "FALLING", "STABLE"
  final String bestSellDate;
  final double expectedPeakPrice;
  final String recommendation; // e.g., "WAIT", "SELL TODAY", "HOLD"

  CommodityForecast({
    required this.commodityId,
    required this.commodityName,
    required this.predictionDate,
    required this.predictionTime,
    required this.currentPrice,
    required this.forecast,
    required this.trend,
    required this.bestSellDate,
    required this.expectedPeakPrice,
    required this.recommendation,
  });

  CommodityForecast copyWith({
    int? commodityId,
    String? commodityName,
    String? predictionDate,
    String? predictionTime,
    double? currentPrice,
    List<ForecastDay>? forecast,
    String? trend,
    String? bestSellDate,
    double? expectedPeakPrice,
    String? recommendation,
  }) {
    return CommodityForecast(
      commodityId: commodityId ?? this.commodityId,
      commodityName: commodityName ?? this.commodityName,
      predictionDate: predictionDate ?? this.predictionDate,
      predictionTime: predictionTime ?? this.predictionTime,
      currentPrice: currentPrice ?? this.currentPrice,
      forecast: forecast ?? this.forecast,
      trend: trend ?? this.trend,
      bestSellDate: bestSellDate ?? this.bestSellDate,
      expectedPeakPrice: expectedPeakPrice ?? this.expectedPeakPrice,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  factory CommodityForecast.fromJson(Map<String, dynamic> json) {
    return CommodityForecast(
      commodityId: json['commodity_id'] as int,
      commodityName: (json['commodity_name'] as String?) ?? '',
      predictionDate: json['prediction_date'] as String,
      predictionTime: json['prediction_time'] as String,
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
      'commodity_id': commodityId,
      'commodity_name': commodityName,
      'prediction_date': predictionDate,
      'prediction_time': predictionTime,
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
