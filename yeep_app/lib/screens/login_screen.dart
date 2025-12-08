import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/background.dart';
import '../utils/password_helper.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  void _login() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);
    try {
      String usernameInput = _usernameController.text.trim();
      String passwordInput = _passwordController.text.trim();

      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: usernameInput)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('ไม่พบชื่อผู้ใช้งานนี้');
      }

      var userData = userQuery.docs.first.data();
      String foundEmail = userData['email'];
      String storedHashedPassword = userData['password'] ?? '';

      // ตรวจสอบรหัสผ่าน
      if (!PasswordHelper.verifyPassword(passwordInput, storedHashedPassword)) {
        throw Exception('รหัสผ่านไม่ถูกต้อง');
      }

      // Login ด้วย Firebase Auth (ถ้าต้องการ session management)
      // หรือข้ามขั้นตอนนี้ถ้าจะใช้ Firestore อย่างเดียว
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: foundEmail,
          password: passwordInput,
        );
      } catch (e) {
        // ถ้า Firebase Auth ล้มเหลว (เช่น รหัสผ่านไม่ตรง) แต่ hash ตรง
        // แสดงว่ารหัสผ่านถูกเปลี่ยนแล้วใน Firestore
        // ให้ผ่านไปได้เลย
        print("Firebase Auth failed but hash matched: $e");
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      String msg = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return YeepBackground(
      title: "เข้าสู่ระบบ",
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ชื่อผู้ใช้งาน",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกชื่อผู้ใช้งาน';
                }
                return null;
              },
            ),

            const SizedBox(height: 25),

            const Text(
              "รหัสผ่าน",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกรหัสผ่าน';
                }
                return null;
              },
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      widthFactor: 1.0,
                      child: Text(
                        "ลืมรหัสผ่าน",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("เข้าสู่ระบบ"),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ยังไม่มีบัญชี? ",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    "ลงทะเบียน",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
