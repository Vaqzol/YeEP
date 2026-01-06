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
| Inner Classes | TripSchedule, TripTimeSlot, UserProfile, ContactInfo, Preferences, TripWithAvailability, TripTime | 7 |
| **รวม** | | **27 classes** |

### จำนวน Method (≥12)

| Class | จำนวน Method | Method ตัวอย่าง |
|-------|-------------|-----------------|
| **BookingService** | 21 | createBooking, cancelBooking, sortBookings, getComparator, getUserBookingsSorted |
| **UserService** | 21 | login, register, searchUsersByRole, searchUsersByName, updatePassword |
| **BusRouteService** | 6 | getAllRoutes, getRouteById, searchRoutes, getAllLocations |
| **BusTripService** | 7 | getTripById, getTripsWithAvailability, sortTripsByDepartureTime |
| **FileService** | 15 | readTextFile, readCsvFile, uploadProfileImage, validateFileSize |
| **BookingController** | 16 | bookSeats, cancelBooking, getUserBookings, getTrips, searchRoutes |
| **UserController** | 8 | login, register, getUser, updatePassword, checkEmail |
| **FileController** | 4 | uploadProfileImage, getProfileImage, validateFile, getFileConfig |
| **รวม** | **98 methods** | |

---

## 8. การประยุกต์ใช้แนวคิด Object-Oriented Programming

---

### 8.1 การประยุกต์ใช้แนวคิด Inheritance (การสืบทอด)

#### 8.1.1 หลักการ
Inheritance (การสืบทอด) คือกระบวนการที่ Class หนึ่งสามารถรับคุณสมบัติ (attributes) และพฤติกรรม (methods) จาก Class อื่นได้ โดย Class ที่สืบทอดเรียกว่า Subclass และ Class ที่ถูกสืบทอดเรียกว่า Superclass

#### 8.1.2 การนำไปใช้ในโปรเจค

ในระบบ YeEP ได้ใช้หลักการ Inheritance โดยสร้าง Abstract Class ชื่อ `BaseEntity` เป็น Superclass ที่เก็บ fields พื้นฐานที่ทุก Entity ต้องมี และให้ Entity อื่นๆ สืบทอด

**ตำแหน่งที่ใช้ Inheritance (4 แห่ง):**

| ลำดับ | Subclass | Superclass | ไฟล์ |
|-------|----------|------------|------|
| 1 | `User` | `BaseEntity` | `com/yeep/entity/User.java` |
| 2 | `BusRoute` | `BaseEntity` | `com/yeep/entity/BusRoute.java` |
| 3 | `BusTrip` | `BaseEntity` | `com/yeep/entity/BusTrip.java` |
| 4 | `Booking` | `BaseEntity` | `com/yeep/entity/Booking.java` |

**ตัวอย่างโค้ด:**

```java
// BaseEntity.java - Superclass (Abstract)
@MappedSuperclass
public abstract class BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Getters, Setters...
}

// User.java - Subclass ที่สืบทอดจาก BaseEntity
public class User extends BaseEntity {
    private String username;
    private String email;
    private String password;
    // สามารถใช้ id, createdAt, updatedAt ได้โดยไม่ต้องประกาศซ้ำ
}
```

#### 8.1.3 ประโยชน์ที่ได้รับ
1. **ลดการเขียนโค้ดซ้ำ** - ไม่ต้องประกาศ id, createdAt, updatedAt ในทุก Entity
2. **ง่ายต่อการบำรุงรักษา** - แก้ไขที่ BaseEntity จะมีผลกับทุก Entity
3. **สร้างโครงสร้างที่เป็นระบบ** - Entity ทั้งหมดมีรูปแบบเดียวกัน

---

### 8.2 การประยุกต์ใช้แนวคิด Polymorphism (ความหลากหลายของรูปแบบ)

#### 8.2.1 หลักการ
Polymorphism (ความหลากหลายของรูปแบบ) คือความสามารถที่ Object หลายชนิดสามารถตอบสนองต่อ method เดียวกันได้ในรูปแบบที่แตกต่างกัน ทำให้สามารถใช้ Interface หรือ Superclass เป็นชนิดข้อมูลได้

#### 8.2.2 การนำไปใช้ในโปรเจค

ในระบบ YeEP ได้ใช้หลักการ Polymorphism ผ่าน Spring Data JPA โดยใช้ `JpaRepository<T, ID>` เป็น Interface หลักที่ Repository ทั้งหมด implement

**ตำแหน่งที่ใช้ Polymorphism (4 แห่ง):**

| ลำดับ | Repository | Interface ที่ Extend | ไฟล์ |
|-------|------------|---------------------|------|
| 1 | `BookingRepository` | `JpaRepository<Booking, Long>` | `repository/BookingRepository.java` |
| 2 | `UserRepository` | `JpaRepository<User, Long>` | `repository/UserRepository.java` |
| 3 | `BusRouteRepository` | `JpaRepository<BusRoute, Long>` | `repository/BusRouteRepository.java` |
| 4 | `BusTripRepository` | `JpaRepository<BusTrip, Long>` | `repository/BusTripRepository.java` |

**ตัวอย่างโค้ด:**

```java
// JpaRepository - Interface หลัก (จาก Spring Data JPA)
public interface JpaRepository<T, ID> {
    List<T> findAll();
    Optional<T> findById(ID id);
    T save(T entity);
    void delete(T entity);
}

// BookingRepository - Implement JpaRepository สำหรับ Booking
public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByUserAndStatus(User user, String status);
}

// UserRepository - Implement JpaRepository สำหรับ User
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
}
```

#### 8.2.3 ประโยชน์ที่ได้รับ
1. **ใช้ method เดียวกันกับ Entity ต่างๆ** - `save()`, `findAll()`, `delete()` ใช้ได้กับทุก Repository
2. **ลดการเขียนโค้ดซ้ำ** - Spring Data JPA สร้าง implementation ให้อัตโนมัติ
3. **ยืดหยุ่นในการใช้งาน** - สามารถเพิ่ม custom method ได้ตามต้องการ

---

### 8.3 การประยุกต์ใช้แนวคิด Aggregation (ความสัมพันธ์แบบหลวม)

#### 8.3.1 หลักการ
Aggregation คือความสัมพันธ์แบบ "has-a" ที่ Whole และ Part สามารถอยู่แยกกันได้ กล่าวคือ เมื่อลบ Whole ไม่จำเป็นต้องลบ Part ตามไปด้วย

#### 8.3.2 การนำไปใช้ในโปรเจค

ในระบบ YeEP ได้ใช้หลักการ Aggregation ผ่าน annotation `@ManyToOne` เพื่อแสดงความสัมพันธ์ระหว่าง Entity

**ตำแหน่งที่ใช้ Aggregation (3 แห่ง):**

| ลำดับ | Class | อ้างอิงถึง | Annotation | ไฟล์ | บรรทัด |
|-------|-------|-----------|------------|------|--------|
| 1 | `BusTrip` | `BusRoute` | `@ManyToOne` | `entity/BusTrip.java` | 20 |
| 2 | `Booking` | `BusTrip` | `@ManyToOne` | `entity/Booking.java` | 22 |
| 3 | `Booking` | `User` | `@ManyToOne` | `entity/Booking.java` | 26 |

**ตัวอย่างโค้ด:**

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

#### 8.3.3 ประโยชน์ที่ได้รับ
1. **ความยืดหยุ่น** - สามารถอ้างอิงข้อมูลได้โดยไม่ผูกมัด lifecycle
2. **ลดการซ้ำซ้อนของข้อมูล** - ใช้ foreign key อ้างอิงแทนการ copy ข้อมูล
3. **รองรับความสัมพันธ์แบบ Many-to-One** - หลาย Booking อ้างอิง User คนเดียวกันได้

---

### 8.4 การประยุกต์ใช้แนวคิด Composition (ความสัมพันธ์แบบแน่น)

#### 8.4.1 หลักการ
Composition คือความสัมพันธ์แบบ "has-a" ที่แข็งแกร่งกว่า Aggregation โดย Part ไม่สามารถอยู่ได้โดยไม่มี Whole เมื่อลบ Whole ต้องลบ Part ทั้งหมดด้วย

#### 8.4.2 การนำไปใช้ในโปรเจค

ในระบบ YeEP ได้ใช้หลักการ Composition ผ่าน Inner Class ที่ถูกสร้างและทำลายพร้อมกับ Outer Class

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
    
    // เพิ่ม time slot (สร้าง Part ภายใน Whole)
    public void addTimeSlot(LocalTime departure, LocalTime arrival, int capacity) {
        timeSlots.add(new TripTimeSlot(departure, arrival, capacity));
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
        
        // Package-private: สร้างได้เฉพาะจาก TripSchedule
        TripTimeSlot(LocalTime departure, LocalTime arrival, int capacity) {
            this.departure = departure;
            this.arrival = arrival;
            this.capacity = capacity;
        }
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
    
    // Inner Classes: Parts ที่ขึ้นอยู่กับ UserProfile
    public static class ContactInfo { ... }
    public static class Preferences { ... }
}
```

#### 8.4.3 ประโยชน์ที่ได้รับ
1. **ควบคุม lifecycle ได้** - Part ถูกสร้างและทำลายพร้อมกับ Whole
2. **ความเป็นเจ้าของชัดเจน** - Part ไม่สามารถอยู่แยกจาก Whole ได้
3. **จัดการหน่วยความจำได้ดี** - ลบ Whole = ลบ Part ทั้งหมด

---

### 8.5 การใช้เทคนิคในการเรียงลำดับข้อมูล (Data Sorting)

#### 8.5.1 หลักการ
Data Sorting คือกระบวนการจัดเรียงข้อมูลในลำดับที่ต้องการ ในโปรเจคนี้ใช้ **Selection Sort Algorithm** ซึ่งเป็นอัลกอริทึมที่เข้าใจง่ายและเหมาะสำหรับการเรียนรู้

**Selection Sort Algorithm:**
1. หาค่าที่น้อยที่สุดในส่วนที่ยังไม่ได้เรียง
2. สลับค่านั้นกับตำแหน่งแรกของส่วนที่ยังไม่ได้เรียง
3. ทำซ้ำจนครบทุกตำแหน่ง

**Time Complexity:** O(n²) | **Space Complexity:** O(1)

#### 8.5.2 การนำไปใช้ในโปรเจค

**ตำแหน่งที่ใช้ Data Sorting (2 แห่ง):**

| ลำดับ | Method | Class | ไฟล์ | บรรทัด | จุดประสงค์ |
|-------|--------|-------|------|--------|-----------|
| 1 | `sortBookings()` | `BookingService` | `BookingService.java` | 150-189 | เรียงลำดับการจองตามวันที่/สถานะ/สาย/ที่นั่ง |
| 2 | `sortTripsByDepartureTime()` | `BusTripService` | `BusTripService.java` | 118-154 | เรียงลำดับเที่ยวรถตามเวลาออกเดินทาง |

**ตัวอย่างโค้ด Sorting #1:**

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

**ตัวอย่างโค้ด Sorting #2:**

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

#### 8.5.3 ประโยชน์ที่ได้รับ
1. **แสดงผลข้อมูลอย่างเป็นระบบ** - ผู้ใช้สามารถดูข้อมูลที่เรียงลำดับแล้ว
2. **รองรับหลายเกณฑ์** - เลือกเรียงตามวันที่ สถานะ หรือเวลาได้
3. **ปรับทิศทางได้** - เรียงจากน้อยไปมาก หรือมากไปน้อย

---

### 8.6 การใช้เทคนิคในการค้นหาข้อมูล (Data Searching)

#### 8.6.1 หลักการ
Data Searching คือกระบวนการค้นหาข้อมูลที่ตรงกับเงื่อนไขที่กำหนด ในโปรเจคนี้ใช้ **Sequential Search Algorithm** (Linear Search) ซึ่งเป็นอัลกอริทึมพื้นฐานที่ตรวจสอบทีละรายการ

**Sequential Search Algorithm:**
1. วนลูปตรวจสอบทีละ element ตั้งแต่ต้นจนจบ
2. เปรียบเทียบกับเงื่อนไขที่ต้องการ
3. ถ้าตรง เพิ่มเข้าผลลัพธ์
4. คืนค่าผลลัพธ์ทั้งหมด

**Time Complexity:** O(n) | **Space Complexity:** O(1)

#### 8.6.2 การนำไปใช้ในโปรเจค

**ตำแหน่งที่ใช้ Data Searching (3 แห่ง):**

| ลำดับ | Method | Class | ไฟล์ | บรรทัด | จุดประสงค์ |
|-------|--------|-------|------|--------|-----------|
| 1 | `searchRoutes()` | `BusRouteService` | `BusRouteService.java` | 43-71 | ค้นหาเส้นทางตามต้นทาง-ปลายทาง |
| 2 | `searchUsersByRole()` | `UserService` | `UserService.java` | 220-240 | ค้นหาผู้ใช้ตาม Role |
| 3 | `searchUsersByName()` | `UserService` | `UserService.java` | 248-267 | ค้นหาผู้ใช้ตามชื่อ (partial match) |

**ตัวอย่างโค้ด Searching #1:**

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

**ตัวอย่างโค้ด Searching #2:**

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

**ตัวอย่างโค้ด Searching #3:**

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

#### 8.6.3 ประโยชน์ที่ได้รับ
1. **ค้นหาได้ยืดหยุ่น** - รองรับ partial match และ case-insensitive
2. **ค้นหาได้หลายเงื่อนไข** - ค้นหาตาม origin, destination, role, หรือชื่อ
3. **เข้าใจง่าย** - โค้ดอ่านง่ายและบำรุงรักษาได้ง่าย

---

### 8.7 การนำเข้าข้อมูลจากไฟล์ (File Input/Output)

#### 8.7.1 หลักการ
File I/O คือการอ่านและเขียนข้อมูลจากไฟล์ ซึ่งเป็นวิธีการจัดเก็บข้อมูลแบบถาวร (Persistent Storage) ในโปรเจคนี้ใช้ `FileService` สำหรับจัดการไฟล์ทุกประเภท

#### 8.7.2 การนำไปใช้ในโปรเจค

**ตำแหน่งที่ใช้ File I/O (FileService.java):**

| ลำดับ | Method | จุดประสงค์ | ประเภทไฟล์ |
|-------|--------|-----------|-----------|
| 1 | `readTextFile()` | อ่านไฟล์ Text | Text File |
| 2 | `readCsvFile()` | อ่านไฟล์ CSV | CSV File |
| 3 | `writeTextFile()` | เขียนไฟล์ Text | Text File |
| 4 | `uploadProfileImage()` | อัพโหลดรูปโปรไฟล์ | Binary File (Image) |
| 5 | `getProfileImage()` | ดึงรูปโปรไฟล์ | Binary File (Image) |

**ตัวอย่างโค้ด:**

```java
// FileService.java - อ่านไฟล์ Text
public List<String> readTextFile(String filePath) throws IOException {
    Path path = Paths.get(filePath);
    return Files.readAllLines(path, StandardCharsets.UTF_8);
}

// FileService.java - อ่านไฟล์ CSV
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

// FileService.java - เขียนไฟล์ Text
public void writeTextFile(String filePath, List<String> lines) throws IOException {
    Path path = Paths.get(filePath);
    Files.write(path, lines, StandardCharsets.UTF_8);
}
```

#### 8.7.3 ประโยชน์ที่ได้รับ
1. **รองรับหลายประเภทไฟล์** - Text, CSV, และ Binary (รูปภาพ)
2. **จัดการข้อมูลได้ยืดหยุ่น** - อ่าน เขียน และอัพโหลดไฟล์
3. **รักษาความปลอดภัย** - มีการ validate ขนาดและประเภทไฟล์

---

## 9. สรุปรวม OOP Concepts

| Concept | ต้องการ | มี | สถานะ | ที่ตั้ง |
|---------|--------|-----|-------|--------|
| **Inheritance** | ≥2 | 4 | ✅ ผ่าน | User, BusRoute, BusTrip, Booking |
| **Polymorphism** | ≥2 | 4 | ✅ ผ่าน | BookingRepo, UserRepo, BusRouteRepo, BusTripRepo |
| **Aggregation** | ≥2 | 3 | ✅ ผ่าน | BusTrip→Route, Booking→Trip, Booking→User |
| **Composition** | ≥2 | 2 | ✅ ผ่าน | TripSchedule, UserProfile |
| **Data Sorting** | ≥2 | 2 | ✅ ผ่าน | BookingService, BusTripService |
| **Data Searching** | ≥2 | 3 | ✅ ผ่าน | BusRouteService, UserService (x2) |
| **File I/O** | ≥1 | 1 | ✅ ผ่าน | FileService |

**สรุป: โปรเจค YeEP มีการใช้หลักการ OOP ครบทุกข้อตามที่กำหนด**

