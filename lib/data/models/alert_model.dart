class AlertCommodity {
  final int id;
  final String name;

  const AlertCommodity({
    required this.id,
    required this.name,
  });

  factory AlertCommodity.fromJson(Map<String, dynamic> json) {
    return AlertCommodity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class AlertMarket {
  final int id;
  final String name;

  const AlertMarket({
    required this.id,
    required this.name,
  });

  factory AlertMarket.fromJson(Map<String, dynamic> json) {
    return AlertMarket(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class AlertPrice {
  final double current;
  final double? previous;
  final double? changePercent;

  const AlertPrice({
    required this.current,
    this.previous,
    this.changePercent,
  });

  factory AlertPrice.fromJson(Map<String, dynamic> json) {
    return AlertPrice(
      current: (json['current'] as num).toDouble(),
      previous: json['previous'] != null ? (json['previous'] as num).toDouble() : null,
      changePercent: json['change_percent'] != null ? (json['change_percent'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'previous': previous,
      'change_percent': changePercent,
    };
  }
}

class AlertTypes {
  static const String priceIncrease = 'PRICE_INCREASE';
  static const String priceDrop = 'PRICE_DROP';
  static const String betterMarket = 'BETTER_MARKET';
  static const String aiRecommendation = 'AI_RECOMMENDATION';

  static const List<String> values = [
    betterMarket,
    priceIncrease,
    priceDrop,
    aiRecommendation,
  ];
}

class Alert {
  final int id;
  final String type;
  final String severity;
  final String title;
  final String message;
  final AlertCommodity commodity;
  final AlertMarket market;
  final AlertPrice? price;
  final DateTime createdAt;

  const Alert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.commodity,
    required this.market,
    this.price,
    required this.createdAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String? ?? '',
      severity: json['severity'] as String? ?? 'MEDIUM',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      commodity: AlertCommodity.fromJson(json['commodity'] as Map<String, dynamic>),
      market: AlertMarket.fromJson(json['market'] as Map<String, dynamic>),
      price: json['price'] != null ? AlertPrice.fromJson(json['price'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'title': title,
      'message': message,
      'commodity': commodity.toJson(),
      'market': market.toJson(),
      'price': price?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PaginatedAlertsResponse {
  final List<Alert> items;
  final int page;
  final int pageSize;
  final int total;

  const PaginatedAlertsResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  bool get hasNextPage => page * pageSize < total;

  factory PaginatedAlertsResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((item) => Alert.fromJson(item as Map<String, dynamic>))
        .where((alert) => alert.type != 'MARKET_GLUT') // Defensive exclusion
        .toList();

    return PaginatedAlertsResponse(
      items: itemsList,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? itemsList.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'page': page,
      'page_size': pageSize,
      'total': total,
    };
  }
}
