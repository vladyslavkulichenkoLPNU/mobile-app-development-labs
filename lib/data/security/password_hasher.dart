import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

abstract final class PasswordHasher {
  static const int _saltBytes = 16;
  static const int _iterations = 10000;
  static const String _prefix = 'sha256';

  static String hash(String password) {
    final salt = _generateSalt();
    final derived = _derive(password, salt);
    return '$_prefix\$$_iterations\$$salt\$$derived';
  }

  static bool verify(String password, String storedHash) {
    final parts = storedHash.split(r'$');
    if (parts.length != 4 || parts[0] != _prefix) {
      return false;
    }
    final iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations <= 0) {
      return false;
    }
    final salt = parts[2];
    final expected = parts[3];
    final actual = _derive(password, salt, iterations: iterations);
    return _constantTimeEquals(actual, expected);
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(_saltBytes, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String _derive(
    String password,
    String salt, {
    int iterations = _iterations,
  }) {
    final hmac = Hmac(sha256, utf8.encode(password));
    var digest = hmac.convert(utf8.encode(salt)).bytes;
    for (var i = 1; i < iterations; i++) {
      digest = hmac.convert(digest).bytes;
    }
    return base64UrlEncode(digest);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
