// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appName => 'മണ്ഡി ഇന്റലിജൻസ്';

  @override
  String get alertsScreen => 'അലർട്ടുകൾ';

  @override
  String get help => 'സഹായം';

  @override
  String get somethingWentWrong => 'അയ്യോ, എന്തോ കുഴപ്പമുണ്ടല്ലോ!';

  @override
  String get tryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get noPricesFound => 'വിലകൾ ലഭ്യമാക്കാനായില്ല';

  @override
  String get noPricesFoundSubtitle => 'നിങ്ങൾ തിരഞ്ഞെടുത്തവയ്ക്ക് മാർക്കറ്റ് വിലകളൊന്നും കണ്ടെത്താനായില്ല.';

  @override
  String get loadingPrices => 'വിലകൾ ലോഡ് ചെയ്യുന്നു...';

  @override
  String get search => 'തിരയുക...';

  @override
  String get noOptionsFound => 'ഓപ്ഷനുകളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get high => 'കൂടിയത്';

  @override
  String get modal => 'മോഡൽ';

  @override
  String get low => 'കുറഞ്ഞത്';

  @override
  String get home => 'ഹോം';

  @override
  String get markets => 'മാർക്കറ്റുകൾ';

  @override
  String get alerts => 'അലർട്ടുകൾ';

  @override
  String get forecasts => 'പ്രവചനങ്ങൾ';

  @override
  String get profile => 'പ്രൊഫൈൽ';

  @override
  String get justNow => 'ഇപ്പോൾ';

  @override
  String minutesAgo(Object count) {
    return '$count മിനിറ്റ് മുമ്പ്';
  }

  @override
  String hoursAgo(Object count) {
    return '$count മണിക്കൂർ മുമ്പ്';
  }

  @override
  String get yesterday => 'ഇന്നലെ';

  @override
  String daysAgo(Object count) {
    return '$count ദിവസം മുമ്പ്';
  }

  @override
  String weeksAgo(Object count) {
    return '$count ആഴ്ച മുമ്പ്';
  }

  @override
  String monthsAgo(Object count) {
    return '$count മാസം മുമ്പ്';
  }

  @override
  String lastUpdated(Object relativeTime) {
    return 'അവസാനം അപ്ഡേറ്റ് ചെയ്തത്: $relativeTime';
  }

  @override
  String get commodity => 'ഉൽപ്പന്നം';

  @override
  String get state => 'സംസ്ഥാനം';

  @override
  String get district => 'ജില്ല';

  @override
  String get market => 'മാർക്കറ്റ്';

  @override
  String get applyFilters => 'ഫിൽറ്ററുകൾ പ്രയോഗിക്കുക';

  @override
  String get clearAll => 'എല്ലാം മായ്‌ക്കുക';

  @override
  String get marketDirectory => 'മാർക്കറ്റ് ഡയറക്‌ടറി';

  @override
  String get selectState => 'സംസ്ഥാനം തിരഞ്ഞെടുക്കുക';

  @override
  String get selectDistrict => 'ജില്ല തിരഞ്ഞെടുക്കുക';

  @override
  String get loadingStates => 'സംസ്ഥാനങ്ങൾ ലോഡ് ചെയ്യുന്നു...';

  @override
  String get errorLoadingStates => 'സംസ്ഥാനങ്ങൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്';

  @override
  String get selectStateFirst => 'ആദ്യം സംസ്ഥാനം തിരഞ്ഞെടുക്കുക';

  @override
  String get allDistricts => 'എല്ലാ ജില്ലകളും';

  @override
  String get loadingDistricts => 'ജില്ലകൾ ലോഡ് ചെയ്യുന്നു...';

  @override
  String get errorLoadingDistricts => 'ജില്ലകൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്';

  @override
  String get searchMarkets => 'മാർക്കറ്റുകൾ തിരയുക...';

  @override
  String get marketDirectoryIntro => 'ലഭ്യമായ മാർക്കറ്റുകൾ കാണാൻ ഒരു സംസ്ഥാനം തിരഞ്ഞെടുക്കുക.\nനിങ്ങൾക്ക് ജില്ല തിരിച്ച് ഫിൽട്ടർ ചെയ്യാനും പ്രത്യേക മാർക്കറ്റുകൾക്കായി തിരയാനും കഴിയും.';

  @override
  String get noMarketsFound => 'മാർക്കറ്റുകളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String marketsFound(Object count) {
    return '$count മാർക്കറ്റുകൾ കണ്ടെത്തി';
  }

  @override
  String get filterResults => 'ഫലങ്ങൾ ഫിൽട്ടർ ചെയ്യുക';

  @override
  String resultsFound(Object count) {
    return '$count ഫലങ്ങൾ കണ്ടെത്തി';
  }

  @override
  String activeFilters(Object count) {
    return '$count സജീവ ഫിൽറ്ററുകൾ';
  }

  @override
  String get variety => 'ഇനം';

  @override
  String get currentPricePerQuintal => 'നിലവിലെ വില / ക്വിന്റൽ';

  @override
  String get viewDetails => 'കൂടുതൽ വിവരങ്ങൾ';

  @override
  String get noPreviewAvailable => 'പ്രിവ്യൂ ലഭ്യമല്ല';

  @override
  String get priceSummary => 'വില വിവരണം';

  @override
  String get trendNote => '*ഏറ്റവും പഴയ റെക്കോർഡുമായി താരതമ്യം ചെയ്യുമ്പോൾ വിലയിലുള്ള മൊത്തത്തിലുള്ള മാറ്റത്തെയാണ് ട്രെൻഡ് സൂചിപ്പിക്കുന്നത്.';

  @override
  String get highPrice => 'ഉയർന്ന വില';

  @override
  String get modalPrice => 'മോഡൽ വില';

  @override
  String get lowPrice => 'കുറഞ്ഞ വില';

  @override
  String get noHistoricalDataAvailable => 'പഴയ ഡാറ്റകളൊന്നും ലഭ്യമല്ല';

  @override
  String get recentTrend => 'സമീപകാല ട്രെൻഡ്';

  @override
  String recentRecordsMissingDates(Object count) {
    return '$count സമീപകാല റെക്കോർഡുകൾ • ചില തീയതികൾ നഷ്‌ടപ്പെട്ടിട്ടുണ്ടാകാം';
  }

  @override
  String get modalPricePerQuintal => 'മോഡൽ വില (₹/ക്വിന്റൽ)';

  @override
  String get dates => 'തീയതികൾ';

  @override
  String get failedToLoadCommodities => 'ഉൽപ്പന്നങ്ങൾ ലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു';

  @override
  String get marketInformation => 'മാർക്കറ്റ് വിവരങ്ങൾ';

  @override
  String get availableCommoditiesToday => 'ഇന്ന് ലഭ്യമായ ഉൽപ്പന്നങ്ങൾ';

  @override
  String get todaysCommodities => 'ഇന്നത്തെ ഉൽപ്പന്നങ്ങൾ';

  @override
  String get noCommoditiesAvailableToday => 'ഇന്ന് ഉൽപ്പന്നങ്ങളൊന്നും ലഭ്യമല്ല';

  @override
  String errorWithDetails(Object error) {
    return 'പിശക്: $error';
  }

  @override
  String get user => 'ഉപയോക്താവ്';

  @override
  String get editProfile => 'പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യുക';

  @override
  String get logout => 'ലോഗ് ഔട്ട്';

  @override
  String get personalInformation => 'വ്യക്തിഗത വിവരങ്ങൾ';

  @override
  String get preferredCrops => 'താൽപ്പര്യമുള്ള വിളകൾ';

  @override
  String get noPreferredCropsSelected => 'താൽപ്പര്യമുള്ള വിളകളൊന്നും തിരഞ്ഞെടുത്തിട്ടില്ല.';

  @override
  String get completeProfileDescription => 'നിങ്ങൾക്ക് അനുയോജ്യമായ മണ്ഡി വിലകളും വിള നിർദ്ദേശങ്ങളും മാർക്കറ്റ് അലർട്ടുകളും ലഭിക്കാൻ നിങ്ങളുടെ പ്രൊഫൈൽ പൂർത്തിയാക്കുക.';

  @override
  String failedToUpdateProfile(Object error) {
    return 'പ്രൊഫൈൽ അപ്ഡേറ്റ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get saveChanges => 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക';

  @override
  String get continueLabel => 'തുടരുക';

  @override
  String get preferredLanguage => 'താൽപ്പര്യമുള്ള ഭാഷ';

  @override
  String get selectLanguage => 'ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get chooseUpTo5Crops => 'പരമാവധി 5 വിളകൾ വരെ തിരഞ്ഞെടുക്കുക.';

  @override
  String get searchCrops => 'വിളകൾ തിരയുക...';

  @override
  String get maxPreferredCrops => 'നിങ്ങൾക്ക് പരമാവധി 5 വിളകൾ മാത്രമേ തിരഞ്ഞെടുക്കാൻ കഴിയൂ.';

  @override
  String get english => 'ഇംഗ്ലീഷ്';

  @override
  String get malayalam => 'മലയാളം';

  @override
  String get hindi => 'ഹിന്ദി';

  @override
  String get login => 'ലോഗിൻ';

  @override
  String get loggingIn => 'ലോഗിൻ ചെയ്യുന്നു...';

  @override
  String get signup => 'സൈൻ അപ്പ്';

  @override
  String get liveMandiPrices => 'തത്സമയ മണ്ഡി വിലകൾ';

  @override
  String get language => 'ഭാഷ';

  @override
  String get setupProfile => 'പ്രൊഫൈൽ സെറ്റപ്പ് ചെയ്യുക';

  @override
  String get skip => 'സ്കിപ്പ് ചെയ്യുക';

  @override
  String get updateProfile => 'നിങ്ങളുടെ പ്രൊഫൈൽ അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get finishProfile => 'പ്രൊഫൈൽ സെറ്റപ്പ് പൂർത്തിയാക്കുക';
}
