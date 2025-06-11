// lib/api/fmas_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Singleton client for FMAS REST API.
/// Note: backend routes are under /api/auth/...
class FmasApi {
  FmasApi._();

  static final instance = FmasApi._();

  // Android emulator loopback; backend listens on port 3000
  final Uri _base = Uri.parse('http://10.0.2.2:3000');

  /// POST /api/auth/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      _base.replace(path: '${_base.path}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Login failed: ${res.body}');
  }

  /// POST /api/auth/register
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String location,
  }) async {
    final res = await http.post(
      _base.replace(path: '${_base.path}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
        'location': location,
      }),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw Exception('Register failed: ${res.body}');
  }

  /// POST /api/auth/google
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final res = await http.post(
      _base.replace(path: '${_base.path}/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Google login failed: ${res.body}');
  }
}
