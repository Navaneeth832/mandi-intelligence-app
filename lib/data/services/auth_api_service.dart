import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/signup_request.dart';

class AuthApiService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<AuthResponse> register(SignupRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to register: ${response.body}');
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to login: ${response.body}');
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
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
      'Failed to update profile: ${response.body}',
    );
  }
}
}

