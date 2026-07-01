import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/core/providers/locale_provider.dart';
import 'package:mandi_intelligence_app/features/auth/providers/profile_notifier.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/auth/login_request.dart';
import '../../../data/models/auth/signup_request.dart';
import '../../../data/models/auth/user_profile.dart';

class AuthState {
  final UserProfile? currentUser;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });
}

class AuthNotifier extends Notifier<AuthState> {
  String _normalizeLanguageCode(String? value) {
    switch (value) {
      case 'en':
      case 'English':
      case 'english':
        return 'en';
      case 'ml':
      case 'Malayalam':
      case 'മലയാളം':
        return 'ml';
      case 'hi':
      case 'Hindi':
      case 'हिंदी':
        return 'hi';
      default:
        return 'en';
    }
  }

  @override
  AuthState build() {
    Future.microtask(_checkAuth);

    return AuthState(
      isLoading: true,
    );
  }

  Future<UserProfile?> _loadAuthenticatedUser() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    if (user?.preferredLanguage != null) {
      ref.read(localeProvider.notifier).setLocale(_normalizeLanguageCode(user!.preferredLanguage));
    }
    return user;
  }

  Future<void> _checkAuth() async {
    try {
      final user = await _loadAuthenticatedUser();
      state = AuthState(
        currentUser: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
    } catch (e) {
      state = AuthState(isLoading: false, isAuthenticated: false, error: e.toString());
    }
  }

  Future<UserProfile?> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.login(LoginRequest(email: email, password: password));
      ref.invalidate(profileNotifierProvider);
      ref.invalidate(preferredCropsNotifierProvider);
      final user = response.user;
      if (user.preferredLanguage.isNotEmpty) {
        ref.read(localeProvider.notifier).setLocale(_normalizeLanguageCode(user.preferredLanguage));
      }
      state = AuthState(
        currentUser: user,
        isAuthenticated: true,
        isLoading: false,
      );
      return user;
    } catch (e) {
      state = AuthState(error: e.toString(), isLoading: false);
      return null;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(SignupRequest(name: name, email: email, password: password));
      state = AuthState(isLoading: false, isAuthenticated: false);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.read(localeProvider.notifier).setLocale('en');
    ref.invalidate(profileNotifierProvider);
    ref.invalidate(preferredCropsNotifierProvider);
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
