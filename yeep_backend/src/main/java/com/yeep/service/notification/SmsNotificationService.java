package com.yeep.service.notification;

import org.springframework.stereotype.Service;

/**
 * SmsNotificationService - Implementation ของ NotificationService
 * 
 * ใช้หลักการ Polymorphism โดยสืบทอดจาก Interface NotificationService
 * สำหรับส่งการแจ้งเตือนผ่านทาง SMS
 */
@Service("smsNotificationService")
public class SmsNotificationService implements NotificationService {

    private static final String TYPE = "SMS";

    @Override
    public boolean sendNotification(String to, String subject, String message) {
        // จำลองการส่ง SMS
        System.out.println("========== SMS NOTIFICATION ==========");
        System.out.println("Phone: " + to);
        System.out.println("Message: " + message);
        System.out.println("=======================================");

        // ในระบบจริงจะเชื่อมต่อกับ SMS Gateway
        // เช่น Twilio, AWS SNS, หรือ Thai SMS providers
        return true;
    }

    @Override
    public boolean sendBookingConfirmation(String to, String bookingCode, String routeName, String seatNumber) {
        // SMS ต้องกระชับ
        String message = String.format(
                "YeEP: จองสำเร็จ! รหัส %s สาย %s ที่นั่ง %s",
                bookingCode, routeName, seatNumber);
        return sendNotification(to, "Booking", message);
    }

    @Override
    public boolean sendCancellationNotification(String to, String bookingCode) {
        String message = String.format(
                "YeEP: ยกเลิกการจอง %s สำเร็จ",
                bookingCode);
        return sendNotification(to, "Cancellation", message);
    }

    @Override
    public boolean isAvailable() {
        // ในระบบจริงจะเช็ค SMS Gateway connection
        return true;
    }

    @Override
    public String getType() {
        return TYPE;
    }
}
