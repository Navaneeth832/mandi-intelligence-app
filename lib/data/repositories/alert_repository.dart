import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/alert_fallback_data_source.dart';
import '../models/alert_model.dart';
import '../services/alert_api_service.dart';

class AlertRepository {
  final AlertApiService _apiService;
  final FlutterSecureStorage _storage;
  final AlertFallbackDataSource _fallbackDataSource;
  final bool forceFallback;

  AlertRepository(
    this._apiService,
    this._storage, {
    AlertFallbackDataSource? fallbackDataSource,
    this.forceFallback = false,
  }) : _fallbackDataSource = fallbackDataSource ?? AlertFallbackDataSource();

  static const String _tokenKey = 'access_token';

  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  bool _shouldFallback(Object error) {
    if (forceFallback) return true;

    if (error is SocketException) return true;
    if (error is AlertApiException) {
      if (error.statusCode == 401) {
        // Do not fallback on authentication errors (401)
        return false;
      }
      // Fallback on server connection, 5xx errors, or unavailable backend
      if (error.statusCode == null || error.statusCode! >= 500 || error.statusCode == 404 || error.statusCode == 503) {
        return true;
      }
    }
    // Timeout or format/network errors
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('timeout') ||
        errStr.contains('connection refused') ||
        errStr.contains('failed host lookup') ||
        errStr.contains('clientexception')) {
      return true;
    }

    return false;
  }

  Future<PaginatedAlertsResponse> getAlerts({
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (forceFallback) {
      return await _fallbackDataSource.getAlerts(
        type: type,
        page: page,
        pageSize: pageSize,
      );
    }

    try {
      final token = await _getToken();
      return await _apiService.getAlerts(
        type: type,
        page: page,
        pageSize: pageSize,
        token: token,
      );
    } catch (e) {
      if (_shouldFallback(e)) {
        return await _fallbackDataSource.getAlerts(
          type: type,
          page: page,
          pageSize: pageSize,
        );
      }
      rethrow;
    }
  }

  Future<PaginatedAlertsResponse> getAlertHistory({
    String? type,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (forceFallback) {
      return await _fallbackDataSource.getAlertHistory(
        type: type,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        pageSize: pageSize,
      );
    }

    try {
      final token = await _getToken();
      return await _apiService.getAlertHistory(
        type: type,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        pageSize: pageSize,
        token: token,
      );
    } catch (e) {
      if (_shouldFallback(e)) {
        return await _fallbackDataSource.getAlertHistory(
          type: type,
          search: search,
          dateFrom: dateFrom,
          dateTo: dateTo,
          page: page,
          pageSize: pageSize,
        );
      }
      rethrow;
    }
  }
}
