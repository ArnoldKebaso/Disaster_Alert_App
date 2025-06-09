// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/fmas_api.dart';
import '../models/user.dart';

/// Represents the authentication state.
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final bool loading;

  AuthState._({
    required this.isAuthenticated,
    this.user,
    this.error,
    this.loading = false,
  });

  // Initial: not logged in
  factory AuthState.initial() =>
      AuthState._(isAuthenticated: false, loading: false);

  // Loading: login/register in progress
  factory AuthState.loading() =>
      AuthState._(isAuthenticated: false, loading: true);

  // Authenticated: store the User
  factory AuthState.authenticated(User user) =>
      AuthState._(isAuthenticated: true, user: user);

  // Error: login/register failed
  factory AuthState.error(String message) =>
      AuthState._(isAuthenticated: false, error: message);
}

/// StateNotifier to handle login, logout, etc.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  /// Attempt login against the backend
  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final data = await FmasApi.instance.login(email, password);
      final user = User.fromJson(data);
      // TODO: store user.token in secure storage for future calls
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Log out locally
  void logout() {
    // TODO: clear secure storage if used
    state = AuthState.initial();
  }
}

/// Expose AuthNotifier via Riverpod
final authProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
