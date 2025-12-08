class Validators {
  // ตรวจสอบว่าเป็น Email ที่ถูกต้องหรือไม่
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // ตรวจสอบ Username (3-20 ตัวอักษร, อนุญาตตัวอักษร ตัวเลข _ -)
  static bool isValidUsername(String username) {
    if (username.isEmpty || username.length < 3 || username.length > 20) {
      return false;
    }
    return RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username);
  }

  // ตรวจสอบเบอร์โทรศัพท์ (10 หลัก เริ่มต้นด้วย 0)
  static bool isValidThaiPhone(String phone) {
    if (phone.isEmpty) return false;
    return RegExp(r'^0[0-9]{9}$').hasMatch(phone);
  }

  // ตรวจสอบ Password (อย่างน้อย 6 ตัว)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // ตรวจสอบ Password แบบเข้มงวด (8+ ตัว, มีตัวพิมพ์ใหญ่ เล็ก และตัวเลข)
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    return hasUppercase && hasLowercase && hasDigit;
  }

  // ฟังก์ชัน helper สำหรับแสดงข้อความ error
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    if (!isValidEmail(value)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกชื่อผู้ใช้งาน';
    }
    if (!isValidUsername(value)) {
      return 'ชื่อผู้ใช้ต้องมี 3-20 ตัวอักษร (a-z, 0-9, _, -)';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกเบอร์โทรศัพท์';
    }
    if (!isValidThaiPhone(value)) {
      return 'เบอร์โทรศัพท์ไม่ถูกต้อง (ต้องเป็น 10 หลัก เริ่มต้นด้วย 0)';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    if (!isValidPassword(value)) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }
    return null;
  }
}
