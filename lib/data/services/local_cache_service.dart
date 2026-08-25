import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cache/cached_entry.dart';
import '../../features/mandi_prices/providers/filter_model.dart';

class LocalCacheService {
  static LocalCacheService? _instance;
  static Isar? _isar;

  LocalCacheService._();

  static Future<LocalCacheService> getInstance() async {
    if (_instance == null) {
      _instance = LocalCacheService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    if (_isar != null && _isar!.isOpen) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [CachedEntrySchema],
        directory: dir.path,
        name: 'mandi_cache',
      );
    } catch (e) {
      // If Isar fails to open or is already open
      _isar = Isar.getInstance('mandi_cache');
    }
  }

  Future<void> saveCache(String key, String jsonContent) async {
    if (_isar == null || !_isar!.isOpen) await _init();
    final isar = _isar;
    if (isar == null) return;

    final entry = CachedEntry()
      ..cacheKey = key
      ..rawJson = jsonContent
      ..cachedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.cachedEntrys.putByCacheKey(entry);
    });
  }

  Future<CachedEntry?> getCache(String key) async {
    if (_isar == null || !_isar!.isOpen) await _init();
    final isar = _isar;
    if (isar == null) return null;

    return await isar.cachedEntrys.getByCacheKey(key);
  }

  Future<void> clearCache(String key) async {
    if (_isar == null || !_isar!.isOpen) await _init();
    final isar = _isar;
    if (isar == null) return;

    await isar.writeTxn(() async {
      await isar.cachedEntrys.deleteByCacheKey(key);
    });
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
