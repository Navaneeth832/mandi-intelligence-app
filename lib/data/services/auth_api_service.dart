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

  Future<AuthResponse> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get current user: ${response.body}');
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
  }
}
