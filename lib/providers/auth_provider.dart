// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/fmas_api.dart';
import '../models/user.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool loading;
  final String? error;

  AuthState._({
    required this.isAuthenticated,
    this.user,
    this.loading = false,
    this.error,
  });

  factory AuthState.initial() => AuthState._(isAuthenticated: false);

  factory AuthState.loading() =>
      AuthState._(isAuthenticated: false, loading: true);

  factory AuthState.authenticated(User user) =>
      AuthState._(isAuthenticated: true, user: user);

  factory AuthState.error(String msg) =>
      AuthState._(isAuthenticated: false, error: msg);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final data = await FmasApi.instance.login(email, password);
      final user = User.fromJson(data);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register(String username, String email, String password,
      String phone, String location) async {
    state = AuthState.loading();
    try {
      final data = await FmasApi.instance.register(
        username: username,
        email: email,
        password: password,
        phone: phone,
        location: location,
      );
      final user = User.fromJson(data);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> loginWithGoogle(String idToken) async {
    state = AuthState.loading();
    try {
      final data = await FmasApi.instance.loginWithGoogle(idToken);
      final user = User.fromJson(data);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void logout() => state = AuthState.initial();
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
