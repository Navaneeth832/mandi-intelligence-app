import 'package:shared_preferences/shared_preferences.dart';
import '../models/cache/cached_entry.dart';
import '../../features/mandi_prices/providers/filter_model.dart';

class LocalCacheService {
  static LocalCacheService? _instance;
  SharedPreferences? _prefs;

  LocalCacheService._();

  static Future<LocalCacheService> getInstance() async {
    if (_instance == null) {
      _instance = LocalCacheService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveCache(String key, String jsonContent) async {
    await _init();
    await _prefs?.setString('cache_data_$key', jsonContent);
    await _prefs?.setString('cache_time_$key', DateTime.now().toIso8601String());
  }

  Future<CachedEntry?> getCache(String key) async {
    await _init();
    final jsonContent = _prefs?.getString('cache_data_$key');
    final timeStr = _prefs?.getString('cache_time_$key');

    if (jsonContent != null && timeStr != null) {
      final cachedAt = DateTime.tryParse(timeStr) ?? DateTime.now();
      return CachedEntry(
        cacheKey: key,
        rawJson: jsonContent,
        cachedAt: cachedAt,
      );
    }
    return null;
  }

  Future<void> clearCache(String key) async {
    await _init();
    await _prefs?.remove('cache_data_$key');
    await _prefs?.remove('cache_time_$key');
  }

  // --- CACHE KEY BUILDERS ---
  static String buildMandiPricesKey(
    Filter filter, {
    int page = 1,
    int pageSize = 50,
    String? language,
  }) {
    final cropStr = filter.crop ?? '';
    final stateStr = filter.state ?? '';
    final distStr = filter.district ?? '';
    final mktStr = filter.market ?? '';
    final langStr = language ?? '';
    return 'mandi_prices_state=${stateStr}_dist=${distStr}_mkt=${mktStr}_crop=${cropStr}_lang=${langStr}_p=${page}_ps=${pageSize}';
  }

  static String buildStatesKey(String? language) {
    return 'states_lang=${language ?? ''}';
  }

  static String buildDistrictsKey(String? state, int? stateId, String? language) {
    return 'districts_state=${state ?? ''}_id=${stateId ?? ''}_lang=${language ?? ''}';
  }

  static String buildMarketsKey(int? districtId, String? language) {
    return 'markets_distId=${districtId ?? ''}_lang=${language ?? ''}';
  }

  static String buildCommoditiesKey(String type) {
    return 'commodities_type=$type';
  }

  static String buildUserProfileKey() {
    return 'user_profile';
  }

  static String buildPreferredCropsKey() {
    return 'preferred_crops';
  }
}
