import '../models/mandi_price.dart';
import '../services/mandi_api_service.dart';

class MandiRepository {
  final MandiApiService _apiService;

  MandiRepository(this._apiService);

  Future<List<MandiPrice>> getMandiPrices() {
    return _apiService.getMandiPrices();
  }
}