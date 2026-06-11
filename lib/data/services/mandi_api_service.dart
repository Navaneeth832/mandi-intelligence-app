import 'dart:math';
import '../models/mandi_price.dart';

class MandiApiService {
  // Simulate a network request
  Future<List<MandiPrice>> getMandiPrices() async {
    await Future.delayed(const Duration(seconds: 2));

    // Simulate a random error
    if (Random().nextDouble() < 0.1) {
      throw Exception('Failed to load market prices. Please check your connection.');
    }

    // Simulate empty list
    if (Random().nextDouble() < 0.1) {
      return [];
    }

    return List.generate(10, (index) {
      final random = Random();
      return MandiPrice(
        commodity: 'Tomato',
        variety: 'Variety ${index + 1}',
        market: 'Market ${index + 1}',
        district: 'District ${random.nextInt(5) + 1}',
        state: 'Kerala',
        modalPrice: 2500 + random.nextInt(500),
        highPrice: 2800 + random.nextInt(300),
        lowPrice: 2200 + random.nextInt(200),
        priceChange: (random.nextDouble() * 10) - 5,
        lastUpdated: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
      );
    });
  }
}