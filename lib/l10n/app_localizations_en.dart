// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mandi Intelligence';

  @override
  String get alertsScreen => 'Alerts';

  @override
  String get help => 'Help';

  @override
  String get somethingWentWrong => 'Oh no, something went wrong!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noPricesFound => 'No Prices Found';

  @override
  String get noPricesFoundSubtitle => 'We couldn\'t find any market prices for your current selection.';

  @override
  String get loadingPrices => 'Loading prices...';

  @override
  String get search => 'Search...';

  @override
  String get noOptionsFound => 'No options found';

  @override
  String get high => 'High';

  @override
  String get modal => 'Modal';

  @override
  String get low => 'Low';

  @override
  String get home => 'Home';

  @override
  String get markets => 'Markets';

  @override
  String get alerts => 'Alerts';

  @override
  String get forecasts => 'Forecasts';

  @override
  String get yourPreferredCrops => 'Your preferred crops';

  @override
  String get mockData => 'MOCK DATA';

  @override
  String get forecastsAreSimulated => 'Forecasts are simulated.';

  @override
  String get currentPriceLabel => 'Current Price';

  @override
  String get trendLabel => 'Trend';

  @override
  String get recommendationLabel => 'Recommendation';

  @override
  String get bestSellingDayLabel => 'Best Selling Day';

  @override
  String get expectedPeakPriceLabel => 'Expected Peak Price';

  @override
  String get viewForecastLabel => 'View Forecast';

  @override
  String get dailyForecastLabel => 'Daily Forecast';

  @override
  String get noPreferredCropsSelectedForecasts => 'No preferred crops selected. Select your preferred crops from your profile to receive forecasts.';

  @override
  String get retryLabel => 'Retry';

  @override
  String get loadingLabel => 'Loading...';

  @override
  String get sellTodayLabel => 'SELL TODAY';

  @override
  String get waitLabel => 'WAIT';

  @override
  String get holdLabel => 'HOLD';

  @override
  String get risingLabel => 'Rising';

  @override
  String get fallingLabel => 'Falling';

  @override
  String get stableLabel => 'Stable';

  @override
  String get predictionDateLabel => 'Prediction Date';

  @override
  String get predictionTimeLabel => 'Prediction Time';

  @override
  String get latestPredictionLabel => 'Latest Prediction';

  @override
  String get noForecastsAvailable => 'No forecasts available';

  @override
  String get forecastUpdated => 'Forecast updated';

  @override
  String get profile => 'Profile';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object count) {
    return '$count mins ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count hours ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String weeksAgo(Object count) {
    return '$count weeks ago';
  }

  @override
  String monthsAgo(Object count) {
    return '$count months ago';
  }

  @override
  String lastUpdated(Object relativeTime) {
    return 'Last updated: $relativeTime';
  }

  @override
  String get commodity => 'Commodity';

  @override
  String get state => 'State';

  @override
  String get district => 'District';

  @override
  String get market => 'Market';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get clearAll => 'Clear All';

  @override
  String get marketDirectory => 'Market Directory';

  @override
  String get selectState => 'Select State';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get loadingStates => 'Loading states...';

  @override
  String get errorLoadingStates => 'Error loading states';

  @override
  String get selectStateFirst => 'Select state first';

  @override
  String get allDistricts => 'All Districts';

  @override
  String get loadingDistricts => 'Loading districts...';

  @override
  String get errorLoadingDistricts => 'Error loading districts';

  @override
  String get searchMarkets => 'Search markets...';

  @override
  String get marketDirectoryIntro => 'Select a state to browse available markets.\nYou can further filter by district and search for specific markets.';

  @override
  String get noMarketsFound => 'No markets found';

  @override
  String marketsFound(Object count) {
    return '$count Markets Found';
  }

  @override
  String get filterResults => 'Filter Results';

  @override
  String resultsFound(Object count) {
    return '$count Results Found';
  }

  @override
  String activeFilters(Object count) {
    return '$count Active Filters';
  }

  @override
  String get variety => 'Variety';

  @override
  String get grade => 'Grade';

  @override
  String get currentPricePerQuintal => 'Current Price / Quintal';

  @override
  String get viewDetails => 'View Details';

  @override
  String get noPreviewAvailable => 'No preview available';

  @override
  String get priceSummary => 'Price Summary';

  @override
  String get trendNote => '*Trend indicates the overall price shift compared to the oldest available historic record.';

  @override
  String get highPrice => 'High Price';

  @override
  String get modalPrice => 'Modal Price';

  @override
  String get lowPrice => 'Low Price';

  @override
  String get noHistoricalDataAvailable => 'No historical data available';

  @override
  String get recentTrend => 'Recent Trend';

  @override
  String recentRecordsMissingDates(Object count) {
    return '$count recent records • Missing dates may exist';
  }

  @override
  String get modalPricePerQuintal => 'Modal Price (₹/Quintal)';

  @override
  String get dates => 'Dates';

  @override
  String get failedToLoadCommodities => 'Failed to load commodities';

  @override
  String get marketInformation => 'Market Information';

  @override
  String get availableCommoditiesToday => 'Available Commodities Today';

  @override
  String get todaysCommodities => 'Today\'s Commodities';

  @override
  String get noCommoditiesAvailableToday => 'No commodities available today';

  @override
  String errorWithDetails(Object error) {
    return 'Error: $error';
  }

  @override
  String get user => 'User';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get logout => 'Logout';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get preferredCrops => 'Preferred Crops';

  @override
  String get noPreferredCropsSelected => 'No preferred crops selected.';

  @override
  String get completeProfileDescription => 'Complete your profile to receive personalized mandi prices, crop recommendations, and market alerts.';

  @override
  String failedToUpdateProfile(Object error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get continueLabel => 'Continue';

  @override
  String get preferredLanguage => 'Preferred Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get chooseUpTo5Crops => 'Choose up to 5 crops.';

  @override
  String get searchCrops => 'Search crops...';

  @override
  String get maxPreferredCrops => 'You can select a maximum of 5 preferred crops.';

  @override
  String get english => 'English';

  @override
  String get malayalam => 'Malayalam';

  @override
  String get hindi => 'Hindi';

  @override
  String get login => 'Login';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get signup => 'Sign Up';

  @override
  String get liveMandiPrices => 'Live Mandi Prices';

  @override
  String get language => 'Language';

  @override
  String get setupProfile => 'Setup Profile';

  @override
  String get skip => 'Skip';

  @override
  String get updateProfile => 'Update Your Profile';

  @override
  String get finishProfile => 'Finish Setting Up Your Profile';

  @override
  String get expectedPriceTrajectory => 'Expected price trajectory for next 7 days';

  @override
  String get detailedPriceForecasts => 'Detailed price forecasts for each of the upcoming 7 days';

  @override
  String get advisory => 'Advisory';

  @override
  String get exploreOtherMarketsCommodities => 'Explore Other Markets / Commodities';

  @override
  String get bestMarkets => 'Best Markets';

  @override
  String get explorePlaceholderTitle => 'Explore Other Markets';

  @override
  String get explorePlaceholderMessage => 'Browse and exploration features will be available in a future update.';

  @override
  String get sevenDayTrendChart => '7-Day Trend Chart';

  @override
  String get marketsSortedByHighestPredictedPrice => 'Markets in your district sorted by highest predicted price';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle => 'Enter your registered email or mobile number to receive an OTP.';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get sendingOtp => 'Sending OTP...';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get verifyingOtp => 'Verifying OTP...';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resettingPassword => 'Resetting Password...';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordResetSuccess => 'Password reset successfully! Please login with your new password.';

  @override
  String get enterRegisteredIdentifier => 'Please enter your registered email or mobile number';

  @override
  String get exploreMoreCommodities => 'Explore More Commodities';

  @override
  String get exploreAdvisoryResults => 'Explore Advisory Results';

  @override
  String get selectCommodities => 'Select Commodities';

  @override
  String get selectMarkets => 'Select Markets';

  @override
  String get showAdvisory => 'Show Advisory';

  @override
  String get allActiveCommodities => 'All Active Commodities';

  @override
  String get pleaseSelectCommodity => 'Please select at least one commodity';

  @override
  String get noForecastsInDistrict => 'No forecasts available for your district';

  @override
  String get noForecastsInDistrictSubtitle => 'You can explore market prices for this crop across other districts & states in India.';

  @override
  String get exploreOtherMarketsButton => 'Explore Other Markets';
}
