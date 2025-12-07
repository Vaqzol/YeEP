import 'package:flutter/material.dart';

import 'login_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // หน้า Success พื้นหลังขาวตามแบบ
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // ปุ่ม Back จำลอง
              Row(
                children: const [
                  Icon(Icons.arrow_back_ios_new, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Back",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const Spacer(),
              // 🔥 วงกลมสีเขียวใหญ่ๆ
              Container(
                height: 180,
                width: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80), // สีเขียวตามแบบ
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, size: 100, color: Colors.white),
              ),
              const SizedBox(height: 40),
              const Text(
                "ลงทะเบียนสำเร็จ",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),

              SizedBox(
                width: 200, // ปุ่มไม่เต็มจอตามแบบ
                child: ElevatedButton(
                  // 🔥 ปุ่มสีส้มตามแบบ (ไม่ใช่สีขาว)
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  ),
                  child: const Text("เข้าสู่ระบบ"),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
