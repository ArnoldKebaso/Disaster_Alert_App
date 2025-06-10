// lib/models/user.dart

/// Data class for the logged-in user & JWT token.
class User {
  final String id;
  final String email;
  final String token;

  User({
    required this.id,
    required this.email,
    required this.token,
  });

  /// Create a User from the JSON response of /auth/login
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'] as String,
      email: json['user']['email'] as String,
      token: json['token'] as String,
    );
  }
}
