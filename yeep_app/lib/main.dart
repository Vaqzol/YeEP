import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart'; // เพิ่มบรรทัดนี้
import 'screens/login_screen.dart';

// กำหนดสีหลักของแอป
const Color primaryOrange = Color(0xFFFF7028);
const Color secondaryOrange = Color(0xFFFFA751);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YeEP App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        // 🔥 ใช้ฟอนต์ Kanit ทั้งแอป
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
        // 🔥 ตั้งค่า Theme ของปุ่มกดให้สวยงามเป็นมาตรฐาน
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            elevation: 3, // เพิ่มเงา
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // ขอบมน
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 🔥 ตั้งค่า Theme ของช่องกรอกข้อความ
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: primaryOrange, width: 2),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
