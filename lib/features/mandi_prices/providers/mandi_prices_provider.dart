import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/mandi_price.dart';
import '../../../data/repositories/mandi_repository.dart';
import '../../../data/services/mandi_api_service.dart';
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

// FutureProvider to fetch the mandi prices based on a filter
final mandiPricesProvider = FutureProvider.family<List<MandiPrice>, Filter>((ref, filter) {
  final repository = ref.watch(mandiRepositoryProvider);
  return repository.getMandiPrices(filter);
});
