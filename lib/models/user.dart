// lib/models/user.dart

/// User model representing auth response.
class User {
  final String id;
  final String email;
  final String token;

  User({
    required this.id,
    required this.email,
    required this.token,
  });

  /// Construct from JSON map returned by /auth/login or /auth/register
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'] as String,
      email: json['user']['email'] as String,
      token: json['token'] as String,
    );
  }
}
