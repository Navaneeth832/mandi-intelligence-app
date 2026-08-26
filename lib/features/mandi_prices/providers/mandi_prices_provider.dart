import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/data/models/state_model.dart';
import '../../../data/models/mandi_price.dart';
import '../../../data/models/market_directory_model.dart';
import '../../../data/repositories/mandi_repository.dart';
import '../../../data/services/mandi_api_service.dart';
import '../../../data/models/district_model.dart';
import '../../../data/models/commodity_model.dart';
import '../../../data/models/market_model.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/providers.dart';
import 'filter_model.dart';

// Provider for the ApiService
final apiServiceProvider = Provider<MandiApiService>((ref) {
  return MandiApiService();
});

// Provider for the Repository
final mandiRepositoryProvider = Provider<MandiRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final cacheService = ref.watch(localCacheServiceProvider).valueOrNull;
  return MandiRepository(apiService, cacheService: cacheService);
});

// --- MANDI PRICES PROVIDER (Existing) ---
class MandiPricesState {
  final List<MandiPrice> items;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final bool isLoadingMore;
  final bool hasMorePages;
  final bool isFromCache;
  final DateTime? cachedAt;

  MandiPricesState({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.isLoadingMore,
    required this.hasMorePages,
    this.isFromCache = false,
    this.cachedAt,
  });

  MandiPricesState copyWith({
    List<MandiPrice>? items,
    int? currentPage,
    int? totalPages,
    int? totalRecords,
    bool? isLoadingMore,
    bool? hasMorePages,
    bool? isFromCache,
    DateTime? cachedAt,
  }) {
    return MandiPricesState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isFromCache: isFromCache ?? this.isFromCache,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

class MandiPricesNotifier extends StateNotifier<AsyncValue<MandiPricesState>> {
  final MandiRepository _repository;
  final Filter _filter;
  final String _language;

  MandiPricesNotifier(this._repository, this._filter, this._language) : super(const AsyncValue.loading()) {
    loadInitialPage();
  }

  Future<void> loadInitialPage() async {
    // Check if cached data exists for zero-latency instant render
    final cachedResult = await _repository.getCachedMandiPrices(_filter, page: 1, pageSize: 50, language: _language);
    if (cachedResult != null && cachedResult.data.data.isNotEmpty) {
      state = AsyncValue.data(MandiPricesState(
        items: cachedResult.data.data,
        currentPage: cachedResult.data.page,
        totalPages: cachedResult.data.totalPages,
        totalRecords: cachedResult.data.totalRecords,
        isLoadingMore: false,
        hasMorePages: cachedResult.data.page < cachedResult.data.totalPages,
        isFromCache: true,
        cachedAt: cachedResult.cachedAt,
      ));
    } else {
      state = const AsyncValue.loading();
    }

    try {
      final response = await _repository.getMandiPrices(
        _filter,
        page: 1,
        language: _language,
        fallbackToCache: false,
      );
      state = AsyncValue.data(MandiPricesState(
        items: response.data,
        currentPage: response.page,
        totalPages: response.totalPages,
        totalRecords: response.totalRecords,
        isLoadingMore: false,
        hasMorePages: response.page < response.totalPages,
        isFromCache: false,
        cachedAt: DateTime.now(),
      ));
    } catch (err, stack) {
      if (state.hasValue && state.value!.items.isNotEmpty) {
        // Keep cached state visible if background API refresh failed!
        return;
      }
      final fallbackCache = await _repository.getCachedMandiPrices(_filter, page: 1, pageSize: 50, language: _language);
      if (fallbackCache != null && fallbackCache.data.data.isNotEmpty) {
        state = AsyncValue.data(MandiPricesState(
          items: fallbackCache.data.data,
          currentPage: fallbackCache.data.page,
          totalPages: fallbackCache.data.totalPages,
          totalRecords: fallbackCache.data.totalRecords,
          isLoadingMore: false,
          hasMorePages: fallbackCache.data.page < fallbackCache.data.totalPages,
          isFromCache: true,
          cachedAt: fallbackCache.cachedAt,
        ));
      } else {
        state = AsyncValue.error(err, stack);
      }
    }
  }

  Future<void> loadNextPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMorePages) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final response = await _repository.getMandiPrices(_filter, page: nextPage, language: _language);

      state = AsyncValue.data(MandiPricesState(
        items: [...currentState.items, ...response.data],
        currentPage: response.page,
        totalPages: response.totalPages,
        totalRecords: response.totalRecords,
        isLoadingMore: false,
        hasMorePages: response.page < response.totalPages,
        isFromCache: false,
        cachedAt: DateTime.now(),
      ));
    } catch (err, stack) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }
}

final mandiPricesProvider = StateNotifierProvider.family<MandiPricesNotifier, AsyncValue<MandiPricesState>, Filter>((ref, filter) {
  final repository = ref.watch(mandiRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final language = locale.languageCode;
  return MandiPricesNotifier(repository, filter, language);
});

// --- MARKET DIRECTORY PROVIDER (Updated) ---
class MarketDirectoryState {
  final List<MarketDirectory> items;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final bool isLoadingMore;
  final bool hasMorePages;

  MarketDirectoryState({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.isLoadingMore,
    required this.hasMorePages,
  });

  MarketDirectoryState copyWith({
    List<MarketDirectory>? items,
    int? currentPage,
    int? totalPages,
    int? totalRecords,
    bool? isLoadingMore,
    bool? hasMorePages,
  }) {
    return MarketDirectoryState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

class MarketDirectoryNotifier extends StateNotifier<AsyncValue<MarketDirectoryState>> {
  final MandiRepository _repository;
  final int? stateId;
  final int? districtId;
  final int? commodityId;
  final String? search;
  final String _language;

  MarketDirectoryNotifier(this._repository, this.stateId, this.districtId, this.commodityId, this.search, this._language) : super(const AsyncValue.loading()) {
    loadInitialPage();
  }

  Future<void> loadInitialPage() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getMarketDirectory(stateId, districtId, commodityId, search: search, page: 1, language: _language);
      state = AsyncValue.data(MarketDirectoryState(
        items: response.data,
        currentPage: response.page,
        totalPages: response.totalPages,
        totalRecords: response.totalRecords,
        isLoadingMore: false,
        hasMorePages: response.page < response.totalPages,
      ));
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> loadNextPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMorePages) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final response = await _repository.getMarketDirectory(stateId, districtId, commodityId, search: search, page: nextPage, language: _language);

      state = AsyncValue.data(MarketDirectoryState(
        items: [...currentState.items, ...response.data],
        currentPage: response.page,
        totalPages: response.totalPages,
        totalRecords: response.totalRecords,
        isLoadingMore: false,
        hasMorePages: response.page < response.totalPages,
      ));
    } catch (err, stack) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }
}

final marketDirectoryProvider = StateNotifierProvider.family<
    MarketDirectoryNotifier,
    AsyncValue<MarketDirectoryState>,
    ({int? stateId, int? districtId, int? commodityId, String? search})>((ref, filter) {
  final repository = ref.watch(mandiRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final language = locale.languageCode;
  return MarketDirectoryNotifier(repository, filter.stateId, filter.districtId, filter.commodityId, filter.search, language);
});

// --- HELPER PROVIDERS (Updated) ---
final statesProvider =
    FutureProvider<List<StateModel>>((ref) {
  final repository =
      ref.watch(mandiRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final language = locale.languageCode;

  return repository.getStates(language: language);
});

final commoditiesProvider =
    FutureProvider<List<Commodity>>((ref) {
  final repository =
      ref.watch(mandiRepositoryProvider);

  return repository.getCommodities();
});

final activeCommoditiesProvider =
    FutureProvider<List<Commodity>>((ref) {
  return ref.read(mandiRepositoryProvider).getActiveCommodities();
});

final allCommoditiesProvider =
    FutureProvider<List<Commodity>>((ref) {
  return ref.read(mandiRepositoryProvider).getAllCommodities();
});

final commodityListProvider = FutureProvider<List<String>>((ref) async {
  final locale = ref.watch(localeProvider);
  final commodities = await ref.watch(commoditiesProvider.future);
  return commodities.map((c) => c.getDisplayName(locale.languageCode)).toList();
});

final marketsProvider =
    FutureProvider.family<
        List<String>,
        int?>((ref, districtId) {

  final repository =
      ref.watch(mandiRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final language = locale.languageCode;

  return repository.getMarkets(
    districtId,
    language: language,
  );
});

final marketsListProvider =
    FutureProvider.family<
        List<Market>,
        int?>((ref, districtId) {

  final repository =
      ref.watch(mandiRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final language = locale.languageCode;

  return repository.getMarketsList(
    districtId,
    language: language,
  );
});

final allMarketsListProvider =
    FutureProvider.family<
        List<Market>,
        int?>((ref, districtId) {

  final repository =
      ref.watch(mandiRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final language = locale.languageCode;

  return repository.getAllMarketsList(
    districtId,
    language: language,
  );
});

final districtsProvider =
    FutureProvider.family<
        List<District>,
        int?>((ref, stateId) {

  final repository =
      ref.watch(mandiRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final language = locale.languageCode;

  return repository.getDistricts(
    stateId: stateId,
    language: language,
  );
});
