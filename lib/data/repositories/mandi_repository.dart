import '../models/mandi_price.dart';
import '../services/mandi_api_service.dart';
import '../../features/mandi_prices/providers/filter_model.dart';

// TASK 5: TESTING CONTROLS
const bool simulateLoading = false;
const bool simulateError = false;
const bool simulateEmpty = false;

class MandiRepository {
  final MandiApiService _apiService;

  MandiRepository(this._apiService);

  Future<List<MandiPrice>> getMandiPrices(Filter filter) async {
    // Handle testing flags
    if (simulateLoading) {
      await Future.delayed(const Duration(seconds: 10));
      // This will likely time out or be handled by a loading indicator in the UI
    }
    if (simulateError) {
      throw Exception('Simulated error: Could not fetch prices.');
    }
    if (simulateEmpty) {
      return [];
    }

    final allPrices = await _apiService.getMandiPrices();

    // Apply filters
    return allPrices.where((price) {
      final cropMatch = filter.crop == null || price.commodity == filter.crop;
      final stateMatch = filter.state == null || price.state == filter.state;
      final marketMatch = filter.market == null || price.market == filter.market;
      return cropMatch && stateMatch && marketMatch;
    }).toList();
  }
  Future<List<String>> getStates() {
    return _apiService.getStates();
  }

  Future<List<String>> getCommodities() {
    return _apiService.getCommodities();
  }

  Future<List<String>> getMarkets() {
    return _apiService.getMarkets();
  }
}