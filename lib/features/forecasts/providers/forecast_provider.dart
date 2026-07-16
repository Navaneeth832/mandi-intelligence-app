import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../data/repositories/forecast_repository.dart';
import '../../../data/models/forecast_model.dart';
import '../../auth/providers/profile_notifier.dart';
import '../../../data/models/commodity_model.dart';
import '../../mandi_prices/providers/mandi_prices_provider.dart';

class ForecastsFilterState {
  final int? commodityId;
  final int? marketId;

  const ForecastsFilterState({this.commodityId, this.marketId});

  ForecastsFilterState copyWith({
    int? Function()? commodityId,
    int? Function()? marketId,
  }) {
    return ForecastsFilterState(
      commodityId: commodityId != null ? commodityId() : this.commodityId,
      marketId: marketId != null ? marketId() : this.marketId,
    );
  }
}

final forecastsFilterProvider = StateProvider<ForecastsFilterState>((ref) {
  return const ForecastsFilterState();
});

final preferredCommoditiesProvider = FutureProvider<List<Commodity>>((ref) async {
  final prefs = await ref.watch(preferredCropsNotifierProvider.future);
  final allCrops = await ref.watch(allCommoditiesProvider.future);
  
  return allCrops.where(
    (Commodity c) => prefs.any((p) => p['commodity_id'] == c.id),
  ).toList();
});

final forecastRepositoryProvider = Provider<ForecastRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForecastRepository(authRepository);
});

final forecastsNotifierProvider = AutoDisposeAsyncNotifierProvider<ForecastsNotifier, PaginatedForecastResponse>(() {
  return ForecastsNotifier();
});

class ForecastsNotifier extends AutoDisposeAsyncNotifier<PaginatedForecastResponse> {
  @override
  Future<PaginatedForecastResponse> build() async {
    // Watch filters, preferred crops, and selected locale so that forecasts reload dynamically.
    final filter = ref.watch(forecastsFilterProvider);
    ref.watch(preferredCropsNotifierProvider);
    final locale = ref.watch(localeProvider);
    
    final repository = ref.read(forecastRepositoryProvider);
    return repository.getForecastsForPreferredCrops(
      language: locale.languageCode,
      page: 1,
      pageSize: 15,
      commodityId: filter.commodityId,
      marketId: filter.marketId,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Refresh user preferred crops first to ensure sync
      await ref.read(preferredCropsNotifierProvider.notifier).refresh();
      final filter = ref.read(forecastsFilterProvider);
      final locale = ref.read(localeProvider);
      final repository = ref.read(forecastRepositoryProvider);
      return repository.getForecastsForPreferredCrops(
        language: locale.languageCode,
        page: 1,
        pageSize: 15,
        commodityId: filter.commodityId,
        marketId: filter.marketId,
      );
    });
  }
}
