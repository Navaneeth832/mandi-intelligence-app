class NotificationPreferences {
  final String? userId;
  final bool priceIncrease;
  final bool priceDrop;
  final bool betterMarket;
  final bool marketGlut;
  final bool aiRecommendation;
  final bool deliveryInApp;
  final bool deliverySms;
  final bool deliveryPush;
  final String frequency;
  final String? createdAt;
  final String? updatedAt;

  const NotificationPreferences({
    this.userId,
    required this.priceIncrease,
    required this.priceDrop,
    required this.betterMarket,
    required this.marketGlut,
    required this.aiRecommendation,
    required this.deliveryInApp,
    required this.deliverySms,
    required this.deliveryPush,
    required this.frequency,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      userId: json['user_id'] as String?,
      priceIncrease: json['price_increase'] as bool? ?? true,
      priceDrop: json['price_drop'] as bool? ?? true,
      betterMarket: json['better_market'] as bool? ?? true,
      marketGlut: json['market_glut'] as bool? ?? true,
      aiRecommendation: json['ai_recommendation'] as bool? ?? true,
      deliveryInApp: json['delivery_in_app'] as bool? ?? true,
      deliverySms: json['delivery_sms'] as bool? ?? false,
      deliveryPush: json['delivery_push'] as bool? ?? false,
      frequency: json['frequency'] as String? ?? 'instant',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price_increase': priceIncrease,
      'price_drop': priceDrop,
      'better_market': betterMarket,
      'market_glut': marketGlut,
      'ai_recommendation': aiRecommendation,
      'delivery_in_app': deliveryInApp,
      'delivery_sms': deliverySms,
      'delivery_push': deliveryPush,
      'frequency': frequency,
    };
  }

  NotificationPreferences copyWith({
    String? userId,
    bool? priceIncrease,
    bool? priceDrop,
    bool? betterMarket,
    bool? marketGlut,
    bool? aiRecommendation,
    bool? deliveryInApp,
    bool? deliverySms,
    bool? deliveryPush,
    String? frequency,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationPreferences(
      userId: userId ?? this.userId,
      priceIncrease: priceIncrease ?? this.priceIncrease,
      priceDrop: priceDrop ?? this.priceDrop,
      betterMarket: betterMarket ?? this.betterMarket,
      marketGlut: marketGlut ?? this.marketGlut,
      aiRecommendation: aiRecommendation ?? this.aiRecommendation,
      deliveryInApp: deliveryInApp ?? this.deliveryInApp,
      deliverySms: deliverySms ?? this.deliverySms,
      deliveryPush: deliveryPush ?? this.deliveryPush,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          priceIncrease == other.priceIncrease &&
          priceDrop == other.priceDrop &&
          betterMarket == other.betterMarket &&
          marketGlut == other.marketGlut &&
          aiRecommendation == other.aiRecommendation &&
          deliveryInApp == other.deliveryInApp &&
          deliverySms == other.deliverySms &&
          deliveryPush == other.deliveryPush &&
          frequency == other.frequency;

  @override
  int get hashCode =>
      priceIncrease.hashCode ^
      priceDrop.hashCode ^
      betterMarket.hashCode ^
      marketGlut.hashCode ^
      aiRecommendation.hashCode ^
      deliveryInApp.hashCode ^
      deliverySms.hashCode ^
      deliveryPush.hashCode ^
      frequency.hashCode;
}
