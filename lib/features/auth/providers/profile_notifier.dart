import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/core/providers/providers.dart';
import 'package:mandi_intelligence_app/data/models/auth/user_profile.dart';

final profileNotifierProvider = AutoDisposeAsyncNotifierProvider<ProfileNotifier, UserProfile?>(() => ProfileNotifier());

class ProfileNotifier extends AutoDisposeAsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() {
    return ref.read(authRepositoryProvider).getProfile();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).getProfile());
  }
}

final preferredCropsNotifierProvider = AutoDisposeAsyncNotifierProvider<PreferredCropsNotifier, List<Map<String, dynamic>>>(() => PreferredCropsNotifier());

class PreferredCropsNotifier extends AutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final data = await ref.read(authRepositoryProvider).getPreferredCrops();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await ref.read(authRepositoryProvider).getPreferredCrops();
      return List<Map<String, dynamic>>.from(data);
    });
  }
}
