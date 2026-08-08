import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/notification_preferences.dart';

class NotificationApiService {
  final String baseUrl = ApiConstants.baseUrl;

  String _extractErrorMessage(http.Response response, String fallback) {
    final body = response.body.trim();
    if (body.isEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }

        final message = decoded['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Fall back to raw body
    }

    return body;
  }

  Future<NotificationPreferences> getNotificationPreferences(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/notification-preferences'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to fetch notification preferences'),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return NotificationPreferences.fromJson(decoded);
  }

  Future<NotificationPreferences> updateNotificationPreferences(
    String token,
    NotificationPreferences preferences,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile/notification-preferences'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(preferences.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to update notification preferences'),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return NotificationPreferences.fromJson(decoded);
  }
}
