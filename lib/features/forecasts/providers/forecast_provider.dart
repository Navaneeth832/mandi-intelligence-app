import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../data/repositories/forecast_repository.dart';
import '../../../data/models/forecast_model.dart';
import '../../auth/providers/profile_notifier.dart';

final forecastRepositoryProvider = Provider<ForecastRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForecastRepository(authRepository);
});

final forecastsNotifierProvider = AutoDisposeAsyncNotifierProvider<ForecastsNotifier, List<CommodityForecast>>(() {
  return ForecastsNotifier();
});

class ForecastsNotifier extends AutoDisposeAsyncNotifier<List<CommodityForecast>> {
  @override
  Future<List<CommodityForecast>> build() async {
    // Watch preferred crops and selected locale so that forecasts reload dynamically on preference or language changes.
    ref.watch(preferredCropsNotifierProvider);
    final locale = ref.watch(localeProvider);
    
    final repository = ref.read(forecastRepositoryProvider);
    return repository.getForecastsForPreferredCrops(language: locale.languageCode);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Refresh user preferred crops first to ensure sync
      await ref.read(preferredCropsNotifierProvider.notifier).refresh();
      final locale = ref.read(localeProvider);
      final repository = ref.read(forecastRepositoryProvider);
      return repository.getForecastsForPreferredCrops(language: locale.languageCode);
    });
  }
}
