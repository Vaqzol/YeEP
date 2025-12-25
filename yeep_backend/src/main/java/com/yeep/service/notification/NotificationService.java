package com.yeep.service.notification;

/**
 * NotificationService Interface - หลักการ Polymorphism
 * 
 * Interface นี้กำหนด contract สำหรับการส่งการแจ้งเตือน
 * สามารถมีหลาย implementation เช่น Email, SMS, Push Notification
 * 
 * ตัวอย่างการใช้ Polymorphism:
 * NotificationService service = new EmailNotificationService();
 * service.sendNotification(...);
 * 
 * หรือ
 * NotificationService service = new SmsNotificationService();
 * service.sendNotification(...);
 */
public interface NotificationService {

    /**
     * ส่งการแจ้งเตือน
     * 
     * @param to      ผู้รับ (email address หรือเบอร์โทร)
     * @param subject หัวข้อ
     * @param message เนื้อหา
     * @return true ถ้าส่งสำเร็จ
     */
    boolean sendNotification(String to, String subject, String message);

    /**
     * ส่งการแจ้งเตือนการจอง
     * 
     * @param to          ผู้รับ
     * @param bookingCode รหัสการจอง
     * @param routeName   ชื่อสายรถ
     * @param seatNumber  เลขที่นั่ง
     * @return true ถ้าส่งสำเร็จ
     */
    boolean sendBookingConfirmation(String to, String bookingCode, String routeName, String seatNumber);

    /**
     * ส่งการแจ้งเตือนยกเลิกการจอง
     * 
     * @param to          ผู้รับ
     * @param bookingCode รหัสการจอง
     * @return true ถ้าส่งสำเร็จ
     */
    boolean sendCancellationNotification(String to, String bookingCode);

    /**
     * ตรวจสอบว่าบริการพร้อมใช้งานหรือไม่
     * 
     * @return true ถ้าพร้อมใช้งาน
     */
    boolean isAvailable();

    /**
     * ดึงชื่อประเภทของการแจ้งเตือน
     * 
     * @return ชื่อประเภท เช่น "EMAIL", "SMS"
     */
    String getType();
}
