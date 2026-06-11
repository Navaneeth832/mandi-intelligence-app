import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/mandi_repository.dart';
import '../../../data/services/mandi_api_service.dart';
import '../../../data/models/mandi_price.dart';

final mandiRepositoryProvider =
    Provider<MandiRepository>((ref) {
  return MandiRepository(
    MandiApiService(),
  );
});

final mandiPricesProvider =
    FutureProvider<List<MandiPrice>>((ref) async {
  final repository = ref.watch(
    mandiRepositoryProvider,
  );

  return repository.getMandiPrices();
});