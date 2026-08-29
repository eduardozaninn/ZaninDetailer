import 'dart:convert';

class JwtUtils {
  static bool isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload =
          jsonDecode(_decodeBase64(parts[1])) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp == null) return false;

      final expiryDate =
          DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000, isUtc: true);
      return DateTime.now().toUtc().isAfter(expiryDate);
    } catch (_) {
      return true;
    }
  }

  static String _decodeBase64(String input) {
    String normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }
    return utf8.decode(base64.decode(normalized));
  }
}
