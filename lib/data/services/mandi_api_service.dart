import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mandi_price.dart';
import '../models/price_history.dart';
import '../models/paginated_mandi_response.dart';

class MandiApiService {

  static const String baseUrl =
      'http://192.168.68.104:8000';

  Future<PaginatedMandiResponse> getMandiPrices({
    int page = 1,
    int pageSize = 20,
    String? state,
    String? market,
    String? commodity,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (state != null && state.isNotEmpty) {
      queryParams['state'] = state;
    }
    if (market != null && market.isNotEmpty) {
      queryParams['market'] = market;
    }
    if (commodity != null && commodity.isNotEmpty) {
      queryParams['commodity'] = commodity;
    }

    final uri = Uri.parse('$baseUrl/mandi-prices').replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load mandi prices',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    return PaginatedMandiResponse.fromJson(data);
  }
  Future<List<String>> getStates() async {
    final response = await http.get(
      Uri.parse('$baseUrl/states'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load states');
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((e) => e['name'].toString())
        .toList();
  }
  Future<List<String>> getCommodities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/commodities'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load commodities');
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((e) => e['name'].toString())
        .toList();
  }
  Future<List<String>> getMarkets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/markets'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load markets');
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((e) => e['name'].toString())
        .toList();
  }
  Future<List<PriceHistory>> getPriceHistory({
    required String commodity,
    required String market,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/price-history?commodity=$commodity&market=$market',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load price history',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map(
          (item) =>
              PriceHistory.fromJson(item),
        )
        .toList();
  }
}