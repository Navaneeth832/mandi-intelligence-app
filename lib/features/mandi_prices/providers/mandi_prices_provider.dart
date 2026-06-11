import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/mandi_price.dart';
import '../../../data/repositories/mandi_repository.dart';
import '../../../data/services/mandi_api_service.dart';

// Provider for the ApiService
final apiServiceProvider = Provider<MandiApiService>((ref) {
  return MandiApiService();
});

// Provider for the Repository
final mandiRepositoryProvider = Provider<MandiRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MandiRepository(apiService);
});

// FutureProvider to fetch the mandi prices
final mandiPricesProvider = FutureProvider<List<MandiPrice>>((ref) {
  final repository = ref.watch(mandiRepositoryProvider);
  return repository.getMandiPrices();
});
