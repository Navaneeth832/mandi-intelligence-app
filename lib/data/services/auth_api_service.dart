import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/signup_request.dart';
import '../models/auth/user_profile.dart';

class AuthApiService {
  final String baseUrl = ApiConstants.baseUrl;

  String _extractErrorMessage(http.Response response, String fallback) {
    final body = response.body.trim();
    if (body.isEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }

        final message = decoded['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Fall back to the raw body below.
    }

    return body;
  }

  Future<SendOtpResponse> sendOTP(String identifier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to send OTP'),
      );
    }

    return SendOtpResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<VerifyOtpResponse> verifyOTP(String identifier, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'otp': otp,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to verify OTP'),
      );
    }

    return VerifyOtpResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<SendOtpResponse> sendForgotPasswordOTP(String identifier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to send OTP'),
      );
    }

    return SendOtpResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<VerifyOtpResponse> verifyForgotPasswordOTP(String identifier, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'otp': otp,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to verify OTP'),
      );
    }

    return VerifyOtpResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> resetPassword(String identifier, String verificationToken, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'verification_token': verificationToken,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to reset password'),
      );
    }
  }


  Future<UserProfile> register(SignupRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to register'),
      );
    }

    return UserProfile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to login'),
      );
    }

    return AuthResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AuthResponse> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get profile: ${response.body}');
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  Future<List<dynamic>> getPreferredCrops(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/preferences'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get preferred crops: ${response.body}');
    }

    return jsonDecode(response.body);
  }

Future<void> savePreferredCrops(
  String token,
  List<int> commodityIds,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/profile/preferences'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'commodity_ids': commodityIds,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to save preferred crops: ${response.body}',
    );
  }
}

  Future<AuthResponse> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10)); // Added timeout

    if (response.statusCode != 200) {
      throw Exception('Failed to get current user: ${response.body}');
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  Future<void> updateProfile(
  String token,
  Map<String, dynamic> body,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode != 200) {
    throw Exception(
      _extractErrorMessage(response, 'Failed to update profile'),
    );
  }
}
}

