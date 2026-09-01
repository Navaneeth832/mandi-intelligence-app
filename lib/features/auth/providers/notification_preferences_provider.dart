import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/notification_preferences.dart';

final notificationPreferencesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    NotificationPreferencesNotifier,
    NotificationPreferences>(NotificationPreferencesNotifier.new);

final hasConfiguredNotificationPreferencesProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  return ref.watch(notificationRepositoryProvider).hasConfiguredNotificationPreferences();
});

class NotificationPreferencesNotifier
    extends AutoDisposeAsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() {
    return ref.read(notificationRepositoryProvider).getNotificationPreferences();
  }

  Future<NotificationPreferences> savePreferences(
    NotificationPreferences updated,
  ) async {
    final repository = ref.read(notificationRepositoryProvider);
    final saved = await repository.updateNotificationPreferences(updated);
    state = AsyncValue.data(saved);
    return saved;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).getNotificationPreferences(),
    );
  }
}
