import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  AuthState build() {
  Future.microtask(_checkAuth);

  return AuthState(
    isLoading: true,
  );
}

  Future<void> _checkAuth() async {
    print("DEBUG: _checkAuth started");
    try {
      final repo = ref.read(authRepositoryProvider);
      print("DEBUG: repo read");
      
      // Attempt to get user directly. This implicitly checks authentication status.
      final user = await repo.getCurrentUser();
      print("DEBUG: getCurrentUser result: ${user != null ? 'User found' : 'No user'}");
      
      state = AuthState(
        currentUser: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
      print("DEBUG: state updated, isLoading = false");
    } catch (e) {
      print("DEBUG: _checkAuth error: $e");
      // Only log out if it's not a temporary network issue, 
      // but for now, just set state to not authenticated.
      state = AuthState(isLoading: false, isAuthenticated: false, error: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(LoginRequest(email: email, password: password));
      ref.invalidate(profileNotifierProvider);
      ref.invalidate(preferredCropsNotifierProvider);
      final user = await repo.getCurrentUser();
      state = AuthState(
        currentUser: user,
        isAuthenticated: user != null,
      );
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(SignupRequest(name: name, email: email, password: password));
      state = AuthState(isAuthenticated: false); // Redirect to login
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.invalidate(profileNotifierProvider);
    ref.invalidate(preferredCropsNotifierProvider);
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
