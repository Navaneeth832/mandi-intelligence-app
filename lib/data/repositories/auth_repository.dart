import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_api_service.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/signup_request.dart';
import '../models/auth/user_profile.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthRepository(this._apiService, this._storage);

  static const _tokenKey = 'access_token';

  Future<SendOtpResponse> sendOTP(String identifier) async {
    return _apiService.sendOTP(identifier);
  }

  Future<VerifyOtpResponse> verifyOTP(String identifier, String otp) async {
    return _apiService.verifyOTP(identifier, otp);
  }

  Future<SendOtpResponse> sendForgotPasswordOTP(String identifier) async {
    return _apiService.sendForgotPasswordOTP(identifier);
  }

  Future<VerifyOtpResponse> verifyForgotPasswordOTP(String identifier, String otp) async {
    return _apiService.verifyForgotPasswordOTP(identifier, otp);
  }

  Future<void> resetPassword(String identifier, String verificationToken, String newPassword) async {
    return _apiService.resetPassword(identifier, verificationToken, newPassword);
  }


  Future<UserProfile> register(SignupRequest request) async {
    return _apiService.register(request);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    await _storage.deleteAll();

    final response = await _apiService.login(request);

    if (response.accessToken != null) {
      await _storage.write(
        key: _tokenKey,
        value: response.accessToken!,
      );
    }

    return response;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<UserProfile?> getProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await _apiService.getProfile(token);
    return response.user;
  }

  Future<List<dynamic>> getPreferredCrops() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    return await _apiService.getPreferredCrops(token);
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    await _apiService.updateProfile(token, body);
  }

  Future<void> savePreferredCrops(List<int> cropIds) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    await _apiService.savePreferredCrops(token, cropIds);
  }

  Future<UserProfile?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final response = await _apiService.getCurrentUser(token);
      return response.user;
    } catch (e) {
      // If token is invalid, remove it
      await logout();
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
      final token = await getToken();
      if (token == null) return false;

      try {
        final response = await _apiService.getCurrentUser(token);
        return response.user != null;
      } catch (_) {
        await logout();
        return false;
      }
    }
}
