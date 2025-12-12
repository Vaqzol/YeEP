import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/background.dart';
import '../services/email_sender.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool isChecked = false;
  bool isLoading = false;

  void _processRegister() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!isChecked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณายอมรับเงื่อนไข")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // ตรวจสอบว่า username ซ้ำหรือไม่ (ผ่าน API)
      final usernameCheck = await ApiService.checkUsername(
        _username.text.trim(),
      );
      if (usernameCheck['success'] == true && usernameCheck['data'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ชื่อผู้ใช้งานนี้ถูกใช้ไปแล้ว")),
        );
        setState(() => isLoading = false);
        return;
      }

      // ตรวจสอบว่า email ซ้ำหรือไม่ (ผ่าน API)
      final emailCheck = await ApiService.checkEmail(_email.text.trim());
      if (emailCheck['success'] == true && emailCheck['data'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("อีเมลนี้ถูกใช้ไปแล้ว")));
        setState(() => isLoading = false);
        return;
      }

      String otp = (100000 + Random().nextInt(900000)).toString();
      await EmailSender.sendOtp(_email.text.trim(), otp);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              username: _username.text.trim(),
              email: _email.text.trim(),
              phone: _phone.text.trim(),
              password: _password.text.trim(),
              correctOtp: otp,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return YeepBackground(
      title: "สร้างบัญชีของคุณ",
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildInputGroup(
              "ชื่อผู้ใช้งาน",
              _username,
              validator: Validators.validateUsername,
            ),
            _buildInputGroup(
              "อีเมล",
              _email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            _buildInputGroup(
              "เบอร์โทรศัพท์",
              _phone,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            _buildInputGroup(
              "รหัสผ่าน",
              _password,
              isPass: true,
              validator: Validators.validatePassword,
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (v) => setState(() => isChecked = v!),
                    activeColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "ฉันยอมรับเงื่อนไขการบริการและนโยบายความเป็นส่วนตัว",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _processRegister,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("ถัดไป"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper สำหรับสร้างช่องกรอก พร้อมหัวข้อ
  Widget _buildInputGroup(
    String label,
    TextEditingController c, {
    bool isPass = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: c,
            obscureText: isPass,
            keyboardType: keyboardType,
            validator: validator,
          ),
        ],
      ),
    );
  }
}
