import 'package:flutter/material.dart';
import '../main.dart'; // import เพื่อเอาสี

class YeepBackground extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;

  const YeepBackground({
    super.key,
    required this.title,
    required this.child,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ใช้ Container เป็นพื้นหลังเพื่อทำ Gradient
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // 🔥 สีไล่เฉดตามแบบ
            colors: [secondaryOrange, primaryOrange],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),
              // ส่วนหัว (Logo / Back Button)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (showBack)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ), // ไอคอนลูกศรแบบใหม่
                            SizedBox(width: 5),
                            Text(
                              "Back",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!showBack) ...[
                      // ไอคอนเมนูจำลอง (ขีด 2 ขีด)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 3, width: 25, color: Colors.white),
                          const SizedBox(height: 5),
                          Container(height: 3, width: 15, color: Colors.white),
                        ],
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        "YeEP",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // กล่องสีขาว
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(30, 35, 30, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35), // ความโค้งของมุมบน
                      topRight: Radius.circular(35),
                    ),
                    boxShadow: [
                      // เงาเล็กน้อยให้ดูมีมิติ
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),
                        child,
                        const SizedBox(height: 30), // พื้นที่ด้านล่างเผื่อไว้
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
