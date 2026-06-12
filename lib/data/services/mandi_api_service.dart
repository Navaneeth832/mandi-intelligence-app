import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mandi_price.dart';

class MandiApiService {

  static const String baseUrl =
      'http://127.0.0.1:8000';

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
}