import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/alert_model.dart';
import '../services/alert_api_service.dart';

class AlertRepository {
  final AlertApiService _apiService;
  final FlutterSecureStorage _storage;

  AlertRepository(
    this._apiService,
    this._storage,
  );

  static const String _tokenKey = 'access_token';

  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<PaginatedAlertsResponse> getAlerts({
    String? type,
    String? language,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _getToken();
    return await _apiService.getAlerts(
      type: type,
      language: language,
      page: page,
      pageSize: pageSize,
      token: token,
    );
  }

  Future<PaginatedAlertsResponse> getAlertHistory({
    String? type,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? language,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _getToken();
    return await _apiService.getAlertHistory(
      type: type,
      search: search,
      dateFrom: dateFrom,
      dateTo: dateTo,
      language: language,
      page: page,
      pageSize: pageSize,
      token: token,
    );
  }
}
