import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/mandi_price.dart';
import '../../../data/models/paginated_mandi_response.dart';
import '../../../data/repositories/mandi_repository.dart';
import '../../../data/services/mandi_api_service.dart';
import '../../../data/models/district_model.dart';
import 'filter_model.dart';

// Provider for the ApiService
final apiServiceProvider = Provider<MandiApiService>((ref) {
  return MandiApiService();
});

// Provider for the Repository
final mandiRepositoryProvider = Provider<MandiRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MandiRepository(apiService);
});

class MandiPricesState {
  final List<MandiPrice> items;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool hasMorePages;

  MandiPricesState({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.isLoadingMore,
    required this.hasMorePages,
  });

  MandiPricesState copyWith({
    List<MandiPrice>? items,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? hasMorePages,
  }) {
    return MandiPricesState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

class MandiPricesNotifier extends StateNotifier<AsyncValue<MandiPricesState>> {
  final MandiRepository _repository;
  final Filter _filter;

  MandiPricesNotifier(this._repository, this._filter) : super(const AsyncValue.loading()) {
    loadInitialPage();
  }

  Future<void> loadInitialPage() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getMandiPrices(_filter, page: 1);
      state = AsyncValue.data(MandiPricesState(
        items: response.data,
        currentPage: response.page,
        totalPages: response.totalPages,
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
      final response = await _repository.getMandiPrices(_filter, page: nextPage);

      state = AsyncValue.data(MandiPricesState(
        items: [...currentState.items, ...response.data],
        currentPage: response.page,
        totalPages: response.totalPages,
        isLoadingMore: false,
        hasMorePages: response.page < response.totalPages,
      ));
    } catch (err, stack) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }
}

// StateNotifierProvider to manage and fetch mandi prices
final mandiPricesProvider = StateNotifierProvider.family<MandiPricesNotifier, AsyncValue<MandiPricesState>, Filter>((ref, filter) {
  final repository = ref.watch(mandiRepositoryProvider);
  return MandiPricesNotifier(repository, filter);
});

final statesProvider =
    FutureProvider<List<String>>((ref) {
  final repository =
      ref.watch(mandiRepositoryProvider);

  return repository.getStates();
});

final commoditiesProvider =
    FutureProvider<List<String>>((ref) {
  final repository =
      ref.watch(mandiRepositoryProvider);

  return repository.getCommodities();
});

final marketsProvider =
    FutureProvider.family<
        List<String>,
        int?>((ref, districtId) {

  final repository =
      ref.watch(mandiRepositoryProvider);

  return repository.getMarkets(
    districtId,
  );
});

final districtsProvider =
    FutureProvider.family<
        List<District>,
        String?>((ref, state) {

  final repository =
      ref.watch(mandiRepositoryProvider);

  return repository.getDistricts(
    state,
  );
});