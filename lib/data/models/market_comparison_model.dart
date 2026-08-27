class MarketComparisonItem {
  final int marketId;
  final String marketName;
  final String districtName;
  final String stateName;
  final double? latitude;
  final double? longitude;
  final double distanceKm;
  final double sellingPrice;
  final double transportCost;
  final double mandiCommission;
  final double netProfit;
  final double totalNetProfit;
  final bool isBestValue;

  MarketComparisonItem({
    required this.marketId,
    required this.marketName,
    required this.districtName,
    required this.stateName,
    this.latitude,
    this.longitude,
    required this.distanceKm,
    required this.sellingPrice,
    required this.transportCost,
    required this.mandiCommission,
    required this.netProfit,
    required this.totalNetProfit,
    required this.isBestValue,
  });

  factory MarketComparisonItem.fromJson(Map<String, dynamic> json) {
    return MarketComparisonItem(
      marketId: json['market_id'] as int,
      marketName: json['market_name'] as String? ?? 'Unknown Mandi',
      districtName: json['district_name'] as String? ?? '',
      stateName: json['state_name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      transportCost: (json['transport_cost'] as num?)?.toDouble() ?? 0.0,
      mandiCommission: (json['mandi_commission'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['net_profit'] as num?)?.toDouble() ?? 0.0,
      totalNetProfit: (json['total_net_profit'] as num?)?.toDouble() ?? 0.0,
      isBestValue: json['is_best_value'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'market_id': marketId,
      'market_name': marketName,
      'district_name': districtName,
      'state_name': stateName,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
      'selling_price': sellingPrice,
      'transport_cost': transportCost,
      'mandi_commission': mandiCommission,
      'net_profit': netProfit,
      'total_net_profit': totalNetProfit,
      'is_best_value': isBestValue,
    };
  }
}

class MarketComparisonResponse {
  final double userLatitude;
  final double userLongitude;
  final int? commodityId;
  final double quantityQuintals;
  final double transportRatePerKm;
  final List<MarketComparisonItem> markets;

  MarketComparisonResponse({
    required this.userLatitude,
    required this.userLongitude,
    this.commodityId,
    required this.quantityQuintals,
    required this.transportRatePerKm,
    required this.markets,
  });

  factory MarketComparisonResponse.fromJson(Map<String, dynamic> json) {
    return MarketComparisonResponse(
      userLatitude: (json['user_latitude'] as num?)?.toDouble() ?? 0.0,
      userLongitude: (json['user_longitude'] as num?)?.toDouble() ?? 0.0,
      commodityId: json['commodity_id'] as int?,
      quantityQuintals: (json['quantity_quintals'] as num?)?.toDouble() ?? 10.0,
      transportRatePerKm: (json['transport_rate_per_km'] as num?)?.toDouble() ?? 2.5,
      markets: (json['markets'] as List<dynamic>?)
              ?.map((e) => MarketComparisonItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
