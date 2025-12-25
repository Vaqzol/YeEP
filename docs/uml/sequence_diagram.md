# Sequence Diagram - YeEP Bus Ticketing System

## 🎫 1. การจองตั๋ว (Booking Flow)

```mermaid
sequenceDiagram
    autonumber
    
    participant U as 👤 User (Flutter)
    participant HS as 🏠 HomeScreen
    participant BS as 🔌 BookingService
    participant BC as 🖥️ BookingController
    participant BServ as 📦 BookingService
    participant BR as 🗄️ BookingRepository
    participant NM as 🔔 NotificationManager
    participant ES as ✉️ EmailService
    participant SS as 📱 SmsService
    
    U->>HS: เลือกต้นทาง-ปลายทาง
    HS->>BS: getRoutes()
    BS->>BC: GET /api/booking/routes
    BC-->>BS: routes[]
    BS-->>HS: แสดงผลการค้นหา
    
    U->>HS: เลือกเที่ยวรถ
    HS->>BS: getTrips(routeId, date)
    BS->>BC: GET /api/booking/trips
    BC-->>BS: trips[]
    BS-->>HS: แสดงเที่ยวรถ
    
    U->>HS: เลือกที่นั่ง
    HS->>BS: getTripSeats(tripId)
    BS->>BC: GET /api/booking/trips/{id}/seats
    BC-->>BS: seats[], bookedSeats[]
    BS-->>HS: แสดงผังที่นั่ง
    
    U->>HS: ยืนยันการจอง
    HS->>BS: bookSeats(tripId, username, seats)
    BS->>BC: POST /api/booking/book
    BC->>BServ: createBooking()
    BServ->>BR: save(booking)
    BR-->>BServ: booking
    
    Note over BServ,SS: Polymorphism - ส่งการแจ้งเตือนทุกช่องทาง
    BServ->>NM: sendBookingConfirmationToAll()
    NM->>ES: sendNotification()
    NM->>SS: sendNotification()
    
    BServ-->>BC: booking
    BC-->>BS: {success: true, bookings: [...]}
    BS-->>HS: จองสำเร็จ
    HS-->>U: แสดงหน้าจองสำเร็จ
```

---

## 🔐 2. การเข้าสู่ระบบ (Login Flow)

```mermaid
sequenceDiagram
    autonumber
    
    participant U as 👤 User
    participant LS as 🔐 LoginScreen
    participant AS as 🔌 ApiService
    participant UC as 🖥️ UserController
    participant US as 📦 UserService
    participant UR as 🗄️ UserRepository
    
    U->>LS: กรอก username, password
    LS->>AS: login(username, password)
    AS->>UC: POST /api/login
    UC->>US: login(request)
    US->>UR: findByUsername(username)
    UR-->>US: Optional<User>
    
    alt ไม่พบ user
        US-->>UC: throw Exception("ไม่พบชื่อผู้ใช้งานนี้")
        UC-->>AS: {success: false, message: "..."}
        AS-->>LS: error
        LS-->>U: แสดง error message
    else รหัสผ่านไม่ถูกต้อง
        US-->>UC: throw Exception("รหัสผ่านไม่ถูกต้อง")
        UC-->>AS: {success: false, message: "..."}
        AS-->>LS: error
        LS-->>U: แสดง error message
    else สำเร็จ
        US-->>UC: UserResponse
        UC-->>AS: {success: true, data: user}
        AS-->>LS: user data
        
        alt role == "driver"
            LS->>U: ไปหน้า DriverHomeScreen
        else role == "user"
            LS->>U: ไปหน้า HomeScreen
        end
    end
```

---

## 🖼️ 3. การเปลี่ยนรูปโปรไฟล์ (File Input Flow)

```mermaid
sequenceDiagram
    autonumber
    
    participant U as 👤 User
    participant AS as 📱 AccountScreen
    participant IP as 📷 ImagePicker
    participant FS as 💾 FileSystem
    participant SP as 🔧 SharedPreferences
    
    U->>AS: แตะที่รูปโปรไฟล์
    AS->>AS: showImagePickerOptions()
    AS-->>U: แสดง Bottom Sheet
    
    alt เลือกจาก Gallery
        U->>AS: เลือก "แกลเลอรี่"
        AS->>IP: pickImage(ImageSource.gallery)
    else ถ่ายรูป
        U->>AS: เลือก "กล้อง"
        AS->>IP: pickImage(ImageSource.camera)
    end
    
    IP-->>AS: XFile?
    
    alt ไม่เลือกรูป
        AS-->>U: ไม่ทำอะไร
    else เลือกรูปแล้ว
        AS->>AS: ตรวจสอบขนาดไฟล์
        
        alt ขนาด > 5MB
            AS-->>U: แสดง error "ไฟล์ใหญ่เกินไป"
        else ขนาด <= 5MB
            AS->>FS: getApplicationDocumentsDirectory()
            FS-->>AS: directory path
            AS->>FS: copy(image, savedPath)
            FS-->>AS: saved
            AS->>SP: setString("profile_image_xxx", path)
            SP-->>AS: saved
            AS-->>U: แสดงรูปใหม่ + SnackBar "สำเร็จ"
        end
    end
```

---

## 📍 4. การติดตาม GPS (GPS Tracking Flow)

```mermaid
sequenceDiagram
    autonumber
    
    participant D as 🚗 Driver (Flutter)
    participant DH as 🏠 DriverHomeScreen
    participant GL as 📍 Geolocator
    participant GS as 🌐 GPS Server (8090)
    participant U as 👤 User (Flutter)
    participant MS as 🗺️ MapScreen
    
    Note over D,GS: Driver ส่งตำแหน่งทุก 5 วินาที
    
    loop Every 5 seconds
        D->>DH: กำลังขับรถ
        DH->>GL: getCurrentPosition()
        GL-->>DH: Position(lat, lng)
        DH->>GS: POST /send-gps {bus, lat, lng, routeId}
        GS-->>DH: OK
    end
    
    Note over U,GS: User ดึงตำแหน่งทุก 3 วินาที
    
    loop Every 3 seconds
        U->>MS: เปิดหน้าแผนที่
        MS->>GS: GET /all-gps
        GS-->>MS: {driver1: {lat, lng}, driver2: {...}}
        MS-->>U: แสดงตำแหน่งรถบนแผนที่
    end
```

---

## 🔔 5. Polymorphism - Notification Flow

```mermaid
sequenceDiagram
    autonumber
    
    participant BC as 🖥️ BookingController
    participant BS as 📦 BookingService
    participant NM as 🔔 NotificationManager
    participant NS as 📬 NotificationService
    participant ES as ✉️ EmailService
    participant SS as 📱 SmsService
    participant PS as 🔔 PushService
    
    Note over BC,PS: แสดงการใช้ Polymorphism
    
    BC->>BS: createBooking()
    BS->>NM: sendBookingConfirmationToAll(email, phone, ...)
    
    Note right of NM: วนลูปทุก service ที่ implements NotificationService
    
    loop for each NotificationService
        NM->>NS: isAvailable()
        alt service พร้อมใช้งาน
            NM->>NS: sendBookingConfirmation(...)
            Note right of NS: Polymorphism:<br/>เรียก method เดียวกัน<br/>แต่ทำงานต่างกัน
        end
    end
    
    NM->>ES: sendBookingConfirmation()
    Note right of ES: ส่ง Email
    ES-->>NM: true
    
    NM->>SS: sendBookingConfirmation()
    Note right of SS: ส่ง SMS
    SS-->>NM: true
    
    NM->>PS: sendBookingConfirmation()
    Note right of PS: ส่ง Push Notification
    PS-->>NM: true
    
    NM-->>BS: done
    BS-->>BC: booking result
```

---

## 📝 หมายเหตุ

### การใช้ OOP Concepts

1. **Inheritance**: 
   - `User`, `Booking`, `BusRoute`, `BusTrip` สืบทอดจาก `BaseEntity`

2. **Polymorphism**: 
   - `NotificationService` interface มีหลาย implementation
   - `NotificationManager` เรียกใช้ผ่าน interface โดยไม่ต้องรู้ว่าเป็น implementation ไหน

3. **File Input**: 
   - `AccountScreen` รองรับการอัพโหลดรูปภาพจาก gallery/camera
   - ตรวจสอบขนาดไฟล์ไม่เกิน 5MB

4. **Data Sorting**: 
   - `BookingService.sortBookings()` ใช้ Comparator สำหรับเรียงลำดับข้อมูล
