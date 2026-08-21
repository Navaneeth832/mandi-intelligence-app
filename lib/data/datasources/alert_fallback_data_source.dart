import '../models/alert_model.dart';

class AlertFallbackDataSource {
  static List<Alert> _generateMockAlerts([String? lang]) {
    final language = (lang ?? 'en').toLowerCase();
    final now = DateTime.now();

    final todayMorning = DateTime(now.year, now.month, now.day, 9, 30);
    final todayNoon = DateTime(now.year, now.month, now.day, 12, 15);
    final yesterdayAfternoon = now.subtract(const Duration(days: 1, hours: 2));
    final yesterdayMorning = now.subtract(const Duration(days: 1, hours: 6));
    final day2Ago = now.subtract(const Duration(days: 2));
    final day3Ago = now.subtract(const Duration(days: 3));
    final day4Ago = now.subtract(const Duration(days: 4));
    final day5Ago = now.subtract(const Duration(days: 5));

    if (language == 'hi') {
      return [
        Alert(
          id: 101,
          type: AlertTypes.priceIncrease,
          severity: 'HIGH',
          title: 'टमाटर की कीमत में वृद्धि',
          message: 'मांग में वृद्धि के कारण त्रिशूर मंडी में टमाटर की कीमतों में 14.29% की वृद्धि हुई है।',
          commodity: const AlertCommodity(id: 19, name: 'टमाटर'),
          market: const AlertMarket(id: 52, name: 'त्रिशूर मंडी'),
          price: const AlertPrice(current: 2800.0, previous: 2450.0, changePercent: 14.29),
          createdAt: todayNoon,
        ),
        Alert(
          id: 102,
          type: AlertTypes.betterMarket,
          severity: 'MEDIUM',
          title: 'नारियल के लिए बेहतर बाजार उपलब्ध',
          message: 'कोझीकोड मंडी में स्थानीय बाजार की तुलना में नारियल की कीमतें 12.5% अधिक मिल रही हैं।',
          commodity: const AlertCommodity(id: 42, name: 'नारियल'),
          market: const AlertMarket(id: 88, name: 'कोझीकोड मंडी'),
          price: const AlertPrice(current: 3150.0, previous: 2800.0, changePercent: 12.50),
          createdAt: todayMorning,
        ),
        Alert(
          id: 103,
          type: AlertTypes.aiRecommendation,
          severity: 'HIGH',
          title: 'एआई सलाह: आलू की बिक्री रोकें',
          message: 'एआई मॉडल पालक्काड मंडी में 3 दिनों के भीतर आलू की कीमतों में 15% उछाल की भविष्यवाणी करते हैं।',
          commodity: const AlertCommodity(id: 15, name: 'आलू'),
          market: const AlertMarket(id: 61, name: 'पालक्काड मंडी'),
          price: null,
          createdAt: yesterdayAfternoon,
        ),
        Alert(
          id: 104,
          type: AlertTypes.priceDrop,
          severity: 'HIGH',
          title: 'प्याज की कीमत में गिरावट',
          message: 'ताजा आवक के बाद कोझीकोड मंडी में प्याज की मॉडल कीमत 8.33% गिर गई है।',
          commodity: const AlertCommodity(id: 24, name: 'प्याज'),
          market: const AlertMarket(id: 88, name: 'कोझीकोड मंडी'),
          price: const AlertPrice(current: 2200.0, previous: 2400.0, changePercent: -8.33),
          createdAt: yesterdayMorning,
        ),
        Alert(
          id: 105,
          type: AlertTypes.priceIncrease,
          severity: 'MEDIUM',
          title: 'हरी मिर्च की कीमत में उछाल',
          message: 'एर्नाकुलम मंडी में हरी मिर्च की कीमत 10.0% बढ़ गई है।',
          commodity: const AlertCommodity(id: 31, name: 'हरी मिर्च'),
          market: const AlertMarket(id: 44, name: 'एर्नाकुलम मंडी'),
          price: const AlertPrice(current: 4400.0, previous: 4000.0, changePercent: 10.00),
          createdAt: day2Ago,
        ),
        Alert(
          id: 106,
          type: AlertTypes.betterMarket,
          severity: 'MEDIUM',
          title: 'केले के लिए उच्च भुगतान',
          message: 'वायनाड मंडी में नेन्द्रन केले का भाव क्षेत्रीय औसत से 9.5% अधिक है।',
          commodity: const AlertCommodity(id: 11, name: 'केला'),
          market: const AlertMarket(id: 73, name: 'वायनाड मंडी'),
          price: const AlertPrice(current: 3450.0, previous: 3150.0, changePercent: 9.52),
          createdAt: day2Ago,
        ),
        Alert(
          id: 107,
          type: AlertTypes.aiRecommendation,
          severity: 'LOW',
          title: 'एआई सलाह: टैपिओका बेचने का सही समय',
          message: 'अधिकतम लाभप्रदता के लिए कोल्लम मंडी में कल टैपिओका बेचने का सुझाव दिया जाता है।',
          commodity: const AlertCommodity(id: 56, name: 'टैपिओका'),
          market: const AlertMarket(id: 29, name: 'कोल्लम मंडी'),
          price: null,
          createdAt: day3Ago,
        ),
        Alert(
          id: 108,
          type: AlertTypes.priceDrop,
          severity: 'LOW',
          title: 'अदरक की कीमत में हल्की गिरावट',
          message: 'स्थिर आपूर्ति के कारण अलप्पुझा मंडी में अदरक की कीमतें 4.5% घटी हैं।',
          commodity: const AlertCommodity(id: 67, name: 'अदरक'),
          market: const AlertMarket(id: 18, name: 'अलप्पुझा मंडी'),
          price: const AlertPrice(current: 6300.0, previous: 6600.0, changePercent: -4.55),
          createdAt: day4Ago,
        ),
        Alert(
          id: 109,
          type: AlertTypes.priceIncrease,
          severity: 'HIGH',
          title: 'इलायची की कीमतों में भारी उछाल',
          message: 'इडुक्की मंडी में इलायची की कीमत में 18.5% की तेज वृद्धि दर्ज की गई।',
          commodity: const AlertCommodity(id: 82, name: 'इलायची'),
          market: const AlertMarket(id: 35, name: 'इडुक्की मंडी'),
          price: const AlertPrice(current: 14500.0, previous: 12235.0, changePercent: 18.51),
          createdAt: day5Ago,
        ),
      ];
    } else if (language == 'ml') {
      return [
        Alert(
          id: 101,
          type: AlertTypes.priceIncrease,
          severity: 'HIGH',
          title: 'തക്കാളി വില വർദ്ധിച്ചു',
          message: 'തൃശ്ശൂർ മണ്ടിയിൽ തക്കാളിയുടെ വില 14.29% വർദ്ധിച്ചു.',
          commodity: const AlertCommodity(id: 19, name: 'തക്കാളി'),
          market: const AlertMarket(id: 52, name: 'തൃശ്ശൂർ മണ്ടി'),
          price: const AlertPrice(current: 2800.0, previous: 2450.0, changePercent: 14.29),
          createdAt: todayNoon,
        ),
        Alert(
          id: 102,
          type: AlertTypes.betterMarket,
          severity: 'MEDIUM',
          title: 'തേങ്ങയ്ക്ക് മികച്ച വില ലഭ്യമാണ്',
          message: 'കോഴിക്കോട് മണ്ടിയിൽ തേങ്ങ വിൽക്കാൻ 12.5% മികച്ച അവസരമുണ്ട്.',
          commodity: const AlertCommodity(id: 42, name: 'തേങ്ങ'),
          market: const AlertMarket(id: 88, name: 'കോഴിക്കോട് മണ്ടി'),
          price: const AlertPrice(current: 3150.0, previous: 2800.0, changePercent: 12.50),
          createdAt: todayMorning,
        ),
        Alert(
          id: 103,
          type: AlertTypes.aiRecommendation,
          severity: 'HIGH',
          title: 'വിൽപ്പന നിർദ്ദേശം: ഉരുളക്കിഴങ്ങ് കരുതിവെയ്ക്കുക',
          message: 'പാലക്കാട് മണ്ടിയിൽ ഉരുളക്കിഴങ്ങിന് വില ഉയർന്നേക്കാം. അഡ്വൈസറി ടാബ് പരിശോധിക്കുക.',
          commodity: const AlertCommodity(id: 15, name: 'ഉരുളക്കിഴങ്ങ്'),
          market: const AlertMarket(id: 61, name: 'പാലക്കാട് മണ്ടി'),
          price: null,
          createdAt: yesterdayAfternoon,
        ),
        Alert(
          id: 104,
          type: AlertTypes.priceDrop,
          severity: 'HIGH',
          title: 'ഉള്ളി വില കുറഞ്ഞു',
          message: 'കോഴിക്കോട് മണ്ടിയിൽ ഉള്ളിയുടെ വില 8.33% കുറഞ്ഞു.',
          commodity: const AlertCommodity(id: 24, name: 'ഉള്ളി'),
          market: const AlertMarket(id: 88, name: 'കോഴിക്കോട് മണ്ടി'),
          price: const AlertPrice(current: 2200.0, previous: 2400.0, changePercent: -8.33),
          createdAt: yesterdayMorning,
        ),
        Alert(
          id: 105,
          type: AlertTypes.priceIncrease,
          severity: 'MEDIUM',
          title: 'പച്ചമുളക് വില വർദ്ധിച്ചു',
          message: 'എറണാകുളം മണ്ടിയിൽ പച്ചമുളകിന്റെ വില 10.0% വർദ്ധിച്ചു.',
          commodity: const AlertCommodity(id: 31, name: 'പച്ചമുളക്'),
          market: const AlertMarket(id: 44, name: 'എറണാകുളം മണ്ടി'),
          price: const AlertPrice(current: 4400.0, previous: 4000.0, changePercent: 10.00),
          createdAt: day2Ago,
        ),
        Alert(
          id: 106,
          type: AlertTypes.betterMarket,
          severity: 'MEDIUM',
          title: 'നേന്ത്രപ്പഴത്തിന് ഉയർന്ന വില',
          message: 'വയനാട് മണ്ടിയിൽ നേന്ത്രപ്പഴത്തിന് 9.5% ഉയർന്ന വില ലഭിക്കുന്നു.',
          commodity: const AlertCommodity(id: 11, name: 'നേന്ത്രപ്പഴം'),
          market: const AlertMarket(id: 73, name: 'വയനാട് മണ്ടി'),
          price: const AlertPrice(current: 3450.0, previous: 3150.0, changePercent: 9.52),
          createdAt: day2Ago,
        ),
        Alert(
          id: 107,
          type: AlertTypes.aiRecommendation,
          severity: 'LOW',
          title: 'വിൽപ്പന നിർദ്ദേശം: മരച്ചീനി',
          message: 'കൊല്ലം മണ്ടിയിൽ മരച്ചീനി വില മാറാൻ സാധ്യതയുണ്ട്. അഡ്വൈസറി ടാബ് പരിശോധിക്കുക.',
          commodity: const AlertCommodity(id: 56, name: 'മരച്ചീനി'),
          market: const AlertMarket(id: 29, name: 'കൊല്ലം മണ്ടി'),
          price: null,
          createdAt: day3Ago,
        ),
        Alert(
          id: 108,
          type: AlertTypes.priceDrop,
          severity: 'LOW',
          title: 'ഇഞ്ചി വില കുറഞ്ഞു',
          message: 'ആലപ്പുഴ മണ്ടിയിൽ ഇഞ്ചിയുടെ വില 4.5% കുറഞ്ഞു.',
          commodity: const AlertCommodity(id: 67, name: 'ഇഞ്ചി'),
          market: const AlertMarket(id: 18, name: 'ആലപ്പുഴ മണ്ടി'),
          price: const AlertPrice(current: 6300.0, previous: 6600.0, changePercent: -4.55),
          createdAt: day4Ago,
        ),
        Alert(
          id: 109,
          type: AlertTypes.priceIncrease,
          severity: 'HIGH',
          title: 'ഏലം വില വർദ്ധിച്ചു',
          message: 'ഇടുക്കി മണ്ടിയിൽ ഏലത്തിന്റെ വില 18.5% വർദ്ധിച്ചു.',
          commodity: const AlertCommodity(id: 82, name: 'ഏലം'),
          market: const AlertMarket(id: 35, name: 'ഇടുക്കി മണ്ടി'),
          price: const AlertPrice(current: 14500.0, previous: 12235.0, changePercent: 18.51),
          createdAt: day5Ago,
        ),
      ];
    }

    // Default English
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
        price: null,
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
    String? language,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    List<Alert> filtered = _generateMockAlerts(language)
        .where((alert) => alert.type != 'MARKET_GLUT')
        .toList();

    if (type != null && type.isNotEmpty && type != 'ALL') {
      filtered = filtered.where((a) => a.type == type).toList();
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

  Future<PaginatedAlertsResponse> getAlertHistory({
    String? type,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? language,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    List<Alert> filtered = _generateMockAlerts(language)
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
