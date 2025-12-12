import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // เปลี่ยน IP นี้เป็น IP ของเครื่องที่รัน Backend
  // ถ้าทดสอบบน Android Emulator ใช้ 10.0.2.2 แทน localhost
  // ถ้าทดสอบบนมือถือจริง ใช้ IP ของคอมพิวเตอร์ เช่น 192.168.x.x
  static const String baseUrl = 'http://10.0.2.2:8081/api';

  // สำหรับทดสอบบน Web หรือ Windows
  // static const String baseUrl = 'http://localhost:8081/api';

  // Login
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  // Get user by username
  static Future<Map<String, dynamic>> getUser(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$username'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  // Check email exists
  static Future<Map<String, dynamic>> checkEmail(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/check-email?email=$email'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  // Update password by email
  static Future<Map<String, dynamic>> updatePassword(
    String email,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/update-password?email=$email&newPassword=$newPassword',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  // Check username exists
  static Future<Map<String, dynamic>> checkUsername(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/check-username?username=$username'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  // Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
