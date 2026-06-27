import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _checkAuth();
    return AuthState();
  }

  Future<void> _checkAuth() async {
    final repo = ref.read(authRepositoryProvider);
    final isAuth = await repo.isAuthenticated();
    if (isAuth) {
      state = AuthState(isLoading: true);
      final user = await repo.getCurrentUser();
      state = AuthState(
        currentUser: user,
        isAuthenticated: user != null,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(LoginRequest(email: email, password: password));
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
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
