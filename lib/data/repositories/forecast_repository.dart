import 'package:intl/intl.dart';
import 'auth_repository.dart';
import '../models/forecast_model.dart';

// TESTING CONTROLS
const bool simulateForecastLoading = false;
const bool simulateForecastError = false;
const bool simulateForecastEmpty = false;

class ForecastRepository {
  final AuthRepository _authRepository;

  ForecastRepository(this._authRepository);

  Future<List<CommodityForecast>> getForecastsForPreferredCrops() async {
    // 1. Simulate loading state
    if (simulateForecastLoading) {
      await Future.delayed(const Duration(seconds: 3));
    }

    // 2. Simulate error state
    if (simulateForecastError) {
      throw Exception('Failed to fetch forecasts. Please check your connection.');
    }

    // 3. Get preferred crops from user preferences
    final preferredCrops = await _authRepository.getPreferredCrops();

    // 4. Simulate empty state or handle actual empty preferred crops
    if (simulateForecastEmpty || preferredCrops.isEmpty) {
      return [];
    }

    // 5. Generate forecasts only for the preferred crops
    final List<CommodityForecast> forecasts = [];
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime today = DateTime.now();

    // Limit to maximum 5 cards as specified
    final List<dynamic> limitedCrops = preferredCrops.take(5).toList();

    for (final crop in limitedCrops) {
      final String cropName = crop['commodity_name'] as String;
      
      // If it's Tomato, match the exact contract response format relative to current date (or static if matching contract)
      if (cropName.toLowerCase() == 'tomato') {
        final List<ForecastDay> forecastDays = [];
        final List<double> prices = [2450.0, 2480.0, 2530.0, 2610.0, 2580.0, 2550.0, 2520.0];
        
        for (int i = 0; i < 7; i++) {
          final dateStr = formatter.format(today.add(Duration(days: i)));
          forecastDays.add(ForecastDay(date: dateStr, price: prices[i]));
        }

        final bestSellDateStr = formatter.format(today.add(const Duration(days: 3))); // Peak on 4th day (index 3)

        forecasts.add(
          CommodityForecast(
            commodity: cropName,
            currentPrice: 2450.0,
            forecast: forecastDays,
            trend: 'RISING',
            bestSellDate: bestSellDateStr,
            expectedPeakPrice: 2610.0,
            recommendation: 'WAIT',
          ),
        );
      } else {
        // Generate dynamic deterministic forecast based on crop name hash
        final int hash = cropName.hashCode.abs();
        final double basePrice = ((hash % 3000) + 1000).toDouble(); // Price between 1000 and 4000
        
        final List<ForecastDay> forecastDays = [];
        final int trendType = hash % 3; // 0 = Rising, 1 = Falling, 2 = Stable
        
        String trend;
        String recommendation;
        int peakDayIndex = 0;
        double peakPrice = basePrice;

        if (trendType == 0) {
          trend = 'RISING';
          recommendation = 'WAIT';
          // Price rises for 4 days then drops slightly
          final List<double> multipliers = [1.0, 1.02, 1.05, 1.10, 1.08, 1.06, 1.04];
          for (int i = 0; i < 7; i++) {
            final double price = double.parse((basePrice * multipliers[i]).toStringAsFixed(0));
            if (price > peakPrice) {
              peakPrice = price;
              peakDayIndex = i;
            }
            forecastDays.add(ForecastDay(
              date: formatter.format(today.add(Duration(days: i))),
              price: price,
            ));
          }
        } else if (trendType == 1) {
          trend = 'FALLING';
          recommendation = 'SELL TODAY';
          // Price falls consistently
          final List<double> multipliers = [1.0, 0.97, 0.94, 0.91, 0.88, 0.86, 0.84];
          for (int i = 0; i < 7; i++) {
            final double price = double.parse((basePrice * multipliers[i]).toStringAsFixed(0));
            forecastDays.add(ForecastDay(
              date: formatter.format(today.add(Duration(days: i))),
              price: price,
            ));
          }
          peakPrice = basePrice;
          peakDayIndex = 0;
        } else {
          trend = 'STABLE';
          recommendation = 'HOLD';
          // Fluctuate slightly
          final List<double> multipliers = [1.0, 0.99, 1.01, 1.00, 0.99, 1.01, 1.00];
          for (int i = 0; i < 7; i++) {
            final double price = double.parse((basePrice * multipliers[i]).toStringAsFixed(0));
            if (price > peakPrice) {
              peakPrice = price;
              peakDayIndex = i;
            }
            forecastDays.add(ForecastDay(
              date: formatter.format(today.add(Duration(days: i))),
              price: price,
            ));
          }
        }

        final bestSellDateStr = formatter.format(today.add(Duration(days: peakDayIndex)));

        forecasts.add(
          CommodityForecast(
            commodity: cropName,
            currentPrice: basePrice,
            forecast: forecastDays,
            trend: trend,
            bestSellDate: bestSellDateStr,
            expectedPeakPrice: peakPrice,
            recommendation: recommendation,
          ),
        );
      }
    }

    return forecasts;
  }
}
