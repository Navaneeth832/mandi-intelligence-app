import '../services/mandi_api_service.dart';
import '../../features/mandi_prices/providers/filter_model.dart';
import '../models/price_history.dart';
import '../models/paginated_mandi_response.dart';
import '../models/paginated_market_response.dart';
import '../models/district_model.dart';
import '../models/commodity_model.dart';
import '../models/state_model.dart';

// TASK 5: TESTING CONTROLS
const bool simulateLoading = false;
const bool simulateError = false;
const bool simulateEmpty = false;

class MandiRepository {
  final MandiApiService _apiService;

  MandiRepository(this._apiService);

  Future<PaginatedMandiResponse> getMandiPrices(
    Filter filter, {
    int page = 1,
    int pageSize = 50,
    String? language,
  }) async {
    // Handle testing flags
    if (simulateLoading) {
      await Future.delayed(const Duration(seconds: 10));
      // This will likely time out or be handled by a loading indicator in the UI
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

    return _apiService.getMandiPrices(
      page: page,
      pageSize: pageSize,
      state: filter.state,
      district: filter.district,
      market: filter.market,
      commodity: filter.crop,
      language: language,
    );
  }
  Future<List<StateModel>> getStates({String? language}) {
    return _apiService.getStates(language: language);
  }

  Future<List<Commodity>> getCommodities() {
    return _apiService.getCommodities();
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

  Future<List<PriceHistory>>
      getPriceHistory({
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
  Future<List<District>> getDistricts({
    String? state,
    int? stateId,
    String? language,
  }) {
  return _apiService.getDistricts(
    state: state,
    stateId: stateId,
    language: language,
  );
}
}
