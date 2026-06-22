import 'dart:convert';

import 'package:http/http.dart' as http;


import '../models/price_history.dart';
import '../models/district_model.dart';
import '../models/paginated_mandi_response.dart';
import '../models/paginated_market_response.dart';
import '../models/commodity_model.dart';
import '../models/state_model.dart';

class MandiApiService {

  static const String baseUrl =
      'https://mandi-intelligence-app-production.up.railway.app';//'http://192.168.29.253:8000';

  Future<PaginatedMandiResponse> getMandiPrices({
    int page = 1,
    int pageSize = 20,
    String? state,
    String? district,
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
    if (district != null && district.isNotEmpty) {
      queryParams['district'] = district;
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
  Future<List<StateModel>> getStates() async {
    final response = await http.get(
      Uri.parse('$baseUrl/states'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load states');
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((e) => StateModel.fromJson(e))
        .toList();
  }
  
  Future<List<Commodity>> getCommodities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/commodities'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load commodities');
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((e) => Commodity.fromJson(e))
        .toList();
  }
  
  Future<List<String>> getMarkets(int? districtId,) async {
      String endpoint = '/markets';
     if (districtId != null) {
        endpoint += '?district_id=$districtId';
    }
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
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
  
  Future<PaginatedMarketResponse> getMarketDirectory({
    int page = 1,
    int pageSize = 50,
    int? stateId,
    int? districtId,
    int? commodityId,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (stateId != null) {
      queryParams['state_id'] = stateId.toString();
    }
    if (districtId != null) {
      queryParams['district_id'] = districtId.toString();
    }
    if (commodityId != null) {
      queryParams['commodity_id'] = commodityId.toString();
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    final uri = Uri.parse('$baseUrl/market-directory').replace(queryParameters: queryParams);
    
    final response = await http.get(uri);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to load market directory');
    }
    
    final Map<String, dynamic> data = jsonDecode(response.body);
    
    return PaginatedMarketResponse.fromJson(data);
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
  Future<List<District>> getDistricts({
    String? state,
    int? stateId,
  }) async {
    String endpoint = '/districts';
    final queryParams = <String, String>{};

    if (state != null && state.isNotEmpty) {
      queryParams['state'] = state;
    }
    if (stateId != null) {
      queryParams['state_id'] = stateId.toString();
    }

    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load districts',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map(
          (e) => District.fromJson(e),
        )
        .toList();
  }
}
