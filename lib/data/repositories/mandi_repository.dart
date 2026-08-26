import 'dart:convert';
import '../services/mandi_api_service.dart';
import '../services/local_cache_service.dart';
import '../../features/mandi_prices/providers/filter_model.dart';
import '../models/price_history.dart';
import '../models/paginated_mandi_response.dart';
import '../models/paginated_market_response.dart';
import '../models/district_model.dart';
import '../models/commodity_model.dart';
import '../models/state_model.dart';
import '../models/market_model.dart';

// TASK 5: TESTING CONTROLS
const bool simulateLoading = false;
const bool simulateError = false;
const bool simulateEmpty = false;

class MandiRepository {
  final MandiApiService _apiService;
  final LocalCacheService? _cacheService;

  MandiRepository(this._apiService, {LocalCacheService? cacheService})
      : _cacheService = cacheService;

  Future<PaginatedMandiResponse> getMandiPrices(
    Filter filter, {
    int page = 1,
    int pageSize = 50,
    String? language,
  }) async {
    // Handle testing flags
    if (simulateLoading) {
      await Future.delayed(const Duration(seconds: 10));
    }
    if (simulateError) {
      throw Exception('Simulated error: Could not fetch prices.');
    }
    if (simulateEmpty) {
      return PaginatedMandiResponse(
        page: page,
        pageSize: pageSize,
        totalRecords: 0,
        totalPages: 0,
        data: [],
      );
    }

    try {
      final response = await _apiService.getMandiPrices(
        page: page,
        pageSize: pageSize,
        state: filter.state,
        district: filter.district,
        market: filter.market,
        commodity: filter.crop,
        language: language,
      );

      final cacheKey = LocalCacheService.buildMandiPricesKey(
        filter,
        page: page,
        pageSize: pageSize,
        language: language,
      );
      final jsonString = jsonEncode(response.toJson());
      _cacheService?.saveCache(cacheKey, jsonString);

      return response;
    } catch (e) {
      final cacheKey = LocalCacheService.buildMandiPricesKey(
        filter,
        page: page,
        pageSize: pageSize,
        language: language,
      );
      final cached = await _cacheService?.getCache(cacheKey);
      if (cached != null) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(cached.rawJson);
          return PaginatedMandiResponse.fromJson(jsonMap);
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<({PaginatedMandiResponse data, DateTime cachedAt})?> getCachedMandiPrices(
    Filter filter, {
    int page = 1,
    int pageSize = 50,
    String? language,
  }) async {
    if (_cacheService == null) return null;
    final cacheKey = LocalCacheService.buildMandiPricesKey(
      filter,
      page: page,
      pageSize: pageSize,
      language: language,
    );
    final cached = await _cacheService.getCache(cacheKey);
    if (cached != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(cached.rawJson);
        final data = PaginatedMandiResponse.fromJson(jsonMap);
        return (data: data, cachedAt: cached.cachedAt);
      } catch (_) {}
    }
    return null;
  }

  Future<List<StateModel>> getStates({String? language}) async {
    try {
      final res = await _apiService.getStates(language: language);
      final cacheKey = LocalCacheService.buildStatesKey(language);
      final jsonString = jsonEncode(res.map((s) => s.toJson()).toList());
      _cacheService?.saveCache(cacheKey, jsonString);
      return res;
    } catch (e) {
      final cacheKey = LocalCacheService.buildStatesKey(language);
      final cached = await _cacheService?.getCache(cacheKey);
      if (cached != null) {
        try {
          final List list = jsonDecode(cached.rawJson);
          return list.map((item) => StateModel.fromJson(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<List<Commodity>> getCommodities() async {
    try {
      final res = await _apiService.getCommodities();
      final cacheKey = LocalCacheService.buildCommoditiesKey('all');
      final jsonString = jsonEncode(res.map((c) => c.toJson()).toList());
      _cacheService?.saveCache(cacheKey, jsonString);
      return res;
    } catch (e) {
      final cacheKey = LocalCacheService.buildCommoditiesKey('all');
      final cached = await _cacheService?.getCache(cacheKey);
      if (cached != null) {
        try {
          final List list = jsonDecode(cached.rawJson);
          return list.map((item) => Commodity.fromJson(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<List<String>> getMarkets(
    int? districtId, {
    String? language,
  }) {
    return _apiService.getMarkets(
      districtId,
      language: language,
    );
  }

  Future<List<Market>> getMarketsList(
    int? districtId, {
    String? language,
  }) async {
    try {
      final res = await _apiService.getMarketsList(
        districtId,
        language: language,
      );
      final cacheKey = LocalCacheService.buildMarketsKey(districtId, language);
      final jsonString = jsonEncode(res.map((m) => m.toJson()).toList());
      _cacheService?.saveCache(cacheKey, jsonString);
      return res;
    } catch (e) {
      final cacheKey = LocalCacheService.buildMarketsKey(districtId, language);
      final cached = await _cacheService?.getCache(cacheKey);
      if (cached != null) {
        try {
          final List list = jsonDecode(cached.rawJson);
          return list.map((item) => Market.fromJson(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<List<Market>> getAllMarketsList(
    int? districtId, {
    String? language,
  }) async {
    try {
      final res = await _apiService.getAllMarketsList(
        districtId,
        language: language,
      );
      final cacheKey = 'all_${LocalCacheService.buildMarketsKey(districtId, language)}';
      final jsonString = jsonEncode(res.map((m) => m.toJson()).toList());
      _cacheService?.saveCache(cacheKey, jsonString);
      return res;
    } catch (e) {
      final cacheKey = 'all_${LocalCacheService.buildMarketsKey(districtId, language)}';
      final cached = await _cacheService?.getCache(cacheKey);
      if (cached != null) {
        try {
          final List list = jsonDecode(cached.rawJson);
          return list.map((item) => Market.fromJson(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<PaginatedMarketResponse> getMarketDirectory(
    int? stateId,
    int? districtId,
    int? commodityId, {
    int page = 1,
    int pageSize = 50,
    String? search,
    String? language,
  }) {
    return _apiService.getMarketDirectory(
      page: page,
      pageSize: pageSize,
      stateId: stateId,
      districtId: districtId,
      commodityId: commodityId,
      search: search,
      language: language,
    );
  }

  Future<List<PriceHistory>> getPriceHistory({
    required String commodity,
    required String market,
    required String variety,
  }) {
    return _apiService.getPriceHistory(
      commodity: commodity,
      market: market,
      variety: variety,
    );
  }

  Future<List<Commodity>> getActiveCommodities() async {
    try {
      final res = await _apiService.getActiveCommodities();
      final cacheKey = LocalCacheService.buildCommoditiesKey('active');
      final jsonString = jsonEncode(res.map((c) => c.toJson()).toList());
      _cacheService?.saveCache(cacheKey, jsonString);
      return res;
    } catch (e) {
      final cacheKey = LocalCacheService.buildCommoditiesKey('active');
      final cached = await _cacheService?.getCache(cacheKey);
      if (cached != null) {
        try {
          final List list = jsonDecode(cached.rawJson);
          return list.map((item) => Commodity.fromJson(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<List<Commodity>> getAllCommodities() async {
    try {
      final res = await _apiService.getAllCommodities();
      final cacheKey = LocalCacheService.buildCommoditiesKey('all');
      final jsonString = jsonEncode(res.map((c) => c.toJson()).toList());
      _cacheService?.saveCache(cacheKey, jsonString);
      return res;
    } catch (e) {
      final cacheKey = LocalCacheService.buildCommoditiesKey('all');
      final cached = await _cacheService?.getCache(cacheKey);
      if (cached != null) {
        try {
          final List list = jsonDecode(cached.rawJson);
          return list.map((item) => Commodity.fromJson(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<List<District>> getDistricts({
    String? state,
    int? stateId,
    String? language,
  }) async {
    try {
      final res = await _apiService.getDistricts(
        state: state,
        stateId: stateId,
        language: language,
      );
      final cacheKey = LocalCacheService.buildDistrictsKey(state, stateId, language);
      final jsonString = jsonEncode(res.map((d) => d.toJson()).toList());
      _cacheService?.saveCache(cacheKey, jsonString);
      return res;
    } catch (e) {
      final cacheKey = LocalCacheService.buildDistrictsKey(state, stateId, language);
      final cached = await _cacheService?.getCache(cacheKey);
      if (cached != null) {
        try {
          final List list = jsonDecode(cached.rawJson);
          return list.map((item) => District.fromJson(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      rethrow;
    }
  }
}
