import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'auth_repository.dart';
import '../models/forecast_model.dart';

// TESTING CONTROLS
const bool simulateForecastLoading = false;
const bool simulateForecastError = false;
const bool simulateForecastEmpty = false;

class ForecastRepository {
  final AuthRepository _authRepository;
  static const String baseUrl = ApiConstants.baseUrl;

  ForecastRepository(this._authRepository);

  Future<PaginatedForecastResponse> getForecastsForPreferredCrops({
    String language = 'en',
    int page = 1,
    int pageSize = 15,
    int? commodityId,
    int? marketId,
  }) async {
    // 1. Simulate loading state
    if (simulateForecastLoading) {
      await Future.delayed(const Duration(seconds: 3));
    }

    // 2. Simulate error state
    if (simulateForecastError) {
      throw Exception('Failed to fetch forecasts. Please check your connection.');
    }

    // 3. Simulate empty state
    if (simulateForecastEmpty) {
      return PaginatedForecastResponse(
        page: page,
        pageSize: pageSize,
        total: 0,
        hasNext: false,
        predictions: [],
      );
    }

    // 4. Retrieve access token from secure storage
    final token = await _authRepository.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    // 5. Construct Predictions API endpoint URI
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (language.isNotEmpty) {
      queryParams['language'] = language;
    }
    if (commodityId != null) {
      queryParams['commodity_id'] = commodityId.toString();
    }
    if (marketId != null) {
      queryParams['market_id'] = marketId.toString();
    }

    final uri = Uri.parse('$baseUrl/predictions/').replace(queryParameters: queryParams);

    // 6. Execute GET request with Bearer Auth header
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // 7. Parse response body and return paginated forecasts
    if (response.statusCode != 200) {
      throw Exception('Failed to load predictions from server.');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return PaginatedForecastResponse.fromJson(data);
  }
}
