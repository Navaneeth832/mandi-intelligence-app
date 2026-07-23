// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'मंडी इंटेलिजेंस';

  @override
  String get alertsScreen => 'अलर्ट';

  @override
  String get help => 'सहायता';

  @override
  String get somethingWentWrong => 'ओह, कुछ गलत हो गया!';

  @override
  String get tryAgain => 'फिर से प्रयास करें';

  @override
  String get noPricesFound => 'कोई भाव नहीं मिला';

  @override
  String get noPricesFoundSubtitle => 'हमें आपके वर्तमान चयन के लिए कोई मंडी भाव नहीं मिला।';

  @override
  String get loadingPrices => 'भाव लोड हो रहे हैं...';

  @override
  String get search => 'खोजें...';

  @override
  String get noOptionsFound => 'कोई विकल्प नहीं मिला';

  @override
  String get high => 'अधिकतम';

  @override
  String get modal => 'मॉडल';

  @override
  String get low => 'न्यूनतम';

  @override
  String get home => 'होम';

  @override
  String get markets => 'मंडियां';

  @override
  String get alerts => 'अलर्ट';

  @override
  String get forecasts => 'पूर्वानुमान';

  @override
  String get yourPreferredCrops => 'आपकी पसंदीदा फसलें';

  @override
  String get mockData => 'नकली डेटा';

  @override
  String get forecastsAreSimulated => 'पूर्वानुमान सिम्युलेटेड हैं।';

  @override
  String get currentPriceLabel => 'वर्तमान मूल्य';

  @override
  String get trendLabel => 'रुझान';

  @override
  String get recommendationLabel => 'अनुशंसा';

  @override
  String get bestSellingDayLabel => 'बेचने का सबसे अच्छा दिन';

  @override
  String get expectedPeakPriceLabel => 'अनुमानित उच्चतम मूल्य';

  @override
  String get viewForecastLabel => 'पूर्वानुमान देखें';

  @override
  String get dailyForecastLabel => 'दैनिक पूर्वानुमान';

  @override
  String get noPreferredCropsSelectedForecasts => 'कोई पसंदीदा फसलें नहीं चुनी गईं। पूर्वानुमान प्राप्त करने के लिए अपनी प्रोफ़ाइल से अपनी पसंदीदा फसलें चुनें।';

  @override
  String get retryLabel => 'पुनः प्रयास करें';

  @override
  String get loadingLabel => 'लोड हो रहा है...';

  @override
  String get sellTodayLabel => 'आज ही बेचें';

  @override
  String get waitLabel => 'प्रतीक्षा करें';

  @override
  String get holdLabel => 'होल्ड करें';

  @override
  String get risingLabel => 'बढ़ रहा है';

  @override
  String get fallingLabel => 'गिर रहा है';

  @override
  String get stableLabel => 'स्थिर';

  @override
  String get predictionDateLabel => 'पूर्वानुमान तिथि';

  @override
  String get predictionTimeLabel => 'पूर्वानुमान समय';

  @override
  String get latestPredictionLabel => 'नवीनतम पूर्वानुमान';

  @override
  String get noForecastsAvailable => 'कोई पूर्वानुमान उपलब्ध नहीं है';

  @override
  String get forecastUpdated => 'पूर्वानुमान अपडेट किया गया';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get justNow => 'अभी-अभी';

  @override
  String minutesAgo(Object count) {
    return '$count मिनट पहले';
  }

  @override
  String hoursAgo(Object count) {
    return '$count घंटे पहले';
  }

  @override
  String get yesterday => 'कल';

  @override
  String daysAgo(Object count) {
    return '$count दिन पहले';
  }

  @override
  String weeksAgo(Object count) {
    return '$count सप्ताह पहले';
  }

  @override
  String monthsAgo(Object count) {
    return '$count महीने पहले';
  }

  @override
  String lastUpdated(Object relativeTime) {
    return 'अंतिम अपडेट: $relativeTime';
  }

  @override
  String get commodity => 'फसल';

  @override
  String get state => 'राज्य';

  @override
  String get district => 'ज़िला';

  @override
  String get market => 'मंडी';

  @override
  String get applyFilters => 'फ़िल्टर लागू करें';

  @override
  String get clearAll => 'सभी साफ़ करें';

  @override
  String get marketDirectory => 'मंडी निर्देशिका';

  @override
  String get selectState => 'राज्य चुनें';

  @override
  String get selectDistrict => 'ज़िला चुनें';

  @override
  String get loadingStates => 'राज्य लोड हो रहे हैं...';

  @override
  String get errorLoadingStates => 'राज्य लोड करने में त्रुटि';

  @override
  String get selectStateFirst => 'पहले राज्य चुनें';

  @override
  String get allDistricts => 'सभी ज़िले';

  @override
  String get loadingDistricts => 'ज़िले लोड हो रहे हैं...';

  @override
  String get errorLoadingDistricts => 'ज़िले लोड करने में त्रुटि';

  @override
  String get searchMarkets => 'मंडियां खोजें...';

  @override
  String get marketDirectoryIntro => 'उपलब्ध मंडियां देखने के लिए राज्य चुनें।\nआप ज़िले के अनुसार फ़िल्टर कर सकते हैं और विशिष्ट मंडियां खोज सकते हैं।';

  @override
  String get noMarketsFound => 'कोई मंडी नहीं मिली';

  @override
  String marketsFound(Object count) {
    return '$count मंडियां मिलीं';
  }

  @override
  String get filterResults => 'परिणाम फ़िल्टर करें';

  @override
  String resultsFound(Object count) {
    return '$count परिणाम मिले';
  }

  @override
  String activeFilters(Object count) {
    return '$count सक्रिय फ़िल्टर';
  }

  @override
  String get variety => 'किस्म';

  @override
  String get grade => 'श्रेणी';

  @override
  String get currentPricePerQuintal => 'वर्तमान भाव / क्विंटल';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get noPreviewAvailable => 'कोई पूर्वावलोकन उपलब्ध नहीं है';

  @override
  String get priceSummary => 'भाव सारांश';

  @override
  String get trendNote => '*ट्रेंड सबसे पुराने उपलब्ध ऐतिहासिक रिकॉर्ड की तुलना में समग्र मूल्य परिवर्तन को दर्शाता है।';

  @override
  String get highPrice => 'अधिकतम भाव';

  @override
  String get modalPrice => 'मॉडल भाव';

  @override
  String get lowPrice => 'न्यूनतम भाव';

  @override
  String get noHistoricalDataAvailable => 'कोई ऐतिहासिक डेटा उपलब्ध नहीं है';

  @override
  String get recentTrend => 'हालिया ट्रेंड';

  @override
  String recentRecordsMissingDates(Object count) {
    return '$count हालिया रिकॉर्ड • कुछ तारीखें गायब हो सकती हैं';
  }

  @override
  String get modalPricePerQuintal => 'मॉडल भाव (₹/क्विंटल)';

  @override
  String get dates => 'तारीखें';

  @override
  String get failedToLoadCommodities => 'फसलें लोड करने में विफल';

  @override
  String get marketInformation => 'मंडी की जानकारी';

  @override
  String get availableCommoditiesToday => 'आज उपलब्ध फसलें';

  @override
  String get todaysCommodities => 'आज की फसलें';

  @override
  String get noCommoditiesAvailableToday => 'आज कोई फसल उपलब्ध नहीं है';

  @override
  String errorWithDetails(Object error) {
    return 'त्रुटि: $error';
  }

  @override
  String get user => 'उपयोगकर्ता';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get personalInformation => 'व्यक्तिगत जानकारी';

  @override
  String get preferredCrops => 'पसंदीदा फसलें';

  @override
  String get noPreferredCropsSelected => 'कोई पसंदीदा फसल नहीं चुनी गई।';

  @override
  String get completeProfileDescription => 'वैयक्तिकृत मंडी भाव, फसल संबंधी सुझाव और मार्केट अलर्ट पाने के लिए अपनी प्रोफ़ाइल पूरी करें।';

  @override
  String failedToUpdateProfile(Object error) {
    return 'प्रोफ़ाइल अपडेट करने में विफल: $error';
  }

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get preferredLanguage => 'पसंदीदा भाषा';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get chooseUpTo5Crops => 'अधिकतम 5 फसलें चुनें।';

  @override
  String get searchCrops => 'फसलें खोजें...';

  @override
  String get maxPreferredCrops => 'आप अधिकतम 5 पसंदीदा फसलें चुन सकते हैं।';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get malayalam => 'मलयालम';

  @override
  String get hindi => 'हिंदी';

  @override
  String get login => 'लॉगिन';

  @override
  String get loggingIn => 'लॉगिन हो रहा है...';

  @override
  String get signup => 'साइन अप';

  @override
  String get liveMandiPrices => 'लाइव मंडी भाव';

  @override
  String get language => 'भाषा';

  @override
  String get setupProfile => 'प्रोफ़ाइल सेटअप करें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get updateProfile => 'अपनी प्रोफ़ाइल अपडेट करें';

  @override
  String get finishProfile => 'प्रोफ़ाइल सेटअप पूरा करें';

  @override
  String get expectedPriceTrajectory => 'अगले 7 दिनों के लिए अपेक्षित मूल्य उतार-चढ़ाव';

  @override
  String get detailedPriceForecasts => 'आगामी 7 दिनों में से प्रत्येक के लिए विस्तृत मूल्य पूर्वानुमान';

  @override
  String get advisory => 'सलाह (Advisory)';

  @override
  String get exploreOtherMarketsCommodities => 'अन्य बाज़ार / फसलें खोजें';

  @override
  String get bestMarkets => 'सर्वश्रेष्ठ बाज़ार';

  @override
  String get explorePlaceholderTitle => 'अन्य बाज़ार खोजें';

  @override
  String get explorePlaceholderMessage => 'बाज़ार और फ़सलों की विस्तृत खोज सुविधा आगामी अपडेट में उपलब्ध होगी।';

  @override
  String get sevenDayTrendChart => '7-दिन का ट्रेंड चार्ट';

  @override
  String get marketsSortedByHighestPredictedPrice => 'आपके जिले के बाजार उच्चतम अनुमानित मूल्य के अनुसार क्रमबद्ध';
}
