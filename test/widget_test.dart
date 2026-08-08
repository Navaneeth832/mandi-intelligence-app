import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_intelligence_app/data/models/notification_preferences.dart';

void main() {
  test('NotificationPreferences model json parsing and copyWith test', () {
    final json = {
      'user_id': 'test-uuid-123',
      'price_increase': true,
      'price_drop': false,
      'better_market': true,
      'market_glut': false,
      'ai_recommendation': true,
      'delivery_in_app': true,
      'delivery_sms': false,
      'delivery_push': false,
      'frequency': 'instant',
      'created_at': '2026-08-08T12:00:00Z',
      'updated_at': '2026-08-08T12:00:00Z',
    };

    final prefs = NotificationPreferences.fromJson(json);

    expect(prefs.userId, 'test-uuid-123');
    expect(prefs.priceIncrease, isTrue);
    expect(prefs.priceDrop, isFalse);
    expect(prefs.betterMarket, isTrue);
    expect(prefs.marketGlut, isFalse);
    expect(prefs.aiRecommendation, isTrue);
    expect(prefs.deliveryInApp, isTrue);
    expect(prefs.deliverySms, isFalse);
    expect(prefs.deliveryPush, isFalse);
    expect(prefs.frequency, 'instant');

    final updated = prefs.copyWith(priceDrop: true, frequency: 'daily_summary');
    expect(updated.priceDrop, isTrue);
    expect(updated.frequency, 'daily_summary');

    final toJsonOutput = updated.toJson();
    expect(toJsonOutput['price_drop'], isTrue);
    expect(toJsonOutput['frequency'], 'daily_summary');
  });
}
