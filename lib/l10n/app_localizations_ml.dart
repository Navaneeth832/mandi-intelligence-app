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
  String get alertsScreen => 'അലേർട്ടുകൾ';

  @override
  String get help => 'സഹായം';

  @override
  String get somethingWentWrong => 'അയ്യോ, എന്തോ പിഴച്ചു!';

  @override
  String get tryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get noPricesFound => 'വിലകൾ ലഭിച്ചില്ല';

  @override
  String get noPricesFoundSubtitle => 'നിങ്ങൾ തെരഞ്ഞെടുത്തതിനായി വിപണി വിലകൾ ലഭിച്ചില്ല.';

  @override
  String get loadingPrices => 'വിലകൾ ലോഡ് ചെയ്യുന്നു...';

  @override
  String get search => 'തിരയുക...';

  @override
  String get noOptionsFound => 'ഓപ്ഷനുകൾ ലഭിച്ചില്ല';

  @override
  String get high => 'ഉയർന്നത്';

  @override
  String get modal => 'മോഡൽ';

  @override
  String get low => 'കുറഞ്ഞത്';

  @override
  String get home => 'ഹോം';

  @override
  String get markets => 'മാർക്കറ്റുകൾ';

  @override
  String get alerts => 'അലേർട്ടുകൾ';

  @override
  String get profile => 'പ്രൊഫൈൽ';

  @override
  String get justNow => 'ഇപ്പോൾ മാത്രം';

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
    return 'അവസാനം പുതുക്കിയത്: $relativeTime';
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
  String get applyFilters => 'ഫിൽട്ടറുകൾ പ്രയോഗിക്കുക';

  @override
  String get clearAll => 'എല്ലാം മായ്ക്കുക';

  @override
  String get marketDirectory => 'മാർക്കറ്റ് ഡയറക്ടറി';

  @override
  String get selectState => 'സംസ്ഥാനം തിരഞ്ഞെടുക്കുക';

  @override
  String get selectDistrict => 'Select District';

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
  String get marketDirectoryIntro => 'ലഭ്യമായ മാർക്കറ്റുകൾ കാണാൻ ഒരു സംസ്ഥാനം തിരഞ്ഞെടുക്കുക.\nജില്ലപ്രകാരവും പ്രത്യേക മാർക്കറ്റുകളും തിരയാം.';

  @override
  String get noMarketsFound => 'മാർക്കറ്റുകൾ ലഭിച്ചില്ല';

  @override
  String marketsFound(Object count) {
    return '$count മാർക്കറ്റുകൾ ലഭിച്ചു';
  }

  @override
  String get filterResults => 'ഫിൽട്ടർ ഫലങ്ങൾ';

  @override
  String resultsFound(Object count) {
    return '$count ഫലങ്ങൾ ലഭിച്ചു';
  }

  @override
  String activeFilters(Object count) {
    return '$count സജീവ ഫിൽട്ടറുകൾ';
  }

  @override
  String get variety => 'വൈവിധ്യം';

  @override
  String get currentPricePerQuintal => 'നിലവിലെ വില / ക്വിന്റൽ';

  @override
  String get viewDetails => 'വിശദാംശങ്ങൾ കാണുക';

  @override
  String get noPreviewAvailable => 'പ്രിവ്യൂ ലഭ്യമല്ല';

  @override
  String get priceSummary => 'വില സംഗ്രഹം';

  @override
  String get trendNote => '*ട്രെൻഡ് ഏറ്റവും പഴയ ലഭ്യമായ ചരിത്രരേഖയുമായി താരതമ്യം ചെയ്തുള്ള മൊത്തം വിലമാറ്റം കാണിക്കുന്നു.';

  @override
  String get highPrice => 'ഉയർന്ന വില';

  @override
  String get modalPrice => 'മോഡൽ വില';

  @override
  String get lowPrice => 'കുറഞ്ഞ വില';

  @override
  String get noHistoricalDataAvailable => 'ചരിത്ര ഡാറ്റ ലഭ്യമല്ല';

  @override
  String get recentTrend => 'സമീപകാല പ്രവണതി';

  @override
  String recentRecordsMissingDates(Object count) {
    return '$count സമീപകാല രേഖകൾ • ചില തീയതികൾ ഇല്ലായിരിക്കാം';
  }

  @override
  String get modalPricePerQuintal => 'മോഡൽ വില (₹/ക്വിന്റൽ)';

  @override
  String get dates => 'തീയതികൾ';

  @override
  String get failedToLoadCommodities => 'ഉൽപ്പന്നങ്ങൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല';

  @override
  String get marketInformation => 'മാർക്കറ്റ് വിവരങ്ങൾ';

  @override
  String get availableCommoditiesToday => 'ഇന്നത്തെ ലഭ്യമായ ഉൽപ്പന്നങ്ങൾ';

  @override
  String get todaysCommodities => 'ഇന്നത്തെ ഉൽപ്പന്നങ്ങൾ';

  @override
  String get noCommoditiesAvailableToday => 'ഇന്ന് ഉൽപ്പന്നങ്ങൾ ലഭ്യമല്ല';

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
  String get preferredCrops => 'ഇഷ്ടപ്പെട്ട വിളകൾ';

  @override
  String get noPreferredCropsSelected => 'ഇഷ്ടപ്പെട്ട വിളകൾ തിരഞ്ഞെടുക്കപ്പെട്ടിട്ടില്ല.';

  @override
  String get completeProfileDescription => 'നിങ്ങളുടെ പ്രൊഫൈൽ പൂർത്തിയാക്കി വ്യക്തിഗത മാർക്കറ്റ് വിലകളും വിള നിർദ്ദേശങ്ങളും അലർട്ടുകളും നേടുക.';

  @override
  String failedToUpdateProfile(Object error) {
    return 'പ്രൊഫൈൽ അപ്ഡേറ്റ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get saveChanges => 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക';

  @override
  String get continueLabel => 'തുടരുക';

  @override
  String get preferredLanguage => 'ഇഷ്ടമുള്ള ഭാഷ';

  @override
  String get selectLanguage => 'ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get chooseUpTo5Crops => 'പരമാവധി 5 വിളകൾ തിരഞ്ഞെടുക്കാം.';

  @override
  String get searchCrops => 'വിളകൾ തിരയുക...';

  @override
  String get maxPreferredCrops => 'പരമാവധി 5 ഇഷ്ടപ്പെട്ട വിളകൾ മാത്രം തിരഞ്ഞെടുക്കാം.';

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
  String get liveMandiPrices => 'തത്സമയ മണ്ടി വിലകൾ';

  @override
  String get language => 'ഭാഷ';

  @override
  String get setupProfile => 'പ്രൊഫൈൽ സജ്ജമാക്കുക';

  @override
  String get skip => 'ഒഴിവാക്കുക';

  @override
  String get updateProfile => 'നിങ്ങളുടെ പ്രൊഫൈൽ അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get finishProfile => 'പ്രൊഫൈൽ സജ്ജീകരണം പൂർത്തിയാക്കുക';
}
