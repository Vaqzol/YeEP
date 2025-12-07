import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/background.dart';
import '../main.dart'; // เอาสี
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return YeepBackground(
      title: "เมนูหลัก",
      // ใส่ Icon คน ด้านขวาบน
      showBack: false,
      child: Column(
        children: [
          // แอบใส่ปุ่ม Logout ตรงนี้ชั่วคราว (ในแบบมี User Icon)
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 20),
          // 🔥 ปุ่มเมนู 3 อันด้านบน (ทรงแคปซูล)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCapsuleButton("แผนที่รถ"),
              const SizedBox(width: 10),
              _buildCapsuleButton("ตารางเดินรถ"),
              const SizedBox(width: 10),
              _buildCapsuleButton("ประวัติการจอง"),
            ],
          ),

          const SizedBox(height: 40),

          // 🔥 ปุ่ม Dropdown จำลอง (ต้นทาง/ปลายทาง)
          _buildFakeDropdown("จาก: ต้นทาง", "หอพักหญิง-เรียนรวม"),
          const SizedBox(height: 15),
          _buildFakeDropdown("ถึง: ปลายทาง", "หอพักชาย-ตลาดหน้ามอ"),

          const SizedBox(height: 40),

          // ปุ่มค้นหา (มีไอคอน)
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search),
              label: const Text("ค้นหารถเมล์"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ปุ่มยืนยันที่นั่ง
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryOrange, // สีอ่อนกว่านิดนึงตามแบบ
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("ยืนยันที่นั่ง"),
            ),
          ),
        ],
      ),
    );
  }

  // Helper สร้างปุ่มแคปซูล
  Widget _buildCapsuleButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(), // รูปร่างแคปซูล
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      child: Text(text),
    );
  }

  // Helper สร้างปุ่มที่หน้าตาเหมือน Dropdown
  Widget _buildFakeDropdown(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // ขอบมนมาก
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Kanit',
              ), // ต้องระบุ font เพราะอยู่ใน RichText
              children: [
                TextSpan(
                  text: "$label  ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_right, color: primaryOrange),
        ],
      ),
    );
  }
}
