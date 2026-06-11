import '../models/mandi_price.dart';
import '../services/mandi_api_service.dart';

/// Repository to manage Mandi price data.
class MandiRepository {
  final MandiApiService _apiService;

  MandiRepository(this._apiService);

  /// Fetches mandi prices. Returns mock data for development.
  Future<List<MandiPrice>> getMandiPrices() async {
    // Mock data for development
    return [
      MandiPrice(
        commodity: "Tomato",
        market: "Perumbavoor",
        district: "Ernakulam",
        state: "Kerala",
        variety: "Hybrid",
        minPrice: 1800,
        modalPrice: 2200,
        maxPrice: 2500,
        arrivalDate: DateTime.now(),
      ),
    ];
  }
}
