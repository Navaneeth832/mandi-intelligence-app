import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ml')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Mandi Intelligence'**
  String get appName;

  /// No description provided for @alertsScreen.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsScreen;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oh no, something went wrong!'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noPricesFound.
  ///
  /// In en, this message translates to:
  /// **'No Prices Found'**
  String get noPricesFound;

  /// No description provided for @noPricesFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any market prices for your current selection.'**
  String get noPricesFoundSubtitle;

  /// No description provided for @loadingPrices.
  ///
  /// In en, this message translates to:
  /// **'Loading prices...'**
  String get loadingPrices;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @noOptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No options found'**
  String get noOptionsFound;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @modal.
  ///
  /// In en, this message translates to:
  /// **'Modal'**
  String get modal;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @markets.
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get markets;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @forecasts.
  ///
  /// In en, this message translates to:
  /// **'Forecasts'**
  String get forecasts;

  /// No description provided for @yourPreferredCrops.
  ///
  /// In en, this message translates to:
  /// **'Your preferred crops'**
  String get yourPreferredCrops;

  /// No description provided for @mockData.
  ///
  /// In en, this message translates to:
  /// **'MOCK DATA'**
  String get mockData;

  /// No description provided for @forecastsAreSimulated.
  ///
  /// In en, this message translates to:
  /// **'Forecasts are simulated.'**
  String get forecastsAreSimulated;

  /// No description provided for @currentPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get currentPriceLabel;

  /// No description provided for @trendLabel.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendLabel;

  /// No description provided for @recommendationLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendationLabel;

  /// No description provided for @bestSellingDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Best Selling Day'**
  String get bestSellingDayLabel;

  /// No description provided for @expectedPeakPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected Peak Price'**
  String get expectedPeakPriceLabel;

  /// No description provided for @viewForecastLabel.
  ///
  /// In en, this message translates to:
  /// **'View Forecast'**
  String get viewForecastLabel;

  /// No description provided for @dailyForecastLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Forecast'**
  String get dailyForecastLabel;

  /// No description provided for @noPreferredCropsSelectedForecasts.
  ///
  /// In en, this message translates to:
  /// **'No preferred crops selected. Select your preferred crops from your profile to receive forecasts.'**
  String get noPreferredCropsSelectedForecasts;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// No description provided for @sellTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'SELL TODAY'**
  String get sellTodayLabel;

  /// No description provided for @waitLabel.
  ///
  /// In en, this message translates to:
  /// **'WAIT'**
  String get waitLabel;

  /// No description provided for @holdLabel.
  ///
  /// In en, this message translates to:
  /// **'HOLD'**
  String get holdLabel;

  /// No description provided for @risingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rising'**
  String get risingLabel;

  /// No description provided for @fallingLabel.
  ///
  /// In en, this message translates to:
  /// **'Falling'**
  String get fallingLabel;

  /// No description provided for @stableLabel.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stableLabel;

  /// No description provided for @predictionDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Prediction Date'**
  String get predictionDateLabel;

  /// No description provided for @predictionTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Prediction Time'**
  String get predictionTimeLabel;

  /// No description provided for @latestPredictionLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest Prediction'**
  String get latestPredictionLabel;

  /// No description provided for @noForecastsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No forecasts available'**
  String get noForecastsAvailable;

  /// No description provided for @forecastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Forecast updated'**
  String get forecastUpdated;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} mins ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(Object count);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String weeksAgo(Object count);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String monthsAgo(Object count);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {relativeTime}'**
  String lastUpdated(Object relativeTime);

  /// No description provided for @commodity.
  ///
  /// In en, this message translates to:
  /// **'Commodity'**
  String get commodity;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @marketDirectory.
  ///
  /// In en, this message translates to:
  /// **'Market Directory'**
  String get marketDirectory;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @loadingStates.
  ///
  /// In en, this message translates to:
  /// **'Loading states...'**
  String get loadingStates;

  /// No description provided for @errorLoadingStates.
  ///
  /// In en, this message translates to:
  /// **'Error loading states'**
  String get errorLoadingStates;

  /// No description provided for @selectStateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select state first'**
  String get selectStateFirst;

  /// No description provided for @allDistricts.
  ///
  /// In en, this message translates to:
  /// **'All Districts'**
  String get allDistricts;

  /// No description provided for @loadingDistricts.
  ///
  /// In en, this message translates to:
  /// **'Loading districts...'**
  String get loadingDistricts;

  /// No description provided for @errorLoadingDistricts.
  ///
  /// In en, this message translates to:
  /// **'Error loading districts'**
  String get errorLoadingDistricts;

  /// No description provided for @searchMarkets.
  ///
  /// In en, this message translates to:
  /// **'Search markets...'**
  String get searchMarkets;

  /// No description provided for @marketDirectoryIntro.
  ///
  /// In en, this message translates to:
  /// **'Select a state to browse available markets.\nYou can further filter by district and search for specific markets.'**
  String get marketDirectoryIntro;

  /// No description provided for @noMarketsFound.
  ///
  /// In en, this message translates to:
  /// **'No markets found'**
  String get noMarketsFound;

  /// No description provided for @marketsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} Markets Found'**
  String marketsFound(Object count);

  /// No description provided for @filterResults.
  ///
  /// In en, this message translates to:
  /// **'Filter Results'**
  String get filterResults;

  /// No description provided for @resultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} Results Found'**
  String resultsFound(Object count);

  /// No description provided for @activeFilters.
  ///
  /// In en, this message translates to:
  /// **'{count} Active Filters'**
  String activeFilters(Object count);

  /// No description provided for @variety.
  ///
  /// In en, this message translates to:
  /// **'Variety'**
  String get variety;

  /// No description provided for @currentPricePerQuintal.
  ///
  /// In en, this message translates to:
  /// **'Current Price / Quintal'**
  String get currentPricePerQuintal;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @noPreviewAvailable.
  ///
  /// In en, this message translates to:
  /// **'No preview available'**
  String get noPreviewAvailable;

  /// No description provided for @priceSummary.
  ///
  /// In en, this message translates to:
  /// **'Price Summary'**
  String get priceSummary;

  /// No description provided for @trendNote.
  ///
  /// In en, this message translates to:
  /// **'*Trend indicates the overall price shift compared to the oldest available historic record.'**
  String get trendNote;

  /// No description provided for @highPrice.
  ///
  /// In en, this message translates to:
  /// **'High Price'**
  String get highPrice;

  /// No description provided for @modalPrice.
  ///
  /// In en, this message translates to:
  /// **'Modal Price'**
  String get modalPrice;

  /// No description provided for @lowPrice.
  ///
  /// In en, this message translates to:
  /// **'Low Price'**
  String get lowPrice;

  /// No description provided for @noHistoricalDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No historical data available'**
  String get noHistoricalDataAvailable;

  /// No description provided for @recentTrend.
  ///
  /// In en, this message translates to:
  /// **'Recent Trend'**
  String get recentTrend;

  /// No description provided for @recentRecordsMissingDates.
  ///
  /// In en, this message translates to:
  /// **'{count} recent records • Missing dates may exist'**
  String recentRecordsMissingDates(Object count);

  /// No description provided for @modalPricePerQuintal.
  ///
  /// In en, this message translates to:
  /// **'Modal Price (₹/Quintal)'**
  String get modalPricePerQuintal;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get dates;

  /// No description provided for @failedToLoadCommodities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load commodities'**
  String get failedToLoadCommodities;

  /// No description provided for @marketInformation.
  ///
  /// In en, this message translates to:
  /// **'Market Information'**
  String get marketInformation;

  /// No description provided for @availableCommoditiesToday.
  ///
  /// In en, this message translates to:
  /// **'Available Commodities Today'**
  String get availableCommoditiesToday;

  /// No description provided for @todaysCommodities.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Commodities'**
  String get todaysCommodities;

  /// No description provided for @noCommoditiesAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'No commodities available today'**
  String get noCommoditiesAvailableToday;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(Object error);

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @preferredCrops.
  ///
  /// In en, this message translates to:
  /// **'Preferred Crops'**
  String get preferredCrops;

  /// No description provided for @noPreferredCropsSelected.
  ///
  /// In en, this message translates to:
  /// **'No preferred crops selected.'**
  String get noPreferredCropsSelected;

  /// No description provided for @completeProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to receive personalized mandi prices, crop recommendations, and market alerts.'**
  String get completeProfileDescription;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedToUpdateProfile(Object error);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @preferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get preferredLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @chooseUpTo5Crops.
  ///
  /// In en, this message translates to:
  /// **'Choose up to 5 crops.'**
  String get chooseUpTo5Crops;

  /// No description provided for @searchCrops.
  ///
  /// In en, this message translates to:
  /// **'Search crops...'**
  String get searchCrops;

  /// No description provided for @maxPreferredCrops.
  ///
  /// In en, this message translates to:
  /// **'You can select a maximum of 5 preferred crops.'**
  String get maxPreferredCrops;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get malayalam;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @liveMandiPrices.
  ///
  /// In en, this message translates to:
  /// **'Live Mandi Prices'**
  String get liveMandiPrices;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @setupProfile.
  ///
  /// In en, this message translates to:
  /// **'Setup Profile'**
  String get setupProfile;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Your Profile'**
  String get updateProfile;

  /// No description provided for @finishProfile.
  ///
  /// In en, this message translates to:
  /// **'Finish Setting Up Your Profile'**
  String get finishProfile;

  /// No description provided for @expectedPriceTrajectory.
  ///
  /// In en, this message translates to:
  /// **'Expected price trajectory for next 7 days'**
  String get expectedPriceTrajectory;

  /// No description provided for @detailedPriceForecasts.
  ///
  /// In en, this message translates to:
  /// **'Detailed price forecasts for each of the upcoming 7 days'**
  String get detailedPriceForecasts;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'ml': return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
