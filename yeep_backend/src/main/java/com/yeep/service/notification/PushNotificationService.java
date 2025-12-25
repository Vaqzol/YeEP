package com.yeep.service.notification;

import org.springframework.stereotype.Service;

/**
 * PushNotificationService - Implementation ของ NotificationService
 * 
 * ใช้หลักการ Polymorphism โดยสืบทอดจาก Interface NotificationService
 * สำหรับส่ง Push Notification ไปยังมือถือ
 */
@Service("pushNotificationService")
public class PushNotificationService implements NotificationService {

    private static final String TYPE = "PUSH";

    @Override
    public boolean sendNotification(String to, String subject, String message) {
        // จำลองการส่ง Push Notification
        System.out.println("========== PUSH NOTIFICATION ==========");
        System.out.println("Device Token: " + to);
        System.out.println("Title: " + subject);
        System.out.println("Body: " + message);
        System.out.println("========================================");

        // ในระบบจริงจะเชื่อมต่อกับ Firebase Cloud Messaging (FCM)
        // หรือ Apple Push Notification Service (APNS)
        return true;
    }

    @Override
    public boolean sendBookingConfirmation(String to, String bookingCode, String routeName, String seatNumber) {
        String title = "จองสำเร็จ! 🎉";
        String body = String.format(
                "รหัส %s | สาย: %s | ที่นั่ง: %s",
                bookingCode, routeName, seatNumber);
        return sendNotification(to, title, body);
    }

    @Override
    public boolean sendCancellationNotification(String to, String bookingCode) {
        String title = "ยกเลิกการจองแล้ว";
        String body = String.format("รหัสการจอง %s ถูกยกเลิกเรียบร้อย", bookingCode);
        return sendNotification(to, title, body);
    }

    @Override
    public boolean isAvailable() {
        // ในระบบจริงจะเช็ค FCM connection
        return true;
    }

    @Override
    public String getType() {
        return TYPE;
    }
}
