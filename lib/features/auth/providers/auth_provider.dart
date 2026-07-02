import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/core/providers/locale_provider.dart';
import 'package:mandi_intelligence_app/features/auth/providers/profile_notifier.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/auth/login_request.dart';
import '../../../data/models/auth/signup_request.dart';
import '../../../data/models/auth/user_profile.dart';

const Object _unset = Object();

class AuthState {
  final UserProfile? currentUser;
  final bool isInitializing;
  final bool isLoginLoading;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isRegistering;
  final String? error;
  final bool isAuthenticated;
  final String? signupIdentifier;
  final String? signupRegistrationMethod;
  final String? verificationToken;
  final bool otpVerified;

  AuthState({
    this.currentUser,
    this.isInitializing = false,
    this.isLoginLoading = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isRegistering = false,
    this.error,
    this.isAuthenticated = false,
    this.signupIdentifier,
    this.signupRegistrationMethod,
    this.verificationToken,
    this.otpVerified = false,
  });

  bool get isBusy =>
      isInitializing || isLoginLoading || isSendingOtp || isVerifyingOtp || isRegistering;

  bool get hasRequestedOtp => signupIdentifier != null;

  bool get canRegister => otpVerified && verificationToken != null;

  AuthState copyWith({
    UserProfile? currentUser,
    bool? isInitializing,
    bool? isLoginLoading,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isRegistering,
    Object? error = _unset,
    bool? isAuthenticated,
    Object? signupIdentifier = _unset,
    Object? signupRegistrationMethod = _unset,
    Object? verificationToken = _unset,
    bool? otpVerified,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isInitializing: isInitializing ?? this.isInitializing,
      isLoginLoading: isLoginLoading ?? this.isLoginLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isRegistering: isRegistering ?? this.isRegistering,
      error: identical(error, _unset) ? this.error : error as String?,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      signupIdentifier: identical(signupIdentifier, _unset)
          ? this.signupIdentifier
          : signupIdentifier as String?,
      signupRegistrationMethod: identical(signupRegistrationMethod, _unset)
          ? this.signupRegistrationMethod
          : signupRegistrationMethod as String?,
      verificationToken: identical(verificationToken, _unset)
          ? this.verificationToken
          : verificationToken as String?,
      otpVerified: otpVerified ?? this.otpVerified,
    );
  }
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

    return AuthState(isInitializing: true);
  }


  String _formatError(Object error) {
    final raw = error.toString();
    return raw
        .replaceFirst('Exception: ', '')
        .replaceFirst('ClientException: ', '')
        .trim();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetSignupFlow() {
    state = state.copyWith(
      error: null,
      signupIdentifier: null,
      signupRegistrationMethod: null,
      verificationToken: null,
      otpVerified: false,
      isSendingOtp: false,
      isVerifyingOtp: false,
      isRegistering: false,
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
        isInitializing: false,
      );
    } catch (e) {
      state = AuthState(
        isInitializing: false,
        isAuthenticated: false,
        error: _formatError(e),
      );
    }
  }

  Future<UserProfile?> login(String identifier, String password) async {
    state = state.copyWith(
      isLoginLoading: true,
      error: null,
    );
    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.login(
        LoginRequest(identifier: identifier, password: password),
      );
      ref.invalidate(profileNotifierProvider);
      ref.invalidate(preferredCropsNotifierProvider);
      final user = response.user;
      if (user.preferredLanguage.isNotEmpty) {
        ref.read(localeProvider.notifier).setLocale(_normalizeLanguageCode(user.preferredLanguage));
      }
      state = AuthState(
        currentUser: user,
        isAuthenticated: true,
        isInitializing: false,
        isLoginLoading: false,
      );
      return user;
    } catch (e) {
      state = state.copyWith(
        isLoginLoading: false,
        error: _formatError(e),
      );
      return null;
    }
  }

  Future<bool> sendOtp(String identifier) async {
    if (state.isSendingOtp || state.isVerifyingOtp || state.isRegistering) {
      return false;
    }

    state = state.copyWith(
      isSendingOtp: true,
      error: null,
      verificationToken: null,
      otpVerified: false,
    );

    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.sendOTP(identifier.trim());
      state = state.copyWith(
        isSendingOtp: false,
        signupIdentifier: response.identifier,
        signupRegistrationMethod: response.registrationMethod,
        verificationToken: null,
        otpVerified: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSendingOtp: false,
        error: _formatError(e),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    final identifier = state.signupIdentifier;
    if (identifier == null || state.isSendingOtp || state.isVerifyingOtp || state.isRegistering) {
      return false;
    }

    state = state.copyWith(
      isVerifyingOtp: true,
      error: null,
    );

    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.verifyOTP(identifier, otp.trim());
      state = state.copyWith(
        isVerifyingOtp: false,
        verificationToken: response.verificationToken,
        otpVerified: true,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isVerifyingOtp: false,
        error: _formatError(e),
      );
      return false;
    }
  }

  Future<bool> register(String name, String password) async {
    final identifier = state.signupIdentifier;
    final token = state.verificationToken;

    if (identifier == null || token == null || !state.otpVerified) {
      state = state.copyWith(error: 'Please verify your OTP before registering.');
      return false;
    }

    if (state.isSendingOtp || state.isVerifyingOtp || state.isRegistering) {
      return false;
    }

    state = state.copyWith(
      isRegistering: true,
      error: null,
    );

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(
        SignupRequest(
          name: name.trim(),
          identifier: identifier,
          password: password,
          verificationToken: token,
        ),
      );
      state = AuthState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isRegistering: false,
        error: _formatError(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.read(localeProvider.notifier).setLocale('en');
    ref.invalidate(profileNotifierProvider);
    ref.invalidate(preferredCropsNotifierProvider);
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
