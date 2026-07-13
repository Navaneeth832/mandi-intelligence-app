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

  // Localization mappings for mock data crop display names
  static const Map<String, Map<String, String>> _cropTranslations = {
    'tomato': {
      'en': 'Tomato',
      'hi': 'टमाटर',
      'ml': 'തക്കാളി',
    },
    'potato': {
      'en': 'Potato',
      'hi': 'आलू',
      'ml': 'ഉരുളക്കിഴങ്ങ്',
    },
    'onion': {
      'en': 'Onion',
      'hi': 'प्याज',
      'ml': 'സവാള',
    },
    'wheat': {
      'en': 'Wheat',
      'hi': 'गेहूं',
      'ml': 'ഗോതമ്പ്',
    },
    'maize': {
      'en': 'Maize',
      'hi': 'മक्का',
      'ml': 'ചോളം',
    },
    'apple': {
      'en': 'Apple',
      'hi': 'सेब',
      'ml': 'ആപ്പിൾ',
    },
    'banana': {
      'en': 'Banana',
      'hi': 'केला',
      'ml': 'വാഴപ്പഴം',
    },
    'coconut': {
      'en': 'Coconut',
      'hi': 'नारियल',
      'ml': 'തേങ്ങ',
    },
    'garlic': {
      'en': 'Garlic',
      'hi': 'लहसुन',
      'ml': 'വെളുത്തുള്ളി',
    },
  };

  Future<List<CommodityForecast>> getForecastsForPreferredCrops({String language = 'en'}) async {
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

    // Limit to maximum 5 cards as specified
    final List<dynamic> limitedCrops = preferredCrops.take(5).toList();

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime today = DateTime.now();
    final String todayStr = formatter.format(today);

    // 5. Generate all raw mock prediction records representing multiple batches
    final List<CommodityForecast> allPredictions = _generateAllMockForecasts(
      limitedCrops,
      today,
      language,
    );

    // 6. Filter predictions to only today's predictions
    final todayPredictions = allPredictions
        .where((p) => p.predictionDate == todayStr)
        .toList();

    if (todayPredictions.isEmpty) {
      return [];
    }

    // 7. Find the latest prediction_time among today's predictions
    final DateFormat timeFormat = DateFormat("hh:mm a");
    String latestTimeStr = '';
    DateTime? latestTime;

    for (final p in todayPredictions) {
      try {
        final parsedTime = timeFormat.parse(p.predictionTime);
        if (latestTime == null || parsedTime.isAfter(latestTime)) {
          latestTime = parsedTime;
          latestTimeStr = p.predictionTime;
        }
      } catch (_) {}
    }

    // 8. Filter predictions to only keep the ones belonging to the latest batch
    final latestPredictions = todayPredictions
        .where((p) => p.predictionTime == latestTimeStr)
        .toList();

    return latestPredictions;
  }

  // Generates a mock dataset with multiple prediction batches (yesterday, today at different times)
  List<CommodityForecast> _generateAllMockForecasts(
    List<dynamic> preferredCrops,
    DateTime today,
    String language,
  ) {
    final List<CommodityForecast> list = [];
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    final String todayStr = formatter.format(today);
    final String yesterdayStr = formatter.format(today.subtract(const Duration(days: 1)));

    // Define mock batches to simulate filtering
    // Batch A: Yesterday, 09:00 AM
    // Batch B: Today, 08:00 AM
    // Batch C: Today, 11:00 AM (LATEST)
    // Batch D: Today, 07:00 AM
    final List<Map<String, String>> batches = [
      {'date': yesterdayStr, 'time': '09:00 AM'},
      {'date': todayStr, 'time': '08:00 AM'},
      {'date': todayStr, 'time': '11:00 AM'}, // This is the latest today batch
      {'date': todayStr, 'time': '07:00 AM'},
    ];

    for (final crop in preferredCrops) {
      final int cropId = crop['commodity_id'] as int;
      final String originalName = crop['commodity_name'] as String;
      
      // Look up translated name, fallback to original
      final String translatedName = _cropTranslations[originalName.toLowerCase()]?[language] ?? originalName;

      for (final batch in batches) {
        final batchDate = batch['date']!;
        final batchTime = batch['time']!;
        final batchDateTime = formatter.parse(batchDate);

        // Tomato matches the exact contract relative to the batch date
        if (originalName.toLowerCase() == 'tomato') {
          final List<ForecastDay> forecastDays = [];
          
          // Modify prices slightly between batches to show they are different
          final List<double> prices = batchTime == '11:00 AM'
              ? [2450.0, 2480.0, 2530.0, 2610.0, 2580.0, 2550.0, 2520.0]
              : [2400.0, 2430.0, 2480.0, 2550.0, 2520.0, 2500.0, 2470.0];
              
          for (int i = 0; i < 7; i++) {
            final dateStr = formatter.format(batchDateTime.add(Duration(days: i)));
            forecastDays.add(ForecastDay(date: dateStr, price: prices[i]));
          }

          final peakIndex = batchTime == '11:00 AM' ? 3 : 3;
          final bestSellDateStr = formatter.format(batchDateTime.add(Duration(days: peakIndex)));
          final double currentPrice = prices[0];
          final double peakPrice = prices[peakIndex];

          list.add(
            CommodityForecast(
              commodityId: cropId,
              commodityName: translatedName,
              predictionDate: batchDate,
              predictionTime: batchTime,
              currentPrice: currentPrice,
              forecast: forecastDays,
              trend: 'RISING',
              bestSellDate: bestSellDateStr,
              expectedPeakPrice: peakPrice,
              recommendation: 'WAIT',
            ),
          );
        } else {
          // Dynamic deterministic forecast based on crop name hash and batch details
          final int hash = originalName.hashCode.abs() + batchTime.hashCode.abs();
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
            final List<double> multipliers = [1.0, 1.02, 1.05, 1.10, 1.08, 1.06, 1.04];
            for (int i = 0; i < 7; i++) {
              final double price = double.parse((basePrice * multipliers[i]).toStringAsFixed(0));
              if (price > peakPrice) {
                peakPrice = price;
                peakDayIndex = i;
              }
              forecastDays.add(ForecastDay(
                date: formatter.format(batchDateTime.add(Duration(days: i))),
                price: price,
              ));
            }
          } else if (trendType == 1) {
            trend = 'FALLING';
            recommendation = 'SELL TODAY';
            final List<double> multipliers = [1.0, 0.97, 0.94, 0.91, 0.88, 0.86, 0.84];
            for (int i = 0; i < 7; i++) {
              final double price = double.parse((basePrice * multipliers[i]).toStringAsFixed(0));
              forecastDays.add(ForecastDay(
                date: formatter.format(batchDateTime.add(Duration(days: i))),
                price: price,
              ));
            }
            peakPrice = basePrice;
            peakDayIndex = 0;
          } else {
            trend = 'STABLE';
            recommendation = 'HOLD';
            final List<double> multipliers = [1.0, 0.99, 1.01, 1.00, 0.99, 1.01, 1.00];
            for (int i = 0; i < 7; i++) {
              final double price = double.parse((basePrice * multipliers[i]).toStringAsFixed(0));
              if (price > peakPrice) {
                peakPrice = price;
                peakDayIndex = i;
              }
              forecastDays.add(ForecastDay(
                date: formatter.format(batchDateTime.add(Duration(days: i))),
                price: price,
              ));
            }
          }

          final bestSellDateStr = formatter.format(batchDateTime.add(Duration(days: peakDayIndex)));

          list.add(
            CommodityForecast(
              commodityId: cropId,
              commodityName: translatedName,
              predictionDate: batchDate,
              predictionTime: batchTime,
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
    }

    return list;
  }
}
