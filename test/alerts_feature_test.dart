import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mandi_intelligence_app/data/models/alert_model.dart';
import 'package:mandi_intelligence_app/data/datasources/alert_fallback_data_source.dart';
import 'package:mandi_intelligence_app/data/services/alert_api_service.dart';
import 'package:mandi_intelligence_app/data/repositories/alert_repository.dart';

class MockSecureStorage extends FlutterSecureStorage {
  const MockSecureStorage();

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return 'fake-jwt-token-123';
  }
}

class FailingApiService extends AlertApiService {
  final int statusCode;
  final String errorMessage;

  FailingApiService({required this.statusCode, required this.errorMessage});

  @override
  Future<PaginatedAlertsResponse> getAlerts({String? type, int page = 1, int pageSize = 20, String? token}) async {
    throw AlertApiException(errorMessage, statusCode: statusCode);
  }

  @override
  Future<PaginatedAlertsResponse> getAlertHistory({String? type, String? search, String? dateFrom, String? dateTo, int page = 1, int pageSize = 20, String? token}) async {
    throw AlertApiException(errorMessage, statusCode: statusCode);
  }
}

void main() {
  group('Alert Model Tests', () {
    test('Parses Alert JSON with valid price correctly', () {
      final json = {
        'id': 101,
        'type': 'PRICE_INCREASE',
        'severity': 'HIGH',
        'title': 'Tomato price increased',
        'message': 'Tomato prices increased by 14% in Thrissur Mandi.',
        'commodity': {'id': 19, 'name': 'Tomato'},
        'market': {'id': 52, 'name': 'Thrissur Mandi'},
        'price': {
          'current': 2800.0,
          'previous': 2450.0,
          'change_percent': 14.29
        },
        'created_at': '2026-08-08T09:30:00+05:30'
      };

      final alert = Alert.fromJson(json);

      expect(alert.id, 101);
      expect(alert.type, AlertTypes.priceIncrease);
      expect(alert.severity, 'HIGH');
      expect(alert.title, 'Tomato price increased');
      expect(alert.message, 'Tomato prices increased by 14% in Thrissur Mandi.');
      expect(alert.commodity.id, 19);
      expect(alert.commodity.name, 'Tomato');
      expect(alert.market.id, 52);
      expect(alert.market.name, 'Thrissur Mandi');
      expect(alert.price, isNotNull);
      expect(alert.price!.current, 2800.0);
      expect(alert.price!.previous, 2450.0);
      expect(alert.price!.changePercent, 14.29);
      expect(alert.createdAt.year, 2026);
    });

    test('Parses Alert JSON with null price correctly (e.g. AI_RECOMMENDATION)', () {
      final json = {
        'id': 103,
        'type': 'AI_RECOMMENDATION',
        'severity': 'HIGH',
        'title': 'Hold Potato sales',
        'message': 'AI models predict price rise for Potato.',
        'commodity': {'id': 15, 'name': 'Potato'},
        'market': {'id': 61, 'name': 'Palakkad Mandi'},
        'price': null,
        'created_at': '2026-08-08T10:00:00+05:30'
      };

      final alert = Alert.fromJson(json);

      expect(alert.id, 103);
      expect(alert.type, AlertTypes.aiRecommendation);
      expect(alert.price, isNull);
    });

    test('PaginatedAlertsResponse parsing excludes MARKET_GLUT defensively', () {
      final json = {
        'items': [
          {
            'id': 1,
            'type': 'PRICE_INCREASE',
            'severity': 'HIGH',
            'title': 'Test Increase',
            'message': 'Message',
            'commodity': {'id': 1, 'name': 'Crop'},
            'market': {'id': 1, 'name': 'Mandi'},
            'price': {'current': 100.0, 'previous': 90.0, 'change_percent': 11.11},
            'created_at': '2026-08-08T10:00:00Z'
          },
          {
            'id': 2,
            'type': 'MARKET_GLUT', // Should be excluded!
            'severity': 'HIGH',
            'title': 'Market Glut Alert',
            'message': 'Glut message',
            'commodity': {'id': 2, 'name': 'Crop2'},
            'market': {'id': 2, 'name': 'Mandi2'},
            'price': null,
            'created_at': '2026-08-08T10:00:00Z'
          }
        ],
        'page': 1,
        'page_size': 20,
        'total': 2
      };

      final response = PaginatedAlertsResponse.fromJson(json);
      expect(response.items.length, 1);
      expect(response.items.first.type, 'PRICE_INCREASE');
      expect(response.items.any((item) => item.type == 'MARKET_GLUT'), isFalse);
    });
  });

  group('Alert Fallback Data Source Tests', () {
    final fallback = AlertFallbackDataSource();

    test('Returns default alerts without MARKET_GLUT', () async {
      final res = await fallback.getAlerts(page: 1, pageSize: 20);
      expect(res.items, isNotEmpty);
      expect(res.items.any((a) => a.type == 'MARKET_GLUT'), isFalse);
    });

    test('Filters alerts by category correctly', () async {
      final res = await fallback.getAlerts(type: AlertTypes.priceIncrease);
      expect(res.items.every((a) => a.type == AlertTypes.priceIncrease), isTrue);
    });

    test('Performs local search across title, message, commodity, market', () async {
      final res = await fallback.getAlertHistory(search: 'tomato');
      expect(res.items, isNotEmpty);
      for (final alert in res.items) {
        final matches = alert.title.toLowerCase().contains('tomato') ||
            alert.message.toLowerCase().contains('tomato') ||
            alert.commodity.name.toLowerCase().contains('tomato') ||
            alert.market.name.toLowerCase().contains('tomato');
        expect(matches, isTrue);
      }
    });

    test('Handles fallback pagination correctly', () async {
      final page1 = await fallback.getAlerts(page: 1, pageSize: 2);
      expect(page1.items.length, 2);
      expect(page1.page, 1);

      final page2 = await fallback.getAlerts(page: 2, pageSize: 2);
      expect(page2.items.length, 2);
      expect(page2.page, 2);
      expect(page1.items.first.id != page2.items.first.id, isTrue);
    });
  });

  group('Alert Repository Fallback Behavior Tests', () {
    test('Triggers fallback on server error (500)', () async {
      final failingService = FailingApiService(statusCode: 500, errorMessage: 'Internal Server Error');
      final repo = AlertRepository(failingService, const MockSecureStorage());

      final result = await repo.getAlerts();
      expect(result.items, isNotEmpty); // Gracefully returned fallback data!
    });

    test('Rethrows authentication error (401) without fallback', () async {
      final failingService = FailingApiService(statusCode: 401, errorMessage: 'Unauthorized');
      final repo = AlertRepository(failingService, const MockSecureStorage());

      expect(() => repo.getAlerts(), throwsA(isA<AlertApiException>()));
    });

    test('Direct forceFallback flag uses fallback immediately', () async {
      final failingService = FailingApiService(statusCode: 400, errorMessage: 'Bad Request');
      final repo = AlertRepository(failingService, const MockSecureStorage(), forceFallback: true);

      final result = await repo.getAlerts();
      expect(result.items, isNotEmpty);
    });
  });
}
