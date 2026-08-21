class CommodityForecast {
  final int commodityId;
  final String commodityName; // Display name
  final String? commodityImageUrl;
  final int marketId;
  final String marketName;
  final int districtId;
  final String districtName;
  final int stateId;
  final String stateName;
  final int varietyId;
  final String varietyName;
  final int gradeId;
  final String gradeName;
  final String predictionDate;
  final String predictionTime;
  final double currentPrice;
  final List<ForecastDay> forecast;
  final String trend; // e.g., "RISING", "FALLING", "STABLE"
  final String bestSellDate;
  final double expectedPeakPrice;
  final String recommendation; // e.g., "WAIT", "SELL TODAY", "HOLD"
  final double transportCost;
  final double marketFee;
  final double expectedProfit;
  final String recommendationReason;
  final String aiRecommendationTitle;

  CommodityForecast({
    required this.commodityId,
    required this.commodityName,
    this.commodityImageUrl,
    required this.marketId,
    required this.marketName,
    required this.districtId,
    required this.districtName,
    required this.stateId,
    required this.stateName,
    required this.varietyId,
    required this.varietyName,
    required this.gradeId,
    required this.gradeName,
    required this.predictionDate,
    required this.predictionTime,
    required this.currentPrice,
    required this.forecast,
    required this.trend,
    required this.bestSellDate,
    required this.expectedPeakPrice,
    required this.recommendation,
    this.transportCost = 150.0,
    this.marketFee = 45.0,
    this.expectedProfit = 480.0,
    this.recommendationReason = 'Peak mandi prices expected in 3 days with strong market demand.',
    this.aiRecommendationTitle = 'Optimal Profit Window',
  });

  CommodityForecast copyWith({
    int? commodityId,
    String? commodityName,
    String? commodityImageUrl,
    int? marketId,
    String? marketName,
    int? districtId,
    String? districtName,
    int? stateId,
    String? stateName,
    int? varietyId,
    String? varietyName,
    int? gradeId,
    String? gradeName,
    String? predictionDate,
    String? predictionTime,
    double? currentPrice,
    List<ForecastDay>? forecast,
    String? trend,
    String? bestSellDate,
    double? expectedPeakPrice,
    String? recommendation,
    double? transportCost,
    double? marketFee,
    double? expectedProfit,
    String? recommendationReason,
    String? aiRecommendationTitle,
  }) {
    return CommodityForecast(
      commodityId: commodityId ?? this.commodityId,
      commodityName: commodityName ?? this.commodityName,
      commodityImageUrl: commodityImageUrl ?? this.commodityImageUrl,
      marketId: marketId ?? this.marketId,
      marketName: marketName ?? this.marketName,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      stateId: stateId ?? this.stateId,
      stateName: stateName ?? this.stateName,
      varietyId: varietyId ?? this.varietyId,
      varietyName: varietyName ?? this.varietyName,
      gradeId: gradeId ?? this.gradeId,
      gradeName: gradeName ?? this.gradeName,
      predictionDate: predictionDate ?? this.predictionDate,
      predictionTime: predictionTime ?? this.predictionTime,
      currentPrice: currentPrice ?? this.currentPrice,
      forecast: forecast ?? this.forecast,
      trend: trend ?? this.trend,
      bestSellDate: bestSellDate ?? this.bestSellDate,
      expectedPeakPrice: expectedPeakPrice ?? this.expectedPeakPrice,
      recommendation: recommendation ?? this.recommendation,
      transportCost: transportCost ?? this.transportCost,
      marketFee: marketFee ?? this.marketFee,
      expectedProfit: expectedProfit ?? this.expectedProfit,
      recommendationReason: recommendationReason ?? this.recommendationReason,
      aiRecommendationTitle: aiRecommendationTitle ?? this.aiRecommendationTitle,
    );
  }

  factory CommodityForecast.fromJson(Map<String, dynamic> json) {
    return CommodityForecast(
      commodityId: json['commodity_id'] as int,
      commodityName: (json['commodity_name'] as String?) ?? '',
      commodityImageUrl: json['commodity_image_url'] as String?,
      marketId: json['market_id'] as int? ?? 0,
      marketName: (json['market_name'] as String?) ?? '',
      districtId: json['district_id'] as int? ?? 0,
      districtName: (json['district_name'] as String?) ?? '',
      stateId: json['state_id'] as int? ?? 0,
      stateName: (json['state_name'] as String?) ?? '',
      varietyId: json['variety_id'] as int? ?? 0,
      varietyName: (json['variety_name'] as String?) ?? '',
      gradeId: json['grade_id'] as int? ?? 0,
      gradeName: (json['grade_name'] as String?) ?? '',
      predictionDate: (json['prediction_date'] as String?) ?? '',
      predictionTime: (json['prediction_time'] as String?) ?? '',
      currentPrice: (json['current_price'] as num).toDouble(),
      forecast: (json['forecast'] as List<dynamic>?)
              ?.map((item) => ForecastDay.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      trend: (json['trend'] as String?) ?? 'STABLE',
      bestSellDate: (json['best_sell_date'] as String?) ?? '',
      expectedPeakPrice: (json['expected_peak_price'] as num).toDouble(),
      recommendation: (json['recommendation'] as String?) ?? 'HOLD',
      transportCost: (json['transport_cost'] as num?)?.toDouble() ?? 150.0,
      marketFee: (json['market_fee'] as num?)?.toDouble() ?? 45.0,
      expectedProfit: (json['expected_profit'] as num?)?.toDouble() ?? 480.0,
      recommendationReason: (json['recommendation_reason'] as String?) ??
          'Peak mandi prices expected in 3 days with strong market demand.',
      aiRecommendationTitle: (json['ai_recommendation_title'] as String?) ??
          'Optimal Profit Window',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commodity_id': commodityId,
      'commodity_name': commodityName,
      'commodity_image_url': commodityImageUrl,
      'market_id': marketId,
      'market_name': marketName,
      'district_id': districtId,
      'district_name': districtName,
      'state_id': stateId,
      'state_name': stateName,
      'variety_id': varietyId,
      'variety_name': varietyName,
      'grade_id': gradeId,
      'grade_name': gradeName,
      'prediction_date': predictionDate,
      'prediction_time': predictionTime,
      'current_price': currentPrice,
      'forecast': forecast.map((f) => f.toJson()).toList(),
      'trend': trend,
      'best_sell_date': bestSellDate,
      'expected_peak_price': expectedPeakPrice,
      'recommendation': recommendation,
      'transport_cost': transportCost,
      'market_fee': marketFee,
      'expected_profit': expectedProfit,
      'recommendation_reason': recommendationReason,
      'ai_recommendation_title': aiRecommendationTitle,
    };
  }
}

class BestMarket {
  final int marketId;
  final String marketName;
  final int districtId;
  final String districtName;
  final int stateId;
  final String stateName;
  final int varietyId;
  final String varietyName;
  final int gradeId;
  final String gradeName;
  final double predictedPrice;
  final double currentPrice;
  final String trend;
  final String recommendation;

  BestMarket({
    required this.marketId,
    required this.marketName,
    required this.districtId,
    required this.districtName,
    required this.stateId,
    required this.stateName,
    required this.varietyId,
    required this.varietyName,
    required this.gradeId,
    required this.gradeName,
    required this.predictedPrice,
    required this.currentPrice,
    required this.trend,
    required this.recommendation,
  });

  factory BestMarket.fromJson(Map<String, dynamic> json) {
    return BestMarket(
      marketId: json['market_id'] as int? ?? 0,
      marketName: (json['market_name'] as String?) ?? '',
      districtId: json['district_id'] as int? ?? 0,
      districtName: (json['district_name'] as String?) ?? '',
      stateId: json['state_id'] as int? ?? 0,
      stateName: (json['state_name'] as String?) ?? '',
      varietyId: json['variety_id'] as int? ?? 0,
      varietyName: (json['variety_name'] as String?) ?? '',
      gradeId: json['grade_id'] as int? ?? 0,
      gradeName: (json['grade_name'] as String?) ?? '',
      predictedPrice: (json['predicted_price'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      trend: (json['trend'] as String?) ?? 'STABLE',
      recommendation: (json['recommendation'] as String?) ?? 'HOLD',
    );
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

class PaginatedForecastResponse {
  final int page;
  final int pageSize;
  final int total;
  final bool hasNext;
  final List<CommodityForecast> predictions;

  PaginatedForecastResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasNext,
    required this.predictions,
  });

  factory PaginatedForecastResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedForecastResponse(
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
      hasNext: json['has_next'] as bool? ?? false,
      predictions: (json['predictions'] as List<dynamic>?)
              ?.map((item) => CommodityForecast.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
