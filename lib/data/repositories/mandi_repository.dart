import '../models/mandi_price.dart';
import '../services/mandi_api_service.dart';
import '../../features/mandi_prices/providers/filter_model.dart';
import '../models/price_history.dart';
import '../models/paginated_mandi_response.dart';
import '../models/district_model.dart';

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
      market: filter.market,
      commodity: filter.crop,
    );
  }
  Future<List<String>> getStates() {
    return _apiService.getStates();
  }

  Future<List<String>> getCommodities() {
    return _apiService.getCommodities();
  }

  Future<List<String>> getMarkets(
  int? districtId,
) {
  return _apiService.getMarkets(
    districtId,
  );
}
  Future<List<PriceHistory>>
      getPriceHistory({
    required String commodity,
    required String market,
      }) {
    return _apiService.getPriceHistory(
      commodity: commodity,
      market: market,
    );
  }
  Future<List<District>> getDistricts(
  String? state,
) {
  return _apiService.getDistricts(
    state,
  );
}
}