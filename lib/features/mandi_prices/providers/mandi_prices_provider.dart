import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/mandi_repository.dart';
import '../../../data/models/mandi_price.dart';

final mandiRepositoryProvider = Provider<MandiRepository>((ref) {
  return MandiRepositoryImpl();
});

final mandiPricesProvider =
    FutureProvider<List<MandiPrice>>((ref) async {
  final repository = ref.watch(mandiRepositoryProvider);
  return repository.getPrices();
});