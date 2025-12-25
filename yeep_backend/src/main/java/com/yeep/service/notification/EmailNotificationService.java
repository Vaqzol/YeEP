package com.yeep.service.notification;

import org.springframework.stereotype.Service;

/**
 * EmailNotificationService - Implementation ของ NotificationService
 * 
 * ใช้หลักการ Polymorphism โดยสืบทอดจาก Interface NotificationService
 * สำหรับส่งการแจ้งเตือนผ่านทาง Email
 */
@Service("emailNotificationService")
public class EmailNotificationService implements NotificationService {

    private static final String TYPE = "EMAIL";

    @Override
    public boolean sendNotification(String to, String subject, String message) {
        // จำลองการส่ง Email
        System.out.println("========== EMAIL NOTIFICATION ==========");
        System.out.println("To: " + to);
        System.out.println("Subject: " + subject);
        System.out.println("Message: " + message);
        System.out.println("=========================================");

        // ในระบบจริงจะเชื่อมต่อกับ SMTP Server
        // เช่น ใช้ JavaMail API หรือ Spring Mail
        return true;
    }

    @Override
    public boolean sendBookingConfirmation(String to, String bookingCode, String routeName, String seatNumber) {
        String subject = "ยืนยันการจองตั๋ว - " + bookingCode;
        String message = String.format(
                "การจองของคุณได้รับการยืนยันแล้ว\n\n" +
                        "รหัสการจอง: %s\n" +
                        "สายรถ: %s\n" +
                        "ที่นั่ง: %s\n\n" +
                        "ขอบคุณที่ใช้บริการ YeEP",
                bookingCode, routeName, seatNumber);
        return sendNotification(to, subject, message);
    }

    @Override
    public boolean sendCancellationNotification(String to, String bookingCode) {
        String subject = "ยกเลิกการจอง - " + bookingCode;
        String message = String.format(
                "การจองของคุณถูกยกเลิกแล้ว\n\n" +
                        "รหัสการจอง: %s\n\n" +
                        "หากมีข้อสงสัยกรุณาติดต่อเจ้าหน้าที่",
                bookingCode);
        return sendNotification(to, subject, message);
    }

    @Override
    public boolean isAvailable() {
        // ในระบบจริงจะเช็ค SMTP connection
        return true;
    }

    @Override
    public String getType() {
        return TYPE;
    }
}
