import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/notification_preferences.dart';
import '../services/notification_api_service.dart';

class NotificationRepository {
  final NotificationApiService _apiService;
  final FlutterSecureStorage _storage;

  NotificationRepository(this._apiService, this._storage);

  static const _tokenKey = 'access_token';
  static const _hasConfiguredKey = 'has_configured_notification_preferences';

  Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> hasConfiguredNotificationPreferences() async {
    final value = await _storage.read(key: _hasConfiguredKey);
    return value == 'true';
  }

  Future<void> markNotificationPreferencesConfigured() async {
    await _storage.write(key: _hasConfiguredKey, value: 'true');
  }

  Future<NotificationPreferences> getNotificationPreferences() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return await _apiService.getNotificationPreferences(token);
  }

  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final result = await _apiService.updateNotificationPreferences(token, preferences);
    await markNotificationPreferencesConfigured();
    return result;
  }
}
