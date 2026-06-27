import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/repositories/auth_repository.dart';

final authApiServiceProvider = Provider((ref) => AuthApiService());

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authRepositoryProvider = Provider((ref) {
  final apiService = ref.read(authApiServiceProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(apiService, storage);
});
