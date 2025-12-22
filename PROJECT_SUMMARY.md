# สรุปโครงสร้างโปรเจค YeEP (proj6393)

สรุปนี้รวบรวมภาพรวมของโค้ดทั้ง frontend (Flutter), backend (Spring Boot), และโมดูล gps-simple ที่อยู่ใน workspace เพื่อให้อ่านและอ้างอิงได้ง่าย

## โครงสร้างหลัก

- Frontend (Flutter app): [yeep_app](yeep_app)
  - Entry point: [yeep_app/lib/main.dart](yeep_app/lib/main.dart)
  - หน้าจอสำคัญ (screens):
    - [yeep_app/lib/screens/login_screen.dart](yeep_app/lib/screens/login_screen.dart)
    - [yeep_app/lib/screens/home_screen.dart](yeep_app/lib/screens/home_screen.dart)
    - Driver-related:
      - [yeep_app/lib/screens/driver_home_screen.dart](yeep_app/lib/screens/driver_home_screen.dart)
      - [yeep_app/lib/screens/driver_check_bookings_screen.dart](yeep_app/lib/screens/driver_check_bookings_screen.dart)
      - [yeep_app/lib/screens/driver_booking_detail_screen.dart](yeep_app/lib/screens/driver_booking_detail_screen.dart)
    - Booking flow screens: select/search/select_seat/confirm/success etc. (อยู่ใน `lib/screens`)
  - Services:
    - Booking API client: [yeep_app/lib/services/booking_service.dart](yeep_app/lib/services/booking_service.dart)
    - API helpers: [yeep_app/lib/services/api_service.dart](yeep_app/lib/services/api_service.dart)

- Backend (Java, Spring Boot): [yeep_backend](yeep_backend)
  - Maven POM: [yeep_backend/pom.xml](yeep_backend/pom.xml)
  - Entry / main app: `YeepBackendApplication` (src/main/java/com/yeep)
  - Controller: [yeep_backend/src/main/java/com/yeep/controller/BookingController.java](yeep_backend/src/main/java/com/yeep/controller/BookingController.java)
  - Service: [yeep_backend/src/main/java/com/yeep/service/BookingService.java](yeep_backend/src/main/java/com/yeep/service/BookingService.java)
  - Entities (schema):
    - [yeep_backend/src/main/java/com/yeep/entity/User.java](yeep_backend/src/main/java/com/yeep/entity/User.java)
    - [yeep_backend/src/main/java/com/yeep/entity/BusRoute.java](yeep_backend/src/main/java/com/yeep/entity/BusRoute.java)
    - [yeep_backend/src/main/java/com/yeep/entity/BusTrip.java](yeep_backend/src/main/java/com/yeep/entity/BusTrip.java)
    - [yeep_backend/src/main/java/com/yeep/entity/Booking.java](yeep_backend/src/main/java/com/yeep/entity/Booking.java)
  - Repositories and DTOs exist under `src/main/java/com/yeep` (เช่น `BookingRepository`, `TripResponse`)

- gps-simple (Standalone Java small server): [gps-simple](gps-simple)
  - Main launcher: [gps-simple/src/Main.java](gps-simple/src/Main.java) — เรียก `GpsHttpServer` บนพอร์ต 8090
  - ใช้สำหรับจำลองบริการ GPS (มี `GpsSource`, `DefaultGpsService`, `GpsHttpServer`)

## API (backend)
 - Base path: `/api/booking` (จาก `BookingController`)
 - สำคัญ endpoints:
   - `GET /api/booking/routes` — ดึงสายรถ
   - `GET /api/booking/trips?routeId=&date=` — ดึงเที่ยวรถของสายและวันที่
   - `GET /api/booking/trips/{tripId}/seats` — ดึงที่นั่งและที่นั่งที่ถูกจอง
   - `POST /api/booking/book` — จองที่นั่ง (body: tripId, username, seatNumbers)
   - `DELETE /api/booking/bookings/{bookingId}?username=` — ยกเลิกการจอง
   - `GET /api/booking/driver/bookings?routeId=&date=` — รายการจองสำหรับคนขับ
   - `POST /api/booking/init-data` และ `POST /api/booking/reset-data` — สร้าง/รีเซ็ตข้อมูลทดสอบ

ส่วน response ปกติจะห่อด้วย `{ success: boolean, <key>: data }` ตาม pattern ที่ใช้ใน controller

## โมเดลข้อมูลสำคัญ
 - `User`:
   - `id`, `username`, `email`, `phone`, `password`, `role` (user|driver), `createdAt`
 - `BusRoute`:
   - `id`, `name`, `color`, `origin`, `destination`, `hasTrips`, `timeRange`
 - `BusTrip`:
   - `id`, `route`(FK), `tripNumber` (nullable), `departureTime`, `arrivalTime`, `tripDate`, `totalSeats`
 - `Booking`:
   - `id`, `bookingCode`, `trip`(FK), `user`(FK), `seatNumber`, `status`, `bookedAt`, `cancelledAt`

## Frontend — การเชื่อมต่อ
 - `yeep_app/lib/services/booking_service.dart` ใช้ baseUrl เป็น `http://localhost:8081/api/booking` (adapt สำหรับ Android emulator ด้วย `10.0.2.2`).
 - หน้าจอไดรเวอร์ (`driver_*`) เรียก `BookingService.getRoutes()` และ `BookingService.getBookingsByRoute(routeId, date)` เพื่อแสดงรายการจอง

## gps-simple
 - เป็นโปรเจคเล็กสำหรับทดสอบ GPS server — รันบนพอร์ต 8090 ตาม `Main.java` (ไม่เกี่ยวกับ backend Spring Boot ที่รันบน 8081 โดยค่าเริ่มต้น)

## ข้อเสนอแนะ / Next steps
 - ผมได้อ่านโค้ดหลักและสรุปไว้ที่นี่แล้ว — ถ้าต้องการผมจะ:
   1) สร้างแผนการตรวจสอบ unit/integration tests (backend + frontend)
   2) รัน backend locally และทดสอบ endpoints (ต้องมี Java 17 + PostgreSQL config)
   3) ปรับ `booking_service.dart` ให้รับค่า base URL จาก `.env` แทน hardcode (ถ้าต้องการ)

ไฟล์ที่อ่านและอ้างอิงหลัก: `yeep_app/lib/main.dart`, `yeep_app/lib/services/booking_service.dart`, `yeep_backend/src/main/java/com/yeep/controller/BookingController.java`, `yeep_backend/src/main/java/com/yeep/service/BookingService.java`, และ entity files.

---
สั่งให้ผมทำข้อใดต่อ: ลงมือรัน backend, ปรับ baseUrl, หรือสร้างชุดสรุป endpoint แบบละเอียด?
