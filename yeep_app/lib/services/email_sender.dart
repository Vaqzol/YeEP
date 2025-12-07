import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailSender {
  // 🔥 แก้ตรงนี้: ใส่อีเมลและรหัส App Password ของคุณ
  static const String myEmail = 'yeep.bus.booking@gmail.com';
  static const String appPassword = 'hzrfvouqrfyyoxcr';

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
