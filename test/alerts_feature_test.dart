import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mandi_intelligence_app/data/models/alert_model.dart';
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
  Future<PaginatedAlertsResponse> getAlerts({String? type, String? language, int page = 1, int pageSize = 20, String? token}) async {
    throw AlertApiException(errorMessage, statusCode: statusCode);
  }

  @override
  Future<PaginatedAlertsResponse> getAlertHistory({String? type, String? search, String? dateFrom, String? dateTo, String? language, int page = 1, int pageSize = 20, String? token}) async {
    throw AlertApiException(errorMessage, statusCode: statusCode);
  }
}

class SuccessApiService extends AlertApiService {
  @override
  Future<PaginatedAlertsResponse> getAlerts({String? type, String? language, int page = 1, int pageSize = 20, String? token}) async {
    return PaginatedAlertsResponse(
      items: [
        Alert(
          id: 1,
          type: AlertTypes.priceIncrease,
          severity: 'HIGH',
          title: 'Tomato price increased',
          message: 'Tomato prices increased by 14%',
          commodity: const AlertCommodity(id: 19, name: 'Tomato'),
          market: const AlertMarket(id: 52, name: 'Thrissur Mandi'),
          price: const AlertPrice(current: 2800.0, previous: 2450.0, changePercent: 14.29),
          createdAt: DateTime.now(),
        )
      ],
      page: page,
      pageSize: pageSize,
      total: 1,
    );
  }

  @override
  Future<PaginatedAlertsResponse> getAlertHistory({String? type, String? search, String? dateFrom, String? dateTo, String? language, int page = 1, int pageSize = 20, String? token}) async {
    return PaginatedAlertsResponse(
      items: [
        Alert(
          id: 2,
          type: AlertTypes.betterMarket,
          severity: 'MEDIUM',
          title: 'Better price available',
          message: 'Better price for Coconut',
          commodity: const AlertCommodity(id: 42, name: 'Coconut'),
          market: const AlertMarket(id: 88, name: 'Kozhikode Mandi'),
          price: const AlertPrice(current: 3150.0, previous: 2800.0, changePercent: 12.5),
          createdAt: DateTime.now(),
        )
      ],
      page: page,
      pageSize: pageSize,
      total: 1,
    );
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

  group('Alert Repository API Integration Tests', () {
    test('Fetches alerts successfully via AlertApiService', () async {
      final service = SuccessApiService();
      final repo = AlertRepository(service, const MockSecureStorage());

      final result = await repo.getAlerts();
      expect(result.items.length, 1);
      expect(result.items.first.title, 'Tomato price increased');
    });

    test('Fetches alert history successfully via AlertApiService', () async {
      final service = SuccessApiService();
      final repo = AlertRepository(service, const MockSecureStorage());

      final result = await repo.getAlertHistory(dateFrom: '2026-08-01', dateTo: '2026-08-23');
      expect(result.items.length, 1);
      expect(result.items.first.type, AlertTypes.betterMarket);
    });

    test('Rethrows API exceptions on failure', () async {
      final failingService = FailingApiService(statusCode: 500, errorMessage: 'Server Error');
      final repo = AlertRepository(failingService, const MockSecureStorage());

      expect(() => repo.getAlerts(), throwsA(isA<AlertApiException>()));
    });
  });
}
