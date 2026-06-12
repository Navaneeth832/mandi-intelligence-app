import 'dart:math';
import '../models/mandi_price.dart';

class MandiApiService {
  // Simulate a network request
  Future<List<MandiPrice>> getMandiPrices() async {
    // This is where you would make a real API call.
    // For now, we are returning a hardcoded list after a short delay.
    await Future.delayed(const Duration(milliseconds: 800));
    return _dummyPrices;
  }

  final List<MandiPrice> _dummyPrices = [
    MandiPrice(commodity: 'Tomato', variety: 'Nadan', market: 'Ernakulam', district: 'Ernakulam', state: 'Kerala', modalPrice: 42, highPrice: 45, lowPrice: 38, priceChange: 1.5, lastUpdated: DateTime.now()),
    MandiPrice(commodity: 'Tomato', variety: 'Hybrid', market: 'Coimbatore', district: 'Coimbatore', state: 'Tamil Nadu', modalPrice: 38, highPrice: 40, lowPrice: 35, priceChange: -0.5, lastUpdated: DateTime.now()),
    MandiPrice(commodity: 'Tomato', variety: 'Nadan', market: 'Mangalore', district: 'Dakshina Kannada', state: 'Karnataka', modalPrice: 40, highPrice: 43, lowPrice: 37, priceChange: 0.2, lastUpdated: DateTime.now()),
    MandiPrice(commodity: 'Coconut', variety: 'West Coast Tall', market: 'Alappuzha', district: 'Alappuzha', state: 'Kerala', modalPrice: 35, highPrice: 38, lowPrice: 32, priceChange: -0.5, lastUpdated: DateTime.now()),
    MandiPrice(commodity: 'Coconut', variety: 'East Coast Tall', market: 'Coimbatore', district: 'Coimbatore', state: 'Tamil Nadu', modalPrice: 36, highPrice: 39, lowPrice: 33, priceChange: 1.0, lastUpdated: DateTime.now()),
    MandiPrice(commodity: 'Paddy', variety: 'Uma', market: 'Palakkad', district: 'Palakkad', state: 'Kerala', modalPrice: 28, highPrice: 30, lowPrice: 26, priceChange: 0.2, lastUpdated: DateTime.now()),
    MandiPrice(commodity: 'Paddy', variety: 'Jaya', market: 'Thanjavur', district: 'Thanjavur', state: 'Tamil Nadu', modalPrice: 30, highPrice: 32, lowPrice: 28, priceChange: -0.8, lastUpdated: DateTime.now()),
    MandiPrice(commodity: 'Paddy', variety: 'Jyothi', market: 'Shivamogga', district: 'Shivamogga', state: 'Karnataka', modalPrice: 29, highPrice: 31, lowPrice: 27, priceChange: 0.5, lastUpdated: DateTime.now()),
  ];
}