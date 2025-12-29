# หลักการ OOP ที่ใช้ในโปรแกรม (Java)

## ภาพรวมหลักการ OOP ที่ใช้

| หลักการ | ไฟล์ | คำอธิบาย |
|---------|------|----------|
| **Inheritance** | `BaseEntity.java` | Abstract class ที่ Entity อื่นสืบทอด |
| **Polymorphism** | `JpaRepository` | Interface ที่ Repository ทั้ง 4 ตัว implement |
| **Aggregation/Composition** | Entity relationships | ความสัมพันธ์ระหว่าง Entity |
| **File Input** | `FileService.java` | อ่าน/เขียนไฟล์ |
| **Data Sorting** | `BookingService.java` | เรียงลำดับข้อมูล |
| **Data Searching** | `BusRouteService.java` | ค้นหาข้อมูล |

---

## 1. Inheritance (การสืบทอด)

### ไฟล์: `com/yeep/entity/BaseEntity.java`

```java
package com.yeep.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * BaseEntity - Abstract class สำหรับ Entity ทั้งหมด
 * 
 * ใช้หลักการ Inheritance โดยให้ Entity อื่นๆ สืบทอดคุณสมบัติร่วม:
 * - id: Primary Key
 * - createdAt: วันที่สร้าง
 * - updatedAt: วันที่แก้ไขล่าสุด
 */
@MappedSuperclass
public abstract class BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Lifecycle callbacks - เรียกอัตโนมัติก่อนบันทึก
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters และ Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
```

### Class ที่สืบทอด:

```java
// User.java - สืบทอดจาก BaseEntity
public class User extends BaseEntity {
    private String username;
    private String email;
    private String password;
    private String role;
    // ...
}

// Booking.java - สืบทอดจาก BaseEntity
public class Booking extends BaseEntity {
    private String bookingCode;
    private String seatNumber;
    private String status;
    // ...
}

// BusRoute.java - สืบทอดจาก BaseEntity
public class BusRoute extends BaseEntity {
    private String name;
    private String color;
    private String origin;
    private String destination;
    // ...
}

// BusTrip.java - สืบทอดจาก BaseEntity
public class BusTrip extends BaseEntity {
    private Integer tripNumber;
    private String departureTime;
    private String arrivalTime;
    // ...
}
```

### แผนภาพ Inheritance:

```
         ┌─────────────────┐
         │   BaseEntity    │  (Abstract Class)
         │─────────────────│
         │ - id            │
         │ - createdAt     │
         │ - updatedAt     │
         │─────────────────│
         │ + onCreate()    │
         │ + onUpdate()    │
         └────────┬────────┘
                  │ extends
     ┌────────────┼────────────┬─────────────┐
     │            │            │             │
┌────┴────┐ ┌─────┴────┐ ┌─────┴────┐ ┌──────┴─────┐
│  User   │ │ Booking  │ │ BusRoute │ │  BusTrip   │
└─────────┘ └──────────┘ └──────────┘ └────────────┘
```

---

## 2. Polymorphism (พหุสัณฐาน)

### หลักการ Polymorphism ที่ใช้ใน Repository

ระบบใช้หลักการ Polymorphism ผ่าน `JpaRepository<T, ID>` interface ของ Spring Data JPA
โดย Repository ทั้ง 4 ตัวสืบทอดจาก interface เดียวกัน แต่ทำงานกับ Entity ที่แตกต่างกัน

### Interface หลัก: JpaRepository

```java
// Spring Data JPA's JpaRepository interface
public interface JpaRepository<T, ID> extends ... {
    List<T> findAll();
    Optional<T> findById(ID id);
    T save(T entity);
    void delete(T entity);
    void deleteById(ID id);
    long count();
    // ... และอื่นๆ
}
```

### Implementation 1: BookingRepository

```java
package com.yeep.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.yeep.entity.Booking;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {
    
    // หาการจองของ user
    List<Booking> findByUserOrderByBookedAtDesc(User user);
    
    // หาการจองของ user ที่ยังไม่ยกเลิก
    List<Booking> findByUserAndStatusOrderByBookedAtDesc(User user, String status);
    
    // หาการจองของเที่ยวรถ
    List<Booking> findByTripAndStatus(BusTrip trip, String status);
    
    // หาที่นั่งที่จองแล้วของเที่ยวรถ
    @Query("SELECT b.seatNumber FROM Booking b WHERE b.trip.id = :tripId AND b.status = 'confirmed'")
    List<String> findBookedSeatsByTripId(@Param("tripId") Long tripId);
    
    // ตรวจสอบว่าที่นั่งถูกจองแล้วหรือยัง
    boolean existsByTripAndSeatNumberAndStatus(BusTrip trip, String seatNumber, String status);
    
    // หาจาก booking code
    Optional<Booking> findByBookingCode(String bookingCode);
}
```

### Implementation 2: UserRepository

```java
package com.yeep.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.yeep.entity.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByUsername(String username);
    
    Optional<User> findByEmail(String email);
    
    boolean existsByUsername(String username);
    
    boolean existsByEmail(String email);
}
```

### Implementation 3: BusRouteRepository

```java
package com.yeep.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.yeep.entity.BusRoute;

@Repository
public interface BusRouteRepository extends JpaRepository<BusRoute, Long> {
    
    // ค้นหาเส้นทาง (Data Searching)
    @Query("SELECT r FROM BusRoute r WHERE " +
           "(:origin IS NULL OR LOWER(r.origin) LIKE LOWER(CONCAT('%', :origin, '%'))) AND " +
           "(:destination IS NULL OR LOWER(r.destination) LIKE LOWER(CONCAT('%', :destination, '%')))")
    List<BusRoute> searchRoutes(@Param("origin") String origin, 
                                @Param("destination") String destination);
    
    // ดึงรายชื่อสถานที่ทั้งหมด
    @Query("SELECT DISTINCT r.origin FROM BusRoute r UNION SELECT DISTINCT r.destination FROM BusRoute r")
    List<String> findAllLocations();
}
```

### Implementation 4: BusTripRepository

```java
package com.yeep.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.yeep.entity.BusTrip;

@Repository
public interface BusTripRepository extends JpaRepository<BusTrip, Long> {
    
    List<BusTrip> findByRouteAndTripDateOrderByDepartureTime(BusRoute route, LocalDate date);
    
    List<BusTrip> findByRouteIdAndTripDateOrderByDepartureTime(Long routeId, LocalDate date);
    
    boolean existsByRouteAndTripDate(BusRoute route, LocalDate date);
}
```

### การใช้งาน Polymorphism ใน Service:

```java
@Service
public class BookingService {
    
    // Polymorphism - inject JpaRepository implementations ที่ต่างกัน
    @Autowired
    private BookingRepository bookingRepository;  // JpaRepository<Booking, Long>
    
    @Autowired
    private UserRepository userRepository;        // JpaRepository<User, Long>
    
    @Autowired
    private BusTripRepository tripRepository;     // JpaRepository<BusTrip, Long>
    
    // เรียกใช้ method เดียวกัน (save, findById, delete) 
    // แต่ทำงานกับ Entity ที่ต่างกัน - นี่คือ Polymorphism!
    
    public Booking createBooking(Long tripId, String username, String seatNumber) {
        // findById ทำงานกับ BusTrip
        BusTrip trip = tripRepository.findById(tripId)
            .orElseThrow(() -> new RuntimeException("Trip not found"));
        
        // findByUsername ทำงานกับ User
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        // save ทำงานกับ Booking
        Booking booking = new Booking();
        booking.setTrip(trip);
        booking.setUser(user);
        booking.setSeatNumber(seatNumber);
        
        return bookingRepository.save(booking);
    }
}
```

### แผนภาพ Polymorphism:

```
                    ┌────────────────────────────┐
                    │   JpaRepository<T, ID>     │  (Interface)
                    │────────────────────────────│
                    │ + findAll(): List<T>       │
                    │ + findById(ID): Optional<T>│
                    │ + save(T): T               │
                    │ + delete(T): void          │
                    └─────────────┬──────────────┘
                                  │ extends
         ┌────────────────┬───────┴───────┬────────────────┐
         │                │               │                │
┌────────┴────────┐ ┌─────┴─────┐ ┌───────┴───────┐ ┌──────┴──────┐
│BookingRepository│ │UserRepo   │ │BusRouteRepo   │ │BusTripRepo  │
│<Booking, Long>  │ │<User,Long>│ │<BusRoute,Long>│ │<BusTrip,Long>│
└─────────────────┘ └───────────┘ └───────────────┘ └─────────────┘
```

**หลักการ Polymorphism:**
- Interface เดียว (`JpaRepository`) มีหลาย implementations
- แต่ละ Repository ทำงานกับ Entity ต่างกัน (Booking, User, BusRoute, BusTrip)
- เรียกใช้ method เดียวกัน (`save`, `findById`, `delete`) แต่ทำงานกับข้อมูลคนละประเภท

---

## 3. Aggregation / Composition

### ความสัมพันธ์ระหว่าง Entity:

```
┌──────────────┐        ┌──────────────┐        ┌──────────────┐
│   BusRoute   │ 1    * │   BusTrip    │ 1    * │   Booking    │
│──────────────│────────│──────────────│────────│──────────────│
│ - name       │        │ - tripNumber │        │ - bookingCode│
│ - color      │        │ - departure  │        │ - seatNumber │
│ - origin     │        │ - arrival    │        │ - status     │
│ - destination│        │ - tripDate   │        │              │
└──────────────┘        └──────────────┘        └──────┬───────┘
                                                       │ *
                                                       │
                                                 ┌─────┴──────┐
                                                 │    User    │
                                                 │────────────│
                                                 │ - username │
                                                 │ - email    │
                                                 └────────────┘
```

### ตัวอย่างโค้ด:

```java
// BusTrip.java - Aggregation กับ BusRoute
@Entity
public class BusTrip extends BaseEntity {
    
    @ManyToOne  // หลาย Trip อยู่ใน 1 Route
    @JoinColumn(name = "route_id")
    private BusRoute route;
    
    private Integer tripNumber;
    private String departureTime;
    // ...
}

// Booking.java - Aggregation กับ BusTrip และ User
@Entity
public class Booking extends BaseEntity {
    
    @ManyToOne  // หลาย Booking อยู่ใน 1 Trip
    @JoinColumn(name = "trip_id")
    private BusTrip trip;
    
    @ManyToOne  // หลาย Booking เป็นของ 1 User
    @JoinColumn(name = "user_id")
    private User user;
    
    private String bookingCode;
    private String seatNumber;
    // ...
}
```

---

## 4. File Input (การนำเข้าข้อมูลจากไฟล์)

### ไฟล์: `com/yeep/service/FileService.java`

```java
@Service
public class FileService {
    
    // ค่าคงที่
    public static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    public static final List<String> ALLOWED_IMAGE_EXTENSIONS = 
        Arrays.asList("jpg", "jpeg", "png", "gif", "webp");
    
    /**
     * อ่านไฟล์ข้อความ (File Input)
     */
    public List<String> readTextFile(String filePath) throws IOException {
        List<String> lines = new ArrayList<>();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                lines.add(line);
            }
        }
        
        return lines;
    }
    
    /**
     * อ่านไฟล์ CSV
     */
    public List<Map<String, String>> readCsvFile(String filePath) throws IOException {
        List<Map<String, String>> data = new ArrayList<>();
        List<String> lines = readTextFile(filePath);
        
        if (lines.isEmpty()) return data;
        
        String[] headers = lines.get(0).split(",");
        
        for (int i = 1; i < lines.size(); i++) {
            String[] values = lines.get(i).split(",");
            Map<String, String> row = new HashMap<>();
            
            for (int j = 0; j < headers.length && j < values.length; j++) {
                row.put(headers[j].trim(), values[j].trim());
            }
            
            data.add(row);
        }
        
        return data;
    }
    
    /**
     * อ่านไฟล์ไบนารี (รูปภาพ)
     */
    public byte[] readBinaryFile(String filePath) throws IOException {
        Path path = Paths.get(filePath);
        return Files.readAllBytes(path);
    }
    
    /**
     * ตรวจสอบขนาดไฟล์
     */
    public boolean validateFileSize(long fileSize) {
        return fileSize <= MAX_FILE_SIZE;
    }
    
    /**
     * ตรวจสอบนามสกุลไฟล์
     */
    public boolean validateImageExtension(String fileName) {
        String extension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        return ALLOWED_IMAGE_EXTENSIONS.contains(extension);
    }
    
    /**
     * อัพโหลดรูปโปรไฟล์
     */
    public Map<String, Object> uploadProfileImage(String username, MultipartFile file) {
        Map<String, Object> result = new HashMap<>();
        
        // ตรวจสอบไฟล์
        if (!validateFileSize(file.getSize())) {
            result.put("success", false);
            result.put("error", "ขนาดไฟล์เกิน 5 MB");
            return result;
        }
        
        if (!validateImageExtension(file.getOriginalFilename())) {
            result.put("success", false);
            result.put("error", "นามสกุลไฟล์ไม่ถูกต้อง");
            return result;
        }
        
        // บันทึกไฟล์
        try {
            Path uploadPath = Paths.get("uploads/profiles");
            Files.createDirectories(uploadPath);
            
            String newFilename = username + "_" + System.currentTimeMillis() + ".jpg";
            Path filePath = uploadPath.resolve(newFilename);
            Files.write(filePath, file.getBytes());
            
            result.put("success", true);
            result.put("path", filePath.toString());
        } catch (IOException e) {
            result.put("success", false);
            result.put("error", e.getMessage());
        }
        
        return result;
    }
}
```

---

## 5. Data Sorting (การเรียงลำดับข้อมูล)

### Algorithm: Selection Sort

**Time Complexity:** O(n²)  
**Space Complexity:** O(1)

### ไฟล์: `com/yeep/service/BookingService.java`

```java
@Service
public class BookingService {
    
    // ค่าคงที่สำหรับการเรียงลำดับ
    public static final String SORT_BY_DATE = "date";
    public static final String SORT_BY_STATUS = "status";
    public static final String SORT_BY_ROUTE = "route";
    public static final String SORT_BY_SEAT = "seat";
    public static final String ORDER_ASC = "asc";
    public static final String ORDER_DESC = "desc";
    
    /**
     * เรียงลำดับการจอง ด้วย Selection Sort Algorithm
     * 
     * Selection Sort Algorithm:
     * 1. หาค่าที่น้อยที่สุด (หรือมากที่สุด) ใน array
     * 2. สลับกับตำแหน่งแรก
     * 3. ทำซ้ำกับส่วนที่เหลือจนครบ
     * 
     * Time Complexity: O(n²)
     * Space Complexity: O(1)
     */
    public List<Booking> sortBookings(List<Booking> bookings, String sortBy, String order) {
        if (bookings == null || bookings.size() <= 1) {
            return bookings;
        }
        
        // สร้าง copy เพื่อไม่แก้ไข list ต้นฉบับ
        List<Booking> result = new ArrayList<>(bookings);
        Comparator<Booking> comparator = getComparator(sortBy);
        
        // กลับลำดับถ้าเป็น DESC
        if (ORDER_DESC.equalsIgnoreCase(order)) {
            comparator = comparator.reversed();
        }
        
        int n = result.size();
        
        // ========== Selection Sort Algorithm ==========
        for (int i = 0; i < n - 1; i++) {
            // หา index ของค่าที่น้อยที่สุดในส่วนที่ยังไม่ได้เรียง
            int minIndex = i;
            for (int j = i + 1; j < n; j++) {
                // เปรียบเทียบ: ถ้า result[j] < result[minIndex]
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
    
    /**
     * สร้าง Comparator ตามฟิลด์ที่เลือก
     */
    private Comparator<Booking> getComparator(String sortBy) {
        switch (sortBy != null ? sortBy.toLowerCase() : SORT_BY_DATE) {
            case SORT_BY_STATUS:
                return Comparator.comparing(Booking::getStatus);
            case SORT_BY_ROUTE:
                return Comparator.comparing(b -> b.getTrip().getRoute().getName());
            case SORT_BY_SEAT:
                return Comparator.comparing(Booking::getSeatNumber);
            case SORT_BY_DATE:
            default:
                return Comparator.comparing(Booking::getBookedAt,
                    Comparator.nullsLast(Comparator.naturalOrder()));
        }
    }
}
```

### แผนภาพ Selection Sort:

```
ขั้นตอน Selection Sort (เรียงน้อยไปมาก):

เริ่มต้น: [64, 25, 12, 22, 11]

รอบที่ 1: หาค่าน้อยสุด (11) สลับกับตำแหน่งแรก
         [11, 25, 12, 22, 64]
              ↑-------------↑ swap

รอบที่ 2: หาค่าน้อยสุดในส่วนที่เหลือ (12) สลับกับตำแหน่งที่ 2
         [11, 12, 25, 22, 64]
              ↑---↑ swap

รอบที่ 3: หาค่าน้อยสุดในส่วนที่เหลือ (22) สลับกับตำแหน่งที่ 3
         [11, 12, 22, 25, 64]
                  ↑---↑ swap

รอบที่ 4: 25 < 64 ไม่ต้องสลับ
         [11, 12, 22, 25, 64] ✓ เรียงเสร็จแล้ว!
```

---

## 6. Data Searching (การค้นหาข้อมูล)

### Algorithm: Sequential Search (Linear Search)

**Time Complexity:** O(n)  
**Space Complexity:** O(1)

### ไฟล์: `com/yeep/service/BusRouteService.java`

```java
@Service
public class BusRouteService {
    
    @Autowired
    private BusRouteRepository busRouteRepository;
    
    /**
     * Sequential Search Algorithm (Linear Search)
     * 
     * วิธีการ:
     * 1. วนลูปตรวจสอบทีละ element ตั้งแต่ต้นจนจบ
     * 2. เปรียบเทียบกับเงื่อนไขที่ต้องการ
     * 3. ถ้าตรง เพิ่มเข้าผลลัพธ์
     * 
     * Time Complexity: O(n)
     * Space Complexity: O(1) สำหรับการค้นหา
     */
    public List<BusRoute> searchRoutes(String origin, String destination) {
        // ดึงข้อมูลทั้งหมดมาก่อน
        List<BusRoute> allRoutes = busRouteRepository.findAll();
        List<BusRoute> result = new ArrayList<>();
        
        // ========== Sequential Search ==========
        // วนลูปตรวจสอบทีละ element
        for (int i = 0; i < allRoutes.size(); i++) {
            BusRoute route = allRoutes.get(i);
            boolean match = true;
            
            // ตรวจสอบเงื่อนไข origin (ถ้ามี)
            if (origin != null && !origin.isEmpty()) {
                // เปรียบเทียบแบบ case-insensitive และ partial match
                if (!route.getOrigin().toLowerCase().contains(origin.toLowerCase())) {
                    match = false;
                }
            }
            
            // ตรวจสอบเงื่อนไข destination (ถ้ามี)
            if (destination != null && !destination.isEmpty()) {
                // เปรียบเทียบแบบ case-insensitive และ partial match
                if (!route.getDestination().toLowerCase().contains(destination.toLowerCase())) {
                    match = false;
                }
            }
            
            // ถ้าตรงเงื่อนไขทั้งหมด เพิ่มเข้าผลลัพธ์
            if (match) {
                result.add(route);
            }
        }
        
        return result;
    }
}
```

### แผนภาพ Sequential Search:

```
ค้นหาเส้นทาง: origin = "หอพัก"

ข้อมูลทั้งหมด:
┌─────┬────────────────┬──────────────────┐
│ idx │     origin     │   destination    │
├─────┼────────────────┼──────────────────┤
│  0  │ หอพัก S16-S18  │ อาคารเรียนรวม 1  │  ← ตรง! เพิ่มเข้า result
│  1  │ หอพัก S4       │ อาคารเรียนรวม 1  │  ← ตรง! เพิ่มเข้า result
│  2  │ อาคารเรียนรวม 1 │ อาคารขนส่ง      │  ← ไม่ตรง
│  3  │ อาคารขนส่ง     │ หอพัก S16-S18    │  ← ไม่ตรง
│  4  │ หอพัก S13      │ ตลาดหน้า ม.      │  ← ตรง! เพิ่มเข้า result
│  5  │ อาคารขนส่ง     │ โรงพยาบาล มทส.   │  ← ไม่ตรง
└─────┴────────────────┴──────────────────┘

ผลลัพธ์: [หอพัก S16-S18, หอพัก S4, หอพัก S13] (3 เส้นทาง)
```

---

## 7. สรุปจำนวน Class และ Method

### จำนวน Class (≥10)

| ประเภท | Class | จำนวน |
|--------|-------|-------|
| Entity | BaseEntity, User, Booking, BusRoute, BusTrip | 5 |
| Service | BookingService, UserService, BusRouteService, BusTripService, FileService | 5 |
| Controller | BookingController, UserController, FileController | 3 |
| Repository | BookingRepository, UserRepository, BusRouteRepository, BusTripRepository | 4 |
| DTO/Util | ApiResponse, EntityMapper, RouteScheduleConfig | 3 |
| **รวม** | | **20 classes** |

### จำนวน Method (≥12)

| Class | จำนวน Method | Method ตัวอย่าง |
|-------|-------------|-----------------|
| **BookingService** | 21 | createBooking, cancelBooking, sortBookings, getComparator, getUserBookingsSorted |
| **UserService** | 18 | login, register, getUserByUsername, updatePassword, hashPassword |
| **BusRouteService** | 6 | getAllRoutes, getRouteById, searchRoutes, getAllLocations |
| **BusTripService** | 5 | getTripById, getTripsByRouteAndDate, getTripsWithAvailability |
| **FileService** | 15 | readTextFile, readCsvFile, uploadProfileImage, validateFileSize |
| **BookingController** | 16 | bookSeats, cancelBooking, getUserBookings, getTrips, searchRoutes |
| **UserController** | 8 | login, register, getUser, updatePassword, checkEmail |
| **FileController** | 4 | uploadProfileImage, getProfileImage, validateFile, getFileConfig |
| **รวม** | **93 methods** | |
