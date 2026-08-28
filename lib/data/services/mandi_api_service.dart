import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

import '../models/price_history.dart';
import '../models/district_model.dart';
import '../models/paginated_mandi_response.dart';
import '../models/paginated_market_response.dart';
import '../models/commodity_model.dart';
import '../models/state_model.dart';
import '../models/market_model.dart';
import '../models/market_comparison_model.dart';

class MandiApiService {

  static const String baseUrl = ApiConstants.baseUrl;

  Future<PaginatedMandiResponse> getMandiPrices({
    int page = 1,
    int pageSize = 20,
    String? state,
    String? district,
    String? market,
    String? commodity,
    String? language,
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
    if (language != null && language.isNotEmpty) {
      queryParams['language'] = language;
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
  Future<List<StateModel>> getStates({String? language}) async {
    final queryParams = <String, String>{};
    
    if (language != null && language.isNotEmpty) {
      queryParams['language'] = language;
    }
    
    final uri = Uri.parse('$baseUrl/states').replace(queryParameters: queryParams);
    
    final response = await http.get(uri);

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
  Future<List<Commodity>> getActiveCommodities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/commodities/active'),
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

  Future<List<Commodity>> getAllCommodities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/commodities/all'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load all commodities');
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((e) => Commodity.fromJson(e))
        .toList();
  }
  Future<List<String>> getMarkets(int? districtId, {String? language}) async {
      String endpoint = '/markets';
      final queryParams = <String, String>{};
      
      if (districtId != null) {
        queryParams['district_id'] = districtId.toString();
      }
      if (language != null && language.isNotEmpty) {
        queryParams['language'] = language;
      }
      
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      
      final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load markets');
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((e) => e['name'].toString())
        .toList();
  }

  Future<List<Market>> getMarketsList(int? districtId, {String? language}) async {
      String endpoint = '/markets';
      final queryParams = <String, String>{};
      
      if (districtId != null) {
        queryParams['district_id'] = districtId.toString();
      }
      if (language != null && language.isNotEmpty) {
        queryParams['language'] = language;
      }
      
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      
      final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load markets');
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((e) => Market.fromJson(e))
        .toList();
  }

  Future<List<Market>> getAllMarketsList(int? districtId, {String? language}) async {
    String endpoint = '/markets/all';
    final queryParams = <String, String>{};
    
    if (districtId != null) {
      queryParams['district_id'] = districtId.toString();
    }
    if (language != null && language.isNotEmpty) {
      queryParams['language'] = language;
    }
    
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load all markets');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((e) => Market.fromJson(e))
        .toList();
  }
  
  Future<PaginatedMarketResponse> getMarketDirectory({
    int page = 1,
    int pageSize = 50,
    int? stateId,
    int? districtId,
    int? commodityId,
    String? search,
    String? language,
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
    if (language != null && language.isNotEmpty) {
      queryParams['language'] = language;
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
    required String variety,
  }) async {
    final queryParams = {
      'commodity': commodity,
      'market': market,
      'variety': variety,
    };

    final uri = Uri.parse('$baseUrl/price-history').replace(queryParameters: queryParams);
    
    final response = await http.get(uri);

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
    String? language,
  }) async {
    String endpoint = '/districts';
    final queryParams = <String, String>{};

    if (state != null && state.isNotEmpty) {
      queryParams['state'] = state;
    }
    if (stateId != null) {
      queryParams['state_id'] = stateId.toString();
    }
    if (language != null && language.isNotEmpty) {
      queryParams['language'] = language;
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

  Future<MarketComparisonResponse> getMarketComparison({
    required double lat,
    required double lng,
    int? commodityId,
    double transportRatePerKm = 2.5,
    double quantity = 10.0,
  }) async {
    // -------------------------------------------------------------------------
    // ENDPOINT SWITCH FOR RAIHAN:
    // Change '/markets/compare-mock' to '/markets/compare' when the real
    // PostGIS endpoint is deployed.
    // -------------------------------------------------------------------------
    const String endpoint = '/markets/compare';

    final queryParams = <String, String>{
      'lat': lat.toString(),
      'lng': lng.toString(),
      'transport_rate_per_km': transportRatePerKm.toString(),
      'quantity': quantity.toString(),
    };

    if (commodityId != null) {
      queryParams['commodity_id'] = commodityId.toString();
    }

    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load market comparison');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return MarketComparisonResponse.fromJson(data);
  }
}
