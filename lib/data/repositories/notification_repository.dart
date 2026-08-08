import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/notification_preferences.dart';
import '../services/notification_api_service.dart';

class NotificationRepository {
  final NotificationApiService _apiService;
  final FlutterSecureStorage _storage;

  NotificationRepository(this._apiService, this._storage);

  static const _tokenKey = 'access_token';

  Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
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
    return await _apiService.updateNotificationPreferences(token, preferences);
  }
}
