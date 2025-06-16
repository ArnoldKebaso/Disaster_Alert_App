// lib/api/fmas_api.dart

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class FmasApi {
  FmasApi._() {
    _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    _cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  static final instance = FmasApi._();
  late final Dio _dio;
  late final CookieJar _cookieJar;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    return resp.data['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final resp = await _dio.post('/auth/google', data: {'idToken': idToken});
    return resp.data['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String location,
  }) async {
    final resp = await _dio.post('/register', data: {
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'location': location,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<void> logout() async => await _dio.post('/logout');

  Future<Map<String, dynamic>> validate() async {
    final resp = await _dio.get('/validate');
    return resp.data as Map<String, dynamic>;
  }

  /// Send a reset‐link to the user’s email
  Future<String> forgotPassword(String email) async {
    final resp = await _dio.post('/forgot-password', data: {'email': email});
    return resp.data['message'] as String;
  }

  /// Reset the password given email, token & newPassword
  Future<String> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final resp = await _dio.post('/reset-password', data: {
      'email': email,
      'token': token,
      'newPassword': newPassword,
    });
    return resp.data['message'] as String;
  }
}
