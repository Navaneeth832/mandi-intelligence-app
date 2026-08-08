import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/notification_api_service.dart';
import '../../data/repositories/notification_repository.dart';

final authApiServiceProvider = Provider((ref) => AuthApiService());

final notificationApiServiceProvider = Provider((ref) => NotificationApiService());

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authRepositoryProvider = Provider((ref) {
  final apiService = ref.read(authApiServiceProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(apiService, storage);
});

final notificationRepositoryProvider = Provider((ref) {
  final apiService = ref.read(notificationApiServiceProvider);
  final storage = ref.read(secureStorageProvider);
  return NotificationRepository(apiService, storage);
});
