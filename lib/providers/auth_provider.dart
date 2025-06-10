// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/fmas_api.dart';
import '../models/user.dart';

/// Holds the authentication state.
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

  factory AuthState.initial() =>
      AuthState._(isAuthenticated: false, loading: false);

  factory AuthState.loading() =>
      AuthState._(isAuthenticated: false, loading: true);

  factory AuthState.authenticated(User user) =>
      AuthState._(isAuthenticated: true, user: user);

  factory AuthState.error(String msg) =>
      AuthState._(isAuthenticated: false, error: msg);
}

/// Manages login/logout with FMAS API.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  /// Call backend to log in.
  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final data = await FmasApi.instance.login(email, password);
      final user = User.fromJson(data);
      // TODO: store user.token in secure storage
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Clear auth state.
  void logout() {
    state = AuthState.initial();
  }
}

/// Expose AuthNotifier to the app.
final authProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
