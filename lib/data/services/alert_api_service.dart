import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/alert_model.dart';

class AlertApiException implements Exception {
  final String message;
  final int? statusCode;

  AlertApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AlertApiService {
  final String baseUrl;

  AlertApiService({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConstants.baseUrl;

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

  Map<String, String> _buildHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<PaginatedAlertsResponse> getAlerts({
    String? type,
    int page = 1,
    int pageSize = 20,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (type != null && type.isNotEmpty && type != 'ALL') {
      queryParams['type'] = type;
    }

    final uri = Uri.parse('$baseUrl/alerts').replace(queryParameters: queryParams);

    final response = await http
        .get(uri, headers: _buildHeaders(token))
        .timeout(const Duration(seconds: ApiConstants.timeoutSeconds));

    if (response.statusCode != 200) {
      throw AlertApiException(
        _extractErrorMessage(response, 'Failed to fetch alerts'),
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PaginatedAlertsResponse.fromJson(decoded);
  }

  Future<PaginatedAlertsResponse> getAlertHistory({
    String? type,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 20,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (type != null && type.isNotEmpty && type != 'ALL') {
      queryParams['type'] = type;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (dateFrom != null && dateFrom.isNotEmpty) {
      queryParams['date_from'] = dateFrom;
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      queryParams['date_to'] = dateTo;
    }

    final uri = Uri.parse('$baseUrl/alerts/history').replace(queryParameters: queryParams);

    final response = await http
        .get(uri, headers: _buildHeaders(token))
        .timeout(const Duration(seconds: ApiConstants.timeoutSeconds));

    if (response.statusCode != 200) {
      throw AlertApiException(
        _extractErrorMessage(response, 'Failed to fetch alert history'),
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PaginatedAlertsResponse.fromJson(decoded);
  }
}
