package com.yeep.service.notification;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * NotificationManager - ใช้หลักการ Polymorphism
 * 
 * Class นี้สาธิตการใช้ Polymorphism โดยรับ List ของ NotificationService
 * (ซึ่งมีหลาย implementation: Email, SMS, Push)
 * และสามารถเรียกใช้ได้โดยไม่ต้องรู้ว่าเป็น implementation ไหน
 */
@Service
public class NotificationManager {

    private final Map<String, NotificationService> notificationServices;

    /**
     * Constructor Injection - รับ NotificationService ทุกตัวที่มีใน Spring Context
     * นี่คือตัวอย่างของ Polymorphism - รับ Interface แต่ได้ Implementation
     * ที่แตกต่างกัน
     */
    @Autowired
    public NotificationManager(List<NotificationService> services) {
        // สร้าง Map เพื่อเข้าถึง service ตามประเภท
        this.notificationServices = services.stream()
                .collect(Collectors.toMap(
                        NotificationService::getType,
                        service -> service));

        System.out.println("NotificationManager initialized with " + services.size() + " services:");
        services.forEach(s -> System.out.println("  - " + s.getType()));
    }

    /**
     * ส่งการแจ้งเตือนผ่านช่องทางที่ระบุ
     * ใช้ Polymorphism - เรียก method เดียวกันแต่ทำงานต่างกัน
     */
    public boolean sendNotification(String type, String to, String subject, String message) {
        NotificationService service = notificationServices.get(type.toUpperCase());
        if (service == null) {
            System.out.println("Unknown notification type: " + type);
            return false;
        }
        return service.sendNotification(to, subject, message);
    }

    /**
     * ส่งการแจ้งเตือนการจองผ่านทุกช่องทางที่พร้อมใช้งาน
     * ตัวอย่าง Polymorphism - เรียก method เดียวกันกับทุก implementation
     */
    public void sendBookingConfirmationToAll(String email, String phone, String bookingCode,
            String routeName, String seatNumber) {
        notificationServices.values().forEach(service -> {
            if (service.isAvailable()) {
                String recipient = service.getType().equals("EMAIL") ? email : phone;
                service.sendBookingConfirmation(recipient, bookingCode, routeName, seatNumber);
            }
        });
    }

    /**
     * ส่งการแจ้งเตือนยกเลิกการจองผ่านทุกช่องทาง
     */
    public void sendCancellationToAll(String email, String phone, String bookingCode) {
        notificationServices.values().forEach(service -> {
            if (service.isAvailable()) {
                String recipient = service.getType().equals("EMAIL") ? email : phone;
                service.sendCancellationNotification(recipient, bookingCode);
            }
        });
    }

    /**
     * ดึง service ตามประเภท
     */
    public NotificationService getService(String type) {
        return notificationServices.get(type.toUpperCase());
    }

    /**
     * ดึงรายชื่อ service ทั้งหมดที่พร้อมใช้งาน
     */
    public List<String> getAvailableServices() {
        return notificationServices.entrySet().stream()
                .filter(e -> e.getValue().isAvailable())
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }
}
