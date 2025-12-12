import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../widgets/background.dart';
import '../main.dart'; // เอาสี
import '../services/api_service.dart';
import 'success_screen.dart';

class OtpScreen extends StatefulWidget {
  final String username, email, phone, password, correctOtp;
  const OtpScreen({
    super.key,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.correctOtp,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  bool isLoading = false;
  int _secondsRemaining = 58;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _timerText {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyAndSave() async {
    String inputOtp = _pinController.text;
    if (inputOtp.length != 6) return;

    if (inputOtp != widget.correctOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("รหัส OTP ไม่ถูกต้อง"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // เรียก API register
      final response = await ApiService.register(
        username: widget.username,
        email: widget.email,
        phone: widget.phone,
        password: widget.password,
      );

      if (response['success'] == true) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SuccessScreen()),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'ลงทะเบียนไม่สำเร็จ');
      }
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 ตั้งค่า Theme ของช่อง Pinput ให้เป็นกล่อง
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: primaryOrange, width: 2),
      ),
    );

    return YeepBackground(
      title: "ยืนยันตัวตน",
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "OTP",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "กรอกรหัส OTP สำหรับการยืนยันตัวตน",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                _timerText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 🔥 ช่องกรอก OTP แบบใหม่
          Pinput(
            length: 6,
            controller: _pinController,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
            onCompleted: (pin) => _verifyAndSave(),
          ),

          const SizedBox(height: 30),
          Text(
            "รหัส OTP ถูกส่งไปยัง Email: ${widget.email}",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 10),
          const Text(
            "ส่งรหัสอีกครั้ง",
            style: TextStyle(
              color: Colors.grey,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _verifyAndSave,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("ลงทะเบียน"),
            ),
          ),
        ],
      ),
    );
  }
}
