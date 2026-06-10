import 'package:http/http.dart' as http;
import '../models/mandi_price.dart';

/// Service to handle API communication for Mandi data.
class MandiApiService {
  final http.Client _client;

  MandiApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MandiPrice>> fetchMandiPrices() async {
    // Implementation will go here once backend is ready.
    return [];
  }
}
