import '../models/alert_model.dart';

class AlertFallbackDataSource {
  static List<Alert> _generateMockAlerts() {
    final now = DateTime.now();

    // Generate dates relative to current date (or 2026-08-09 baseline)
    final todayMorning = DateTime(now.year, now.month, now.day, 9, 30);
    final todayNoon = DateTime(now.year, now.month, now.day, 12, 15);
    final yesterdayAfternoon = now.subtract(const Duration(days: 1, hours: 2));
    final yesterdayMorning = now.subtract(const Duration(days: 1, hours: 6));
    final day2Ago = now.subtract(const Duration(days: 2));
    final day3Ago = now.subtract(const Duration(days: 3));
    final day4Ago = now.subtract(const Duration(days: 4));
    final day5Ago = now.subtract(const Duration(days: 5));

    return [
      Alert(
        id: 101,
        type: AlertTypes.priceIncrease,
        severity: 'HIGH',
        title: 'Tomato price increased',
        message: 'Tomato prices increased by 14.29% in Thrissur Mandi due to increased demand.',
        commodity: const AlertCommodity(id: 19, name: 'Tomato'),
        market: const AlertMarket(id: 52, name: 'Thrissur Mandi'),
        price: const AlertPrice(current: 2800.0, previous: 2450.0, changePercent: 14.29),
        createdAt: todayNoon,
      ),
      Alert(
        id: 102,
        type: AlertTypes.betterMarket,
        severity: 'MEDIUM',
        title: 'Better market found for Coconut',
        message: 'Kozhikode Mandi is offering 12.5% higher prices for Coconut compared to your local market.',
        commodity: const AlertCommodity(id: 42, name: 'Coconut'),
        market: const AlertMarket(id: 88, name: 'Kozhikode Mandi'),
        price: const AlertPrice(current: 3150.0, previous: 2800.0, changePercent: 12.50),
        createdAt: todayMorning,
      ),
      Alert(
        id: 103,
        type: AlertTypes.aiRecommendation,
        severity: 'HIGH',
        title: 'AI Recommendation: Hold Potato sales',
        message: 'AI models predict a 15% price rally for Potato in Palakkad Mandi within 3 days. Recommend holding current stock.',
        commodity: const AlertCommodity(id: 15, name: 'Potato'),
        market: const AlertMarket(id: 61, name: 'Palakkad Mandi'),
        price: null, // Nullable price as allowed for AI_RECOMMENDATION
        createdAt: yesterdayAfternoon,
      ),
      Alert(
        id: 104,
        type: AlertTypes.priceDrop,
        severity: 'HIGH',
        title: 'Onion price dropped',
        message: 'Onion modal price dropped by 8.33% in Kozhikode Mandi following fresh arrivals.',
        commodity: const AlertCommodity(id: 24, name: 'Onion'),
        market: const AlertMarket(id: 88, name: 'Kozhikode Mandi'),
        price: const AlertPrice(current: 2200.0, previous: 2400.0, changePercent: -8.33),
        createdAt: yesterdayMorning,
      ),
      Alert(
        id: 105,
        type: AlertTypes.priceIncrease,
        severity: 'MEDIUM',
        title: 'Green Chilli price surged',
        message: 'Green Chilli price jumped by 10.0% in Ernakulam Mandi.',
        commodity: const AlertCommodity(id: 31, name: 'Green Chilli'),
        market: const AlertMarket(id: 44, name: 'Ernakulam Mandi'),
        price: const AlertPrice(current: 4400.0, previous: 4000.0, changePercent: 10.00),
        createdAt: day2Ago,
      ),
      Alert(
        id: 106,
        type: AlertTypes.betterMarket,
        severity: 'MEDIUM',
        title: 'Higher payout for Banana',
        message: 'Wayand Mandi reports a price premium of 9.5% for Nendran Banana over regional average.',
        commodity: const AlertCommodity(id: 11, name: 'Banana'),
        market: const AlertMarket(id: 73, name: 'Wayanad Mandi'),
        price: const AlertPrice(current: 3450.0, previous: 3150.0, changePercent: 9.52),
        createdAt: day2Ago,
      ),
      Alert(
        id: 107,
        type: AlertTypes.aiRecommendation,
        severity: 'LOW',
        title: 'AI Advisory: Best day to sell Tapioca',
        message: 'Market indicators suggest selling Tapioca tomorrow at Kollam Mandi for maximum profitability.',
        commodity: const AlertCommodity(id: 56, name: 'Tapioca'),
        market: const AlertMarket(id: 29, name: 'Kollam Mandi'),
        price: null,
        createdAt: day3Ago,
      ),
      Alert(
        id: 108,
        type: AlertTypes.priceDrop,
        severity: 'LOW',
        title: 'Ginger price moderate decline',
        message: 'Ginger prices declined by 4.5% in Alappuzha Mandi due to steady supply.',
        commodity: const AlertCommodity(id: 67, name: 'Ginger'),
        market: const AlertMarket(id: 18, name: 'Alappuzha Mandi'),
        price: const AlertPrice(current: 6300.0, previous: 6600.0, changePercent: -4.55),
        createdAt: day4Ago,
      ),
      Alert(
        id: 109,
        type: AlertTypes.priceIncrease,
        severity: 'HIGH',
        title: 'Cardamom prices soared',
        message: 'Cardamom price recorded a sharp 18.5% rise in Idukki Mandi.',
        commodity: const AlertCommodity(id: 82, name: 'Cardamom'),
        market: const AlertMarket(id: 35, name: 'Idukki Mandi'),
        price: const AlertPrice(current: 14500.0, previous: 12235.0, changePercent: 18.51),
        createdAt: day5Ago,
      ),
    ];
  }

  Future<PaginatedAlertsResponse> getAlerts({
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    // Artificial small delay for realistic fallback UX
    await Future.delayed(const Duration(milliseconds: 150));

    List<Alert> filtered = _generateMockAlerts()
        .where((alert) => alert.type != 'MARKET_GLUT')
        .toList();

    if (type != null && type.isNotEmpty && type != 'ALL') {
      filtered = filtered.where((a) => a.type == type).toList();
    }

    // Sort by createdAt descending
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final total = filtered.length;
    final startIndex = (page - 1) * pageSize;

    if (startIndex >= total) {
      return PaginatedAlertsResponse(
        items: [],
        page: page,
        pageSize: pageSize,
        total: total,
      );
    }

    final endIndex = (startIndex + pageSize < total) ? startIndex + pageSize : total;
    final pagedItems = filtered.sublist(startIndex, endIndex);

    return PaginatedAlertsResponse(
      items: pagedItems,
      page: page,
      pageSize: pageSize,
      total: total,
    );
  }

  Future<PaginatedAlertsResponse> getAlertHistory({
    String? type,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    List<Alert> filtered = _generateMockAlerts()
        .where((alert) => alert.type != 'MARKET_GLUT')
        .toList();

    if (type != null && type.isNotEmpty && type != 'ALL') {
      filtered = filtered.where((a) => a.type == type).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((a) {
        return a.title.toLowerCase().contains(q) ||
            a.message.toLowerCase().contains(q) ||
            a.commodity.name.toLowerCase().contains(q) ||
            a.market.name.toLowerCase().contains(q);
      }).toList();
    }

    if (dateFrom != null && dateFrom.isNotEmpty) {
      final fromDt = DateTime.tryParse(dateFrom);
      if (fromDt != null) {
        final startOfDay = DateTime(fromDt.year, fromDt.month, fromDt.day);
        filtered = filtered.where((a) => a.createdAt.isAfter(startOfDay) || a.createdAt.isAtSameMomentAs(startOfDay)).toList();
      }
    }

    if (dateTo != null && dateTo.isNotEmpty) {
      final toDt = DateTime.tryParse(dateTo);
      if (toDt != null) {
        final endOfDay = DateTime(toDt.year, toDt.month, toDt.day, 23, 59, 59);
        filtered = filtered.where((a) => a.createdAt.isBefore(endOfDay) || a.createdAt.isAtSameMomentAs(endOfDay)).toList();
      }
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final total = filtered.length;
    final startIndex = (page - 1) * pageSize;

    if (startIndex >= total) {
      return PaginatedAlertsResponse(
        items: [],
        page: page,
        pageSize: pageSize,
        total: total,
      );
    }

    final endIndex = (startIndex + pageSize < total) ? startIndex + pageSize : total;
    final pagedItems = filtered.sublist(startIndex, endIndex);

    return PaginatedAlertsResponse(
      items: pagedItems,
      page: page,
      pageSize: pageSize,
      total: total,
    );
  }
}
