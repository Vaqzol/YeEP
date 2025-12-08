import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHelper {
  /// Hash password ด้วย SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// ตรวจสอบว่า password ตรงกับ hash หรือไม่
  static bool verifyPassword(String password, String hashedPassword) {
    final hash = hashPassword(password);
    return hash == hashedPassword;
  }
}
