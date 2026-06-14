import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mandi_price.dart';
import '../models/price_history.dart';

class MandiApiService {

  static const String baseUrl =
      'http://192.168.29.253:8000';

  Future<List<MandiPrice>> getMandiPrices() async {

    final response = await http.get(
      Uri.parse('$baseUrl/mandi-prices'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load mandi prices',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map(
          (item) =>
              MandiPrice.fromJson(item),
        )
        .toList();
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