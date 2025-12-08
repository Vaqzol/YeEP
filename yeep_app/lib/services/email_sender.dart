import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailSender {
  // ดึงค่าจาก .env file
  static String get myEmail => dotenv.env['SMTP_EMAIL'] ?? '';
  static String get appPassword => dotenv.env['SMTP_PASSWORD'] ?? '';

  static Future<void> sendOtp(String recipientEmail, String otp) async {
    final smtpServer = gmail(myEmail, appPassword);

    final message = Message()
      ..from = Address(myEmail, 'YeEP App')
      ..recipients.add(recipientEmail)
      ..subject = 'รหัสยืนยันตัวตน (OTP)'
      ..text =
          'รหัส OTP ของคุณคือ: $otp\n\nกรุณากรอกรหัสนี้ในแอปพลิเคชันเพื่อยืนยันตัวตน';

    try {
      await send(message, smtpServer);
      print("ส่งอีเมลสำเร็จ");
    } catch (e) {
      print("ส่งอีเมลไม่ผ่าน: $e");
      throw Exception("ไม่สามารถส่ง OTP ได้");
    }
  }
}
