// lib/api/fmas_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Singleton HTTP client for FMAS backend.
class FmasApi {
  FmasApi._();
  static final instance = FmasApi._();

  // Replace with your actual backend base URL
  final Uri _baseUrl = Uri.parse('https://your-backend.example.com/api');

  /// POST /auth/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      _baseUrl.replace(path: '${_baseUrl.path}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  /// Stub for register endpoint
  Future<Map<String, dynamic>> register(String email, String password) {
    throw UnimplementedError();
  }

// TODO: add forgotPassword, resetPassword, fetchAlerts, submitReport, etc.
}
