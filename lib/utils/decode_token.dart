// lib/utils/decode_token.dart

import 'dart:convert';

/// If ever you need to decode a JWT client-side (e.g. for fallback), this
/// extracts the `role` field from the payload.
/// Note: your backend `/validate` already returns the role, so you likely
/// won't need this in most cases.
String decodeRoleFromToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return 'viewer';
    final payload = parts[1];
    // Base64 decode, with padding
    var normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    return (map['role'] as String?) ?? 'viewer';
  } catch (_) {
    return 'viewer';
  }
}
