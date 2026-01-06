# ภาคผนวก - การประยุกต์ใช้แนวคิด Object-Oriented Programming

## สารบัญ
1. [การประยุกต์ใช้แนวคิด Inheritance](#1-การประยุกต์ใช้แนวคิด-inheritance-การสืบทอด)
2. [การประยุกต์ใช้แนวคิด Polymorphism](#2-การประยุกต์ใช้แนวคิด-polymorphism-ความหลากหลายของรูปแบบ)
3. [การประยุกต์ใช้แนวคิด Aggregation/Composition](#3-การประยุกต์ใช้แนวคิด-aggregationcomposition)
4. [การนำเข้าข้อมูลจากไฟล์ (File Input)](#4-การนำเข้าข้อมูลจากไฟล์-file-input)
5. [การใช้เทคนิคในการเรียงลำดับข้อมูล (Data Sorting)](#5-การใช้เทคนิคในการเรียงลำดับข้อมูล-data-sorting)
6. [การใช้เทคนิคในการค้นหาข้อมูล (Data Searching)](#6-การใช้เทคนิคในการค้นหาข้อมูล-data-searching)
7. [ปริมาณงานและขอบเขตของโปรแกรม](#7-ปริมาณงานและขอบเขตของโปรแกรม)
8. [สรุปรวม OOP Concepts](#8-สรุปรวม-oop-concepts)

---

## 1. การประยุกต์ใช้แนวคิด Inheritance (การสืบทอด)

### 1.1 หลักการ
Inheritance (การสืบทอด) คือกระบวนการที่ Class หนึ่งสามารถรับคุณสมบัติ (attributes) และพฤติกรรม (methods) จาก Class อื่นได้ โดย Class ที่สืบทอดเรียกว่า Subclass และ Class ที่ถูกสืบทอดเรียกว่า Superclass

### 1.2 การนำไปใช้ในโปรเจค

ในระบบ YeEP ได้ใช้หลักการ Inheritance โดยสร้าง Abstract Class ชื่อ `BaseEntity` เป็น Superclass ที่เก็บ fields พื้นฐานที่ทุก Entity ต้องมี และให้ Entity อื่นๆ สืบทอด

**ตำแหน่งที่ใช้ Inheritance (4 แห่ง):**

| ลำดับ | Subclass | Superclass | ไฟล์ |
|-------|----------|------------|------|
| 1 | `User` | `BaseEntity` | `com/yeep/entity/User.java` |
| 2 | `BusRoute` | `BaseEntity` | `com/yeep/entity/BusRoute.java` |
| 3 | `BusTrip` | `BaseEntity` | `com/yeep/entity/BusTrip.java` |
| 4 | `Booking` | `BaseEntity` | `com/yeep/entity/Booking.java` |

### 1.3 ตัวอย่างโค้ด

**BaseEntity.java - Superclass (Abstract)**
```java
@MappedSuperclass
public abstract class BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters, Setters...
}
```

**User.java - Subclass ที่สืบทอดจาก BaseEntity**
```java
public class User extends BaseEntity {
    private String username;
    private String email;
    private String password;
    private String role;
    // สามารถใช้ id, createdAt, updatedAt ได้โดยไม่ต้องประกาศซ้ำ
}
```

### 1.4 ประโยชน์ที่ได้รับ
1. **ลดการเขียนโค้ดซ้ำ** - ไม่ต้องประกาศ id, createdAt, updatedAt ในทุก Entity
2. **ง่ายต่อการบำรุงรักษา** - แก้ไขที่ BaseEntity จะมีผลกับทุก Entity
3. **สร้างโครงสร้างที่เป็นระบบ** - Entity ทั้งหมดมีรูปแบบเดียวกัน

---

## 2. การประยุกต์ใช้แนวคิด Polymorphism (ความหลากหลายของรูปแบบ)

### 2.1 หลักการ
Polymorphism (ความหลากหลายของรูปแบบ) คือความสามารถที่ Object หลายชนิดสามารถตอบสนองต่อ method เดียวกันได้ในรูปแบบที่แตกต่างกัน ทำให้สามารถใช้ Interface หรือ Superclass เป็นชนิดข้อมูลได้

### 2.2 การนำไปใช้ในโปรเจค

ในระบบ YeEP ได้ใช้หลักการ Polymorphism ผ่าน Spring Data JPA โดยใช้ `JpaRepository<T, ID>` เป็น Interface หลักที่ Repository ทั้งหมด implement

**ตำแหน่งที่ใช้ Polymorphism (4 แห่ง):**

| ลำดับ | Repository | Interface ที่ Extend | ไฟล์ |
|-------|------------|---------------------|------|
| 1 | `BookingRepository` | `JpaRepository<Booking, Long>` | `repository/BookingRepository.java` |
| 2 | `UserRepository` | `JpaRepository<User, Long>` | `repository/UserRepository.java` |
| 3 | `BusRouteRepository` | `JpaRepository<BusRoute, Long>` | `repository/BusRouteRepository.java` |
| 4 | `BusTripRepository` | `JpaRepository<BusTrip, Long>` | `repository/BusTripRepository.java` |

### 2.3 ตัวอย่างโค้ด

**JpaRepository - Interface หลัก (จาก Spring Data JPA)**
```java
public interface JpaRepository<T, ID> {
    List<T> findAll();
    Optional<T> findById(ID id);
    T save(T entity);
    void delete(T entity);
    long count();
}
```

**BookingRepository - Implement JpaRepository สำหรับ Booking**
```java
public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByUserAndStatus(User user, String status);
    List<String> findBookedSeatsByTripId(Long tripId);
}
```

**UserRepository - Implement JpaRepository สำหรับ User**
```java
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    boolean existsByUsername(String username);
}
```

### 2.4 ประโยชน์ที่ได้รับ
1. **ใช้ method เดียวกันกับ Entity ต่างๆ** - `save()`, `findAll()`, `delete()` ใช้ได้กับทุก Repository
2. **ลดการเขียนโค้ดซ้ำ** - Spring Data JPA สร้าง implementation ให้อัตโนมัติ
3. **ยืดหยุ่นในการใช้งาน** - สามารถเพิ่ม custom method ได้ตามต้องการ

---

## 3. การประยุกต์ใช้แนวคิด Aggregation/Composition

### 3.1 หลักการ

**Aggregation** คือความสัมพันธ์แบบ "has-a" ที่ Whole และ Part สามารถอยู่แยกกันได้ เมื่อลบ Whole ไม่จำเป็นต้องลบ Part ตามไปด้วย

**Composition** คือความสัมพันธ์แบบ "has-a" ที่แข็งแกร่งกว่า โดย Part ไม่สามารถอยู่ได้โดยไม่มี Whole เมื่อลบ Whole ต้องลบ Part ทั้งหมดด้วย

### 3.2 การนำไปใช้ในโปรเจค - Aggregation

**ตำแหน่งที่ใช้ Aggregation (3 แห่ง):**

| ลำดับ | Class | อ้างอิงถึง | Annotation | ไฟล์ | บรรทัด |
|-------|-------|-----------|------------|------|--------|
| 1 | `BusTrip` | `BusRoute` | `@ManyToOne` | `entity/BusTrip.java` | 20 |
| 2 | `Booking` | `BusTrip` | `@ManyToOne` | `entity/Booking.java` | 22 |
| 3 | `Booking` | `User` | `@ManyToOne` | `entity/Booking.java` | 26 |

**ตัวอย่างโค้ด Aggregation:**
```java
// BusTrip.java - มีความสัมพันธ์กับ BusRoute
public class BusTrip extends BaseEntity {
    @ManyToOne  // Aggregation: Trip อ้างอิงถึง Route
    @JoinColumn(name = "route_id")
    private BusRoute route;
}

// Booking.java - มีความสัมพันธ์กับ BusTrip และ User
public class Booking extends BaseEntity {
    @ManyToOne  // Aggregation: Booking อ้างอิงถึง Trip
    @JoinColumn(name = "trip_id")
    private BusTrip trip;
    
    @ManyToOne  // Aggregation: Booking อ้างอิงถึง User
    @JoinColumn(name = "user_id")
    private User user;
}
```

### 3.3 การนำไปใช้ในโปรเจค - Composition

**ตำแหน่งที่ใช้ Composition (2 แห่ง):**

| ลำดับ | Whole Class | Part Class | ไฟล์ | บรรทัด |
|-------|-------------|------------|------|--------|
| 1 | `TripSchedule` | `TripTimeSlot` | `service/BusTripService.java` | 165-219 |
| 2 | `UserProfile` | `ContactInfo`, `Preferences` | `service/UserService.java` | 279-331 |

**ตัวอย่างโค้ด Composition #1:**
```java
// BusTripService.java - TripSchedule owns TripTimeSlot
public static class TripSchedule {
    private String scheduleName;
    private LocalDate date;
    // Composition: TripSchedule owns these TripTimeSlots
    private List<TripTimeSlot> timeSlots;
    
    public TripSchedule(String scheduleName, LocalDate date) {
        this.scheduleName = scheduleName;
        this.date = date;
        // Composition: สร้าง Part พร้อมกับ Whole
        this.timeSlots = new ArrayList<>();
    }
    
    // ล้าง time slots (ลบ Part ทั้งหมดเมื่อ Whole ถูกทำลาย)
    public void clearAllTimeSlots() {
        timeSlots.clear();
    }
    
    // Inner Class: Part ที่ขึ้นอยู่กับ Whole
    public static class TripTimeSlot {
        private LocalTime departure;
        private LocalTime arrival;
        private int capacity;
    }
}
```

**ตัวอย่างโค้ด Composition #2:**
```java
// UserService.java - UserProfile owns ContactInfo และ Preferences
public static class UserProfile {
    private String username;
    // Composition: UserProfile owns ContactInfo
    private ContactInfo contactInfo;
    // Composition: UserProfile owns Preferences
    private Preferences preferences;
    
    public UserProfile(String username) {
        this.username = username;
        // Composition: สร้าง Part objects พร้อมกับ Whole
        this.contactInfo = new ContactInfo();
        this.preferences = new Preferences();
    }
    
    // เมื่อ UserProfile ถูกทำลาย, Parts ทั้งหมดจะถูกทำลายด้วย
    public void destroy() {
        this.contactInfo = null;
        this.preferences = null;
    }
    
    // Inner Classes
    public static class ContactInfo { ... }
    public static class Preferences { ... }
}
```

### 3.4 ประโยชน์ที่ได้รับ
1. **ความยืดหยุ่น (Aggregation)** - สามารถอ้างอิงข้อมูลได้โดยไม่ผูกมัด lifecycle
2. **ควบคุม lifecycle ได้ (Composition)** - Part ถูกสร้างและทำลายพร้อมกับ Whole
3. **ลดการซ้ำซ้อนของข้อมูล** - ใช้ foreign key อ้างอิงแทนการ copy ข้อมูล

---

## 4. การนำเข้าข้อมูลจากไฟล์ (File Input)

### 4.1 หลักการ
File I/O คือการอ่านและเขียนข้อมูลจากไฟล์ ซึ่งเป็นวิธีการจัดเก็บข้อมูลแบบถาวร (Persistent Storage) ในโปรเจคนี้ใช้ `FileService` สำหรับจัดการไฟล์ทุกประเภท

### 4.2 การนำไปใช้ในโปรเจค

**ตำแหน่งที่ใช้ File I/O (FileService.java):**

| ลำดับ | Method | จุดประสงค์ | ประเภทไฟล์ |
|-------|--------|-----------|-----------|
| 1 | `readTextFile()` | อ่านไฟล์ Text | Text File |
| 2 | `readCsvFile()` | อ่านไฟล์ CSV | CSV File |
| 3 | `writeTextFile()` | เขียนไฟล์ Text | Text File |
| 4 | `uploadProfileImage()` | อัพโหลดรูปโปรไฟล์ | Binary File (Image) |
| 5 | `getProfileImage()` | ดึงรูปโปรไฟล์ | Binary File (Image) |

### 4.3 ตัวอย่างโค้ด

**อ่านไฟล์ Text:**
```java
public List<String> readTextFile(String filePath) throws IOException {
    Path path = Paths.get(filePath);
    return Files.readAllLines(path, StandardCharsets.UTF_8);
}
```

**อ่านไฟล์ CSV:**
```java
public List<Map<String, String>> readCsvFile(String filePath) throws IOException {
    List<Map<String, String>> result = new ArrayList<>();
    List<String> lines = readTextFile(filePath);
    
    if (lines.isEmpty()) return result;
    
    String[] headers = lines.get(0).split(",");
    for (int i = 1; i < lines.size(); i++) {
        String[] values = lines.get(i).split(",");
        Map<String, String> row = new HashMap<>();
        for (int j = 0; j < headers.length && j < values.length; j++) {
            row.put(headers[j].trim(), values[j].trim());
        }
        result.add(row);
    }
    return result;
}
```

**เขียนไฟล์ Text:**
```java
public void writeTextFile(String filePath, List<String> lines) throws IOException {
    Path path = Paths.get(filePath);
    Files.write(path, lines, StandardCharsets.UTF_8);
}
```

### 4.4 ประโยชน์ที่ได้รับ
1. **รองรับหลายประเภทไฟล์** - Text, CSV, และ Binary (รูปภาพ)
2. **จัดการข้อมูลได้ยืดหยุ่น** - อ่าน เขียน และอัพโหลดไฟล์
3. **รักษาความปลอดภัย** - มีการ validate ขนาดและประเภทไฟล์

---

## 5. การใช้เทคนิคในการเรียงลำดับข้อมูล (Data Sorting)

### 5.1 หลักการ
Data Sorting คือกระบวนการจัดเรียงข้อมูลในลำดับที่ต้องการ ในโปรเจคนี้ใช้ **Selection Sort Algorithm** ซึ่งเป็นอัลกอริทึมที่เข้าใจง่ายและเหมาะสำหรับการเรียนรู้

**Selection Sort Algorithm:**
1. หาค่าที่น้อยที่สุดในส่วนที่ยังไม่ได้เรียง
2. สลับค่านั้นกับตำแหน่งแรกของส่วนที่ยังไม่ได้เรียง
3. ทำซ้ำจนครบทุกตำแหน่ง

**Time Complexity:** O(n²) | **Space Complexity:** O(1)

### 5.2 การนำไปใช้ในโปรเจค

**ตำแหน่งที่ใช้ Data Sorting (2 แห่ง):**

| ลำดับ | Method | Class | ไฟล์ | บรรทัด | จุดประสงค์ |
|-------|--------|-------|------|--------|-----------|
| 1 | `sortBookings()` | `BookingService` | `BookingService.java` | 150-189 | เรียงลำดับการจองตามวันที่/สถานะ/สาย/ที่นั่ง |
| 2 | `sortTripsByDepartureTime()` | `BusTripService` | `BusTripService.java` | 118-154 | เรียงลำดับเที่ยวรถตามเวลาออกเดินทาง |

### 5.3 ตัวอย่างโค้ด Sorting #1

```java
// BookingService.java - Selection Sort สำหรับ Booking
public List<Booking> sortBookings(List<Booking> bookings, String sortBy, String order) {
    List<Booking> result = new ArrayList<>(bookings);
    Comparator<Booking> comparator = getComparator(sortBy);
    
    if (ORDER_DESC.equalsIgnoreCase(order)) {
        comparator = comparator.reversed();
    }
    
    int n = result.size();
    
    // Selection Sort Algorithm
    for (int i = 0; i < n - 1; i++) {
        int minIndex = i;
        for (int j = i + 1; j < n; j++) {
            if (comparator.compare(result.get(j), result.get(minIndex)) < 0) {
                minIndex = j;
            }
        }
        // สลับค่า (Swap)
        if (minIndex != i) {
            Booking temp = result.get(i);
            result.set(i, result.get(minIndex));
            result.set(minIndex, temp);
        }
    }
    return result;
}
```

### 5.4 ตัวอย่างโค้ด Sorting #2

```java
// BusTripService.java - Selection Sort สำหรับ BusTrip
public List<BusTrip> sortTripsByDepartureTime(List<BusTrip> trips, boolean ascending) {
    List<BusTrip> result = new ArrayList<>(trips);
    int n = result.size();
    
    // Selection Sort Algorithm
    for (int i = 0; i < n - 1; i++) {
        int selectedIndex = i;
        for (int j = i + 1; j < n; j++) {
            LocalTime timeJ = result.get(j).getDepartureTime();
            LocalTime timeSelected = result.get(selectedIndex).getDepartureTime();
            
            boolean shouldSwap = ascending 
                ? timeJ.isBefore(timeSelected)
                : timeJ.isAfter(timeSelected);
                
            if (shouldSwap) {
                selectedIndex = j;
            }
        }
        // สลับค่า (Swap)
        if (selectedIndex != i) {
            BusTrip temp = result.get(i);
            result.set(i, result.get(selectedIndex));
            result.set(selectedIndex, temp);
        }
    }
    return result;
}
```

### 5.5 ประโยชน์ที่ได้รับ
1. **แสดงผลข้อมูลอย่างเป็นระบบ** - ผู้ใช้สามารถดูข้อมูลที่เรียงลำดับแล้ว
2. **รองรับหลายเกณฑ์** - เลือกเรียงตามวันที่ สถานะ หรือเวลาได้
3. **ปรับทิศทางได้** - เรียงจากน้อยไปมาก หรือมากไปน้อย

---

## 6. การใช้เทคนิคในการค้นหาข้อมูล (Data Searching)

### 6.1 หลักการ
Data Searching คือกระบวนการค้นหาข้อมูลที่ตรงกับเงื่อนไขที่กำหนด ในโปรเจคนี้ใช้ **Sequential Search Algorithm** (Linear Search) ซึ่งเป็นอัลกอริทึมพื้นฐานที่ตรวจสอบทีละรายการ

**Sequential Search Algorithm:**
1. วนลูปตรวจสอบทีละ element ตั้งแต่ต้นจนจบ
2. เปรียบเทียบกับเงื่อนไขที่ต้องการ
3. ถ้าตรง เพิ่มเข้าผลลัพธ์
4. คืนค่าผลลัพธ์ทั้งหมด

**Time Complexity:** O(n) | **Space Complexity:** O(1)

### 6.2 การนำไปใช้ในโปรเจค

**ตำแหน่งที่ใช้ Data Searching (3 แห่ง):**

| ลำดับ | Method | Class | ไฟล์ | บรรทัด | จุดประสงค์ |
|-------|--------|-------|------|--------|-----------|
| 1 | `searchRoutes()` | `BusRouteService` | `BusRouteService.java` | 43-71 | ค้นหาเส้นทางตามต้นทาง-ปลายทาง |
| 2 | `searchUsersByRole()` | `UserService` | `UserService.java` | 220-240 | ค้นหาผู้ใช้ตาม Role |
| 3 | `searchUsersByName()` | `UserService` | `UserService.java` | 248-267 | ค้นหาผู้ใช้ตามชื่อ (partial match) |

### 6.3 ตัวอย่างโค้ด Searching #1

```java
// BusRouteService.java - Sequential Search สำหรับ BusRoute
public List<BusRoute> searchRoutes(String origin, String destination) {
    List<BusRoute> allRoutes = busRouteRepository.findAll();
    List<BusRoute> result = new ArrayList<>();
    
    // Sequential Search - วนลูปตรวจสอบทีละ element
    for (int i = 0; i < allRoutes.size(); i++) {
        BusRoute route = allRoutes.get(i);
        boolean match = true;
        
        // ตรวจสอบเงื่อนไข origin
        if (origin != null && !origin.isEmpty()) {
            if (!route.getOrigin().toLowerCase().contains(origin.toLowerCase())) {
                match = false;
            }
        }
        
        // ตรวจสอบเงื่อนไข destination
        if (destination != null && !destination.isEmpty()) {
            if (!route.getDestination().toLowerCase().contains(destination.toLowerCase())) {
                match = false;
            }
        }
        
        // ถ้าตรงเงื่อนไข เพิ่มเข้าผลลัพธ์
        if (match) {
            result.add(route);
        }
    }
    return result;
}
```

### 6.4 ตัวอย่างโค้ด Searching #2

```java
// UserService.java - Sequential Search สำหรับ User ตาม Role
public List<User> searchUsersByRole(String role) {
    List<User> allUsers = userRepository.findAll();
    List<User> result = new ArrayList<>();
    
    // Sequential Search - วนลูปตรวจสอบทีละ element
    for (int i = 0; i < allUsers.size(); i++) {
        User user = allUsers.get(i);
        
        if (role != null && !role.isEmpty()) {
            if (user.getRole() != null && 
                user.getRole().toLowerCase().equals(role.toLowerCase())) {
                result.add(user);
            }
        }
    }
    return result;
}
```

### 6.5 ตัวอย่างโค้ด Searching #3

```java
// UserService.java - Sequential Search สำหรับ User ตามชื่อ
public List<User> searchUsersByName(String namePattern) {
    List<User> allUsers = userRepository.findAll();
    List<User> result = new ArrayList<>();
    
    // Sequential Search
    for (int i = 0; i < allUsers.size(); i++) {
        User user = allUsers.get(i);
        
        if (namePattern != null && !namePattern.isEmpty()) {
            // partial match, case-insensitive
            if (user.getUsername() != null &&
                user.getUsername().toLowerCase().contains(namePattern.toLowerCase())) {
                result.add(user);
            }
        }
    }
    return result;
}
```

### 6.6 ประโยชน์ที่ได้รับ
1. **ค้นหาได้ยืดหยุ่น** - รองรับ partial match และ case-insensitive
2. **ค้นหาได้หลายเงื่อนไข** - ค้นหาตาม origin, destination, role, หรือชื่อ
3. **เข้าใจง่าย** - โค้ดอ่านง่ายและบำรุงรักษาได้ง่าย

---

## 7. ปริมาณงานและขอบเขตของโปรแกรม

### 7.1 จำนวน Class

| ประเภท | Class | จำนวน |
|--------|-------|-------|
| Entity | BaseEntity, User, Booking, BusRoute, BusTrip | 5 |
| Service | BookingService, UserService, BusRouteService, BusTripService, FileService | 5 |
| Controller | BookingController, UserController, FileController | 3 |
| Repository | BookingRepository, UserRepository, BusRouteRepository, BusTripRepository | 4 |
| DTO/Util | ApiResponse, EntityMapper, RouteScheduleConfig | 3 |
| Inner Classes | TripSchedule, TripTimeSlot, UserProfile, ContactInfo, Preferences, TripWithAvailability, TripTime | 7 |
| **รวม** | | **27 classes** |

### 7.2 จำนวน Method

| Class | จำนวน Method | Method ตัวอย่าง |
|-------|-------------|-----------------|
| **BookingService** | 21 | createBooking, cancelBooking, sortBookings |
| **UserService** | 21 | login, register, searchUsersByRole, searchUsersByName |
| **BusRouteService** | 6 | getAllRoutes, getRouteById, searchRoutes |
| **BusTripService** | 7 | getTripById, getTripsWithAvailability, sortTripsByDepartureTime |
| **FileService** | 15 | readTextFile, readCsvFile, uploadProfileImage |
| **BookingController** | 16 | bookSeats, cancelBooking, getUserBookings |
| **UserController** | 8 | login, register, getUser, updatePassword |
| **FileController** | 4 | uploadProfileImage, getProfileImage |
| **รวม** | **98 methods** | |

---

## 8. สรุปรวม OOP Concepts

| Concept | ต้องการ | มี | สถานะ | ที่ตั้ง |
|---------|--------|-----|-------|--------|
| **Inheritance** | ≥2 | 4 | ✅ ผ่าน | User, BusRoute, BusTrip, Booking |
| **Polymorphism** | ≥2 | 4 | ✅ ผ่าน | BookingRepo, UserRepo, BusRouteRepo, BusTripRepo |
| **Aggregation** | ≥2 | 3 | ✅ ผ่าน | BusTrip→Route, Booking→Trip, Booking→User |
| **Composition** | ≥2 | 2 | ✅ ผ่าน | TripSchedule, UserProfile |
| **Data Sorting** | ≥2 | 2 | ✅ ผ่าน | BookingService, BusTripService |
| **Data Searching** | ≥2 | 3 | ✅ ผ่าน | BusRouteService, UserService (x2) |
| **File I/O** | ≥1 | 1 | ✅ ผ่าน | FileService |

---

**สรุป: โปรเจค YeEP มีการใช้หลักการ OOP ครบทุกข้อตามที่กำหนด**
