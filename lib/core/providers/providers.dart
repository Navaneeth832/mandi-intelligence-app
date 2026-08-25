import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/notification_api_service.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/services/alert_api_service.dart';
import '../../data/repositories/alert_repository.dart';
import '../../data/services/local_cache_service.dart';

final authApiServiceProvider = Provider((ref) => AuthApiService());

final notificationApiServiceProvider = Provider((ref) => NotificationApiService());

final alertApiServiceProvider = Provider((ref) => AlertApiService());

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final localCacheServiceProvider = FutureProvider<LocalCacheService>((ref) async {
  return await LocalCacheService.getInstance();
});

final authRepositoryProvider = Provider((ref) {
  final apiService = ref.read(authApiServiceProvider);
  final storage = ref.read(secureStorageProvider);
  final cacheService = ref.watch(localCacheServiceProvider).valueOrNull;
  return AuthRepository(apiService, storage, cacheService: cacheService);
});

final notificationRepositoryProvider = Provider((ref) {
  final apiService = ref.read(notificationApiServiceProvider);
  final storage = ref.read(secureStorageProvider);
  return NotificationRepository(apiService, storage);
});

final alertRepositoryProvider = Provider((ref) {
  final apiService = ref.read(alertApiServiceProvider);
  final storage = ref.read(secureStorageProvider);
  return AlertRepository(apiService, storage);
});
