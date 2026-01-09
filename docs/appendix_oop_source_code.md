# ภาคผนวก - ซอร์สโค้ดที่ใช้หลักการ OOP

## สารบัญ
1. [Inheritance - การสืบทอด](#1-inheritance---การสืบทอด)
2. [Polymorphism - ความหลากหลาย](#2-polymorphism---ความหลากหลาย)
3. [Aggregation - ความสัมพันธ์แบบหลวม](#3-aggregation---ความสัมพันธ์แบบหลวม)
4. [Composition - ความสัมพันธ์แบบแน่น](#4-composition---ความสัมพันธ์แบบแน่น)
5. [Data Sorting - การเรียงลำดับข้อมูล](#5-data-sorting---การเรียงลำดับข้อมูล)
6. [Data Searching - การค้นหาข้อมูล](#6-data-searching---การค้นหาข้อมูล)
7. [File Input/Output - การอ่าน/เขียนไฟล์](#7-file-inputoutput---การอ่านเขียนไฟล์)

---

## 1. Inheritance - การสืบทอด

### 1.1 BaseEntity.java (Superclass - Abstract)

**ไฟล์:** `com/yeep/entity/BaseEntity.java`

```java
package com.yeep.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Abstract Base Entity สำหรับ Entity ทั้งหมดในระบบ
 * ใช้หลักการ Inheritance เพื่อลดการซ้ำซ้อนของ code
 * 
 * ทุก Entity ที่สืบทอดจะมี:
 * - id: Primary Key
 * - createdAt: วันที่สร้าง
 * - updatedAt: วันที่อัพเดทล่าสุด
 */
@MappedSuperclass
public abstract class BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    protected Long id;

    @Column(name = "created_at", updatable = false)
    protected LocalDateTime createdAt;

    @Column(name = "updated_at")
    protected LocalDateTime updatedAt;

    // ==================== LIFECYCLE CALLBACKS ====================

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // ==================== GETTERS AND SETTERS ====================

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    // ==================== COMMON METHODS ====================

    /**
     * ตรวจสอบว่า Entity นี้เป็น Entity ใหม่หรือไม่
     */
    public boolean isNew() {
        return id == null;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        BaseEntity that = (BaseEntity) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
```

---

### 1.2 User.java (Subclass #1)

**ไฟล์:** `com/yeep/entity/User.java`

```java
package com.yeep.entity;

import jakarta.persistence.*;

/**
 * User Entity - สืบทอดจาก BaseEntity
 * ใช้หลักการ Inheritance เพื่อ reuse fields และ methods จาก parent class
 */
@Entity
@Table(name = "users")
public class User extends BaseEntity {

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true)
    private String email;

    private String phone;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role = "user"; // "user" or "driver"

    // Profile picture path (สำหรับ File Input feature)
    @Column(name = "profile_picture")
    private String profilePicture;

    // Constructors
    public User() {
        super();
    }

    public User(String username, String email, String phone, String password, String role) {
        super();
        this.username = username;
        this.email = email;
        this.phone = phone;
        this.password = password;
        this.role = role;
    }

    // Getters and Setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getProfilePicture() {
        return profilePicture;
    }

    public void setProfilePicture(String profilePicture) {
        this.profilePicture = profilePicture;
    }
}
```

---

### 1.3 Booking.java (Subclass #2)

**ไฟล์:** `com/yeep/entity/Booking.java`

```java
package com.yeep.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * Booking Entity - สืบทอดจาก BaseEntity
 * ใช้หลักการ Inheritance เพื่อ reuse fields และ methods จาก parent class
 */
@Entity
@Table(name = "bookings")
public class Booking extends BaseEntity {

    @Column(name = "booking_code", unique = true, nullable = false)
    private String bookingCode; // P0001, P0002...

    @ManyToOne
    @JoinColumn(name = "trip_id", nullable = false)
    private BusTrip trip;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "seat_number", nullable = false)
    private String seatNumber; // 1A, 2B, etc.

    @Column(nullable = false)
    private String status = "confirmed"; // confirmed, cancelled

    @Column(name = "booked_at")
    private LocalDateTime bookedAt;

    @Column(name = "cancelled_at")
    private LocalDateTime cancelledAt;

    // Constructors
    public Booking() {
        super();
        this.bookedAt = LocalDateTime.now();
        this.status = "confirmed";
    }

    public Booking(String bookingCode, BusTrip trip, User user, String seatNumber) {
        super();
        this.bookingCode = bookingCode;
        this.trip = trip;
        this.user = user;
        this.seatNumber = seatNumber;
        this.status = "confirmed";
        this.bookedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public String getBookingCode() {
        return bookingCode;
    }

    public void setBookingCode(String bookingCode) {
        this.bookingCode = bookingCode;
    }

    public BusTrip getTrip() {
        return trip;
    }

    public void setTrip(BusTrip trip) {
        this.trip = trip;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getBookedAt() {
        return bookedAt;
    }

    public void setBookedAt(LocalDateTime bookedAt) {
        this.bookedAt = bookedAt;
    }

    public LocalDateTime getCancelledAt() {
        return cancelledAt;
    }

    public void setCancelledAt(LocalDateTime cancelledAt) {
        this.cancelledAt = cancelledAt;
    }
}
```

---

### 1.4 BusTrip.java (Subclass #3)

**ไฟล์:** `com/yeep/entity/BusTrip.java`

```java
package com.yeep.entity;

import java.time.LocalDate;
import java.time.LocalTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * BusTrip Entity - สืบทอดจาก BaseEntity
 * ใช้หลักการ Inheritance เพื่อ reuse fields และ methods จาก parent class
 */
@Entity
@Table(name = "bus_trips")
public class BusTrip extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "route_id", nullable = false)
    private BusRoute route;

    @Column(name = "trip_number")
    private Integer tripNumber; // เที่ยวที่ 1, 2, 3...

    @Column(name = "departure_time", nullable = false)
    private LocalTime departureTime; // เวลาออก

    @Column(name = "arrival_time")
    private LocalTime arrivalTime; // เวลาถึง

    @Column(name = "trip_date", nullable = false)
    private LocalDate tripDate; // วันที่

    @Column(name = "total_seats")
    private Integer totalSeats = 20; // จำนวนที่นั่งทั้งหมด

    // Constructors
    public BusTrip() {
        super();
    }

    public BusTrip(BusRoute route, Integer tripNumber, LocalTime departureTime, 
                   LocalTime arrivalTime, LocalDate tripDate) {
        super();
        this.route = route;
        this.tripNumber = tripNumber;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.tripDate = tripDate;
        this.totalSeats = 20;
    }

    // Getters and Setters
    public BusRoute getRoute() {
        return route;
    }

    public void setRoute(BusRoute route) {
        this.route = route;
    }

    public Integer getTripNumber() {
        return tripNumber;
    }

    public void setTripNumber(Integer tripNumber) {
        this.tripNumber = tripNumber;
    }

    public LocalTime getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(LocalTime departureTime) {
        this.departureTime = departureTime;
    }

    public LocalTime getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(LocalTime arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public LocalDate getTripDate() {
        return tripDate;
    }

    public void setTripDate(LocalDate tripDate) {
        this.tripDate = tripDate;
    }

    public Integer getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(Integer totalSeats) {
        this.totalSeats = totalSeats;
    }
}
```

---

## 2. Polymorphism - ความหลากหลาย

### 2.1 BookingRepository.java (Repository #1)

**ไฟล์:** `com/yeep/repository/BookingRepository.java`

```java
package com.yeep.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.yeep.entity.Booking;
import com.yeep.entity.BusTrip;
import com.yeep.entity.User;

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
    
    // นับจำนวนที่นั่งที่จองแล้ว
    @Query("SELECT COUNT(b) FROM Booking b WHERE b.trip.id = :tripId AND b.status = 'confirmed'")
    int countBookedSeatsByTripId(@Param("tripId") Long tripId);
    
    // ตรวจสอบว่าที่นั่งถูกจองแล้วหรือยัง
    boolean existsByTripAndSeatNumberAndStatus(BusTrip trip, String seatNumber, String status);
    
    // หาจาก booking code
    Optional<Booking> findByBookingCode(String bookingCode);
    
    // หา booking code ล่าสุด
    @Query("SELECT b.bookingCode FROM Booking b ORDER BY b.id DESC LIMIT 1")
    Optional<String> findLastBookingCode();
    
    // หาการจองตามสายรถและวันที่
    @Query("SELECT b FROM Booking b WHERE b.trip.route.id = :routeId AND b.trip.tripDate = :date AND b.status = 'confirmed' ORDER BY b.trip.departureTime, b.seatNumber")
    List<Booking> findByRouteIdAndDate(@Param("routeId") Long routeId, @Param("date") java.time.LocalDate date);
}
```

---

### 2.2 UserRepository.java (Repository #2)

**ไฟล์:** `com/yeep/repository/UserRepository.java`

```java
package com.yeep.repository;

import com.yeep.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByUsername(String username);
    
    Optional<User> findByEmail(String email);
    
    boolean existsByUsername(String username);
    
    boolean existsByEmail(String email);
}
```

---

## 3. Aggregation - ความสัมพันธ์แบบหลวม

### 3.1 ตัวอย่าง @ManyToOne ใน BusTrip.java

```java
// BusTrip.java - Aggregation: BusTrip อ้างอิงถึง BusRoute
@ManyToOne
@JoinColumn(name = "route_id", nullable = false)
private BusRoute route;
```

### 3.2 ตัวอย่าง @ManyToOne ใน Booking.java

```java
// Booking.java - Aggregation: Booking อ้างอิงถึง BusTrip
@ManyToOne
@JoinColumn(name = "trip_id", nullable = false)
private BusTrip trip;

// Booking.java - Aggregation: Booking อ้างอิงถึง User
@ManyToOne
@JoinColumn(name = "user_id", nullable = false)
private User user;
```

---

## 4. Composition - ความสัมพันธ์แบบแน่น

### 4.1 TripSchedule Composition (BusTripService.java)

**ไฟล์:** `com/yeep/service/BusTripService.java` บรรทัด 167-239

```java
// ==================== COMPOSITION EXAMPLE #1 ====================
/**
 * TripSchedule - ตัวอย่าง Composition
 * 
 * Composition: TripSchedule "owns" TripTimeSlot objects
 * ถ้า TripSchedule ถูกลบ, TripTimeSlot ทั้งหมดจะถูกลบด้วย
 * 
 * ความแตกต่างจาก Aggregation:
 * - Composition: Part ไม่สามารถอยู่ได้โดยไม่มี Whole (TripTimeSlot ต้องมี TripSchedule)
 * - Aggregation: Part สามารถอยู่ได้โดยไม่มี Whole (Booking อาจอยู่ได้โดยไม่มี User)
 */
public static class TripSchedule {
    private String scheduleName;
    private LocalDate date;
    // Composition: TripSchedule owns these TripTimeSlots
    private List<TripTimeSlot> timeSlots;

    public TripSchedule(String scheduleName, LocalDate date) {
        this.scheduleName = scheduleName;
        this.date = date;
        this.timeSlots = new ArrayList<>(); // Composition: สร้างพร้อมกับ parent
    }

    // เพิ่ม time slot ใหม่ (สร้างภายใน parent)
    public void addTimeSlot(LocalTime departure, LocalTime arrival, int capacity) {
        // Composition: TripTimeSlot ถูกสร้างและ owned โดย TripSchedule
        timeSlots.add(new TripTimeSlot(departure, arrival, capacity));
    }

    // ลบ time slot
    public void removeTimeSlot(int index) {
        if (index >= 0 && index < timeSlots.size()) {
            timeSlots.remove(index); // ลบ TripTimeSlot ออกจาก parent
        }
    }

    // ล้าง time slots ทั้งหมด (Composition: ลบ part ทั้งหมดเมื่อ whole ถูกทำลาย)
    public void clearAllTimeSlots() {
        timeSlots.clear();
    }

    public String getScheduleName() {
        return scheduleName;
    }

    public LocalDate getDate() {
        return date;
    }

    public List<TripTimeSlot> getTimeSlots() {
        return new ArrayList<>(timeSlots);
    }

    public int getTimeSlotsCount() {
        return timeSlots.size();
    }

    // Composition: Part class ที่ขึ้นอยู่กับ Whole
    public static class TripTimeSlot {
        private LocalTime departure;
        private LocalTime arrival;
        private int capacity;

        // Package-private constructor: สร้างได้เฉพาะจาก TripSchedule
        TripTimeSlot(LocalTime departure, LocalTime arrival, int capacity) {
            this.departure = departure;
            this.arrival = arrival;
            this.capacity = capacity;
        }

        public LocalTime getDeparture() {
            return departure;
        }

        public LocalTime getArrival() {
            return arrival;
        }

        public int getCapacity() {
            return capacity;
        }
    }
}
```

---

### 4.2 UserProfile Composition (UserService.java)

**ไฟล์:** `com/yeep/service/UserService.java` บรรทัด 279-374

```java
// ==================== COMPOSITION EXAMPLE #2 ====================
/**
 * UserProfile - ตัวอย่าง Composition
 * 
 * Composition: UserProfile "owns" ContactInfo และ Preferences objects
 * ถ้า UserProfile ถูกลบ, ContactInfo และ Preferences จะถูกลบด้วย
 * 
 * นี่แสดงความสัมพันธ์แบบ "has-a" ที่แข็งแกร่ง:
 * - ContactInfo ไม่สามารถอยู่ได้โดยไม่มี UserProfile
 * - Preferences ไม่สามารถอยู่ได้โดยไม่มี UserProfile
 */
public static class UserProfile {
    private String username;
    // Composition: UserProfile owns ContactInfo
    private ContactInfo contactInfo;
    // Composition: UserProfile owns Preferences
    private Preferences preferences;

    public UserProfile(String username) {
        this.username = username;
        // Composition: สร้าง part objects พร้อมกับ whole
        this.contactInfo = new ContactInfo();
        this.preferences = new Preferences();
    }

    public String getUsername() {
        return username;
    }

    public ContactInfo getContactInfo() {
        return contactInfo;
    }

    public Preferences getPreferences() {
        return preferences;
    }

    // เมื่อ UserProfile ถูกทำลาย, parts ทั้งหมดจะถูกทำลายด้วย
    public void destroy() {
        this.contactInfo = null;
        this.preferences = null;
    }

    // Composition Part #1: ContactInfo
    public static class ContactInfo {
        private String email;
        private String phone;
        private String address;

        public void setEmail(String email) {
            this.email = email;
        }

        public void setPhone(String phone) {
            this.phone = phone;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public String getEmail() {
            return email;
        }

        public String getPhone() {
            return phone;
        }

        public String getAddress() {
            return address;
        }
    }

    // Composition Part #2: Preferences
    public static class Preferences {
        private boolean emailNotifications = true;
        private boolean smsNotifications = false;
        private String language = "th";

        public void setEmailNotifications(boolean enabled) {
            this.emailNotifications = enabled;
        }

        public void setSmsNotifications(boolean enabled) {
            this.smsNotifications = enabled;
        }

        public void setLanguage(String language) {
            this.language = language;
        }

        public boolean isEmailNotifications() {
            return emailNotifications;
        }

        public boolean isSmsNotifications() {
            return smsNotifications;
        }

        public String getLanguage() {
            return language;
        }
    }
}
```

---

## 5. Data Sorting - การเรียงลำดับข้อมูล

### 5.1 sortBookings() - Selection Sort #1 (BookingService.java)

**ไฟล์:** `com/yeep/service/BookingService.java` บรรทัด 140-204

```java
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

    // Selection Sort Algorithm
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
 * สร้าง Comparator ตามฟิลด์ที่ระบุ
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
```

---

### 5.2 sortTripsByDepartureTime() - Selection Sort #2 (BusTripService.java)

**ไฟล์:** `com/yeep/service/BusTripService.java` บรรทัด 101-152

```java
// ==================== DATA SORTING (Selection Sort #2) ====================
/**
 * เรียงลำดับเที่ยวรถตามเวลาออก ด้วย Selection Sort Algorithm
 * 
 * Selection Sort Algorithm:
 * 1. หาค่าที่น้อยที่สุดในส่วนที่ยังไม่ได้เรียง
 * 2. สลับกับตำแหน่งแรกของส่วนที่ยังไม่ได้เรียง
 * 3. ทำซ้ำจนครบ
 * 
 * Time Complexity: O(n²)
 * Space Complexity: O(1)
 * 
 * @param trips     รายการเที่ยวรถ
 * @param ascending true = เรียงจากเช้าไปเย็น, false = เรียงจากเย็นไปเช้า
 * @return รายการเที่ยวรถที่เรียงลำดับแล้ว
 */
public List<BusTrip> sortTripsByDepartureTime(List<BusTrip> trips, boolean ascending) {
    if (trips == null || trips.size() <= 1) {
        return trips;
    }

    // สร้าง copy เพื่อไม่แก้ไข list ต้นฉบับ
    List<BusTrip> result = new ArrayList<>(trips);
    int n = result.size();

    // Selection Sort Algorithm
    for (int i = 0; i < n - 1; i++) {
        int selectedIndex = i;

        for (int j = i + 1; j < n; j++) {
            LocalTime timeJ = result.get(j).getDepartureTime();
            LocalTime timeSelected = result.get(selectedIndex).getDepartureTime();

            boolean shouldSwap = ascending
                    ? timeJ.isBefore(timeSelected) // เรียงน้อยไปมาก
                    : timeJ.isAfter(timeSelected); // เรียงมากไปน้อย

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

---

## 6. Data Searching - การค้นหาข้อมูล

### 6.1 searchRoutes() - Sequential Search #1 (BusRouteService.java)

**ไฟล์:** `com/yeep/service/BusRouteService.java` บรรทัด 31-76

```java
// ค้นหาสายรถตามต้นทาง-ปลายทาง ด้วย Sequential Search Algorithm
/**
 * Sequential Search Algorithm (Linear Search)
 * 
 * วิธีการ:
 * 1. วนลูปตรวจสอบทีละ element ตั้งแต่ต้นจนจบ
 * 2. เปรียบเทียบกับเงื่อนไขที่ต้องการ
 * 3. ถ้าตรง เพิ่มเข้าผลลัพธ์
 * 
 * Time Complexity: O(n)
 * Space Complexity: O(1) สำหรับการค้นหา, O(k) สำหรับผลลัพธ์ (k = จำนวนที่เจอ)
 */
public List<BusRoute> searchRoutes(String origin, String destination) {
    // ดึงข้อมูลทั้งหมดมาก่อน
    List<BusRoute> allRoutes = busRouteRepository.findAll();
    List<BusRoute> result = new ArrayList<>();

    // Sequential Search - วนลูปตรวจสอบทีละ element
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
```

---

### 6.2 searchUsersByRole() - Sequential Search #2 (UserService.java)

**ไฟล์:** `com/yeep/service/UserService.java` บรรทัด 204-240

```java
// ==================== DATA SEARCHING (Sequential Search #2) ====================
/**
 * ค้นหาผู้ใช้ตาม Role ด้วย Sequential Search Algorithm
 * 
 * Sequential Search Algorithm (Linear Search):
 * 1. วนลูปตรวจสอบทีละ element ตั้งแต่ต้นจนจบ
 * 2. เปรียบเทียบกับเงื่อนไขที่ต้องการ
 * 3. ถ้าตรง เพิ่มเข้าผลลัพธ์
 * 
 * Time Complexity: O(n)
 * Space Complexity: O(1) สำหรับการค้นหา
 * 
 * @param role role ที่ต้องการค้นหา (user, driver)
 * @return รายการผู้ใช้ที่มี role ตรงกัน
 */
public java.util.List<User> searchUsersByRole(String role) {
    // ดึงข้อมูลทั้งหมด
    java.util.List<User> allUsers = userRepository.findAll();
    java.util.List<User> result = new java.util.ArrayList<>();

    // Sequential Search - วนลูปตรวจสอบทีละ element
    for (int i = 0; i < allUsers.size(); i++) {
        User user = allUsers.get(i);

        // ตรวจสอบเงื่อนไข role
        if (role != null && !role.isEmpty()) {
            // เปรียบเทียบแบบ case-insensitive
            if (user.getRole() != null &&
                    user.getRole().toLowerCase().equals(role.toLowerCase())) {
                result.add(user);
            }
        }
    }

    return result;
}
```

---

### 6.3 searchUsersByName() - Sequential Search #3 (UserService.java)

**ไฟล์:** `com/yeep/service/UserService.java` บรรทัด 242-266

```java
/**
 * ค้นหาผู้ใช้ตามชื่อ (partial match) ด้วย Sequential Search
 * 
 * @param namePattern รูปแบบชื่อที่ต้องการค้นหา
 * @return รายการผู้ใช้ที่ชื่อตรงกับรูปแบบ
 */
public java.util.List<User> searchUsersByName(String namePattern) {
    java.util.List<User> allUsers = userRepository.findAll();
    java.util.List<User> result = new java.util.ArrayList<>();

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

---

## 7. File Input/Output - การอ่าน/เขียนไฟล์

### 7.1 FileService.java (ฉบับเต็ม)

**ไฟล์:** `com/yeep/service/FileService.java`

```java
package com.yeep.service;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * FileService - บริการจัดการไฟล์
 * 
 * สาธิตการใช้งาน File Input/Output ในหลักการ OOP
 * - อ่านไฟล์ (File Input)
 * - เขียนไฟล์ (File Output)
 * - ตรวจสอบขนาดไฟล์
 * - จัดการไฟล์รูปภาพ
 */
@Service
public class FileService {

    // ==================== CONSTANTS ====================

    /** ขนาดไฟล์สูงสุดที่อนุญาต (5MB) */
    public static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB in bytes

    /** นามสกุลไฟล์รูปภาพที่อนุญาต */
    public static final List<String> ALLOWED_IMAGE_EXTENSIONS = 
            Arrays.asList("jpg", "jpeg", "png", "gif", "webp");

    /** โฟลเดอร์เก็บไฟล์อัพโหลด */
    private static final String UPLOAD_DIR = "uploads";

    /** โฟลเดอร์เก็บรูปโปรไฟล์ */
    private static final String PROFILE_DIR = "profiles";

    // ==================== FILE INPUT METHODS ====================

    /**
     * อ่านไฟล์ข้อความ (File Input)
     * 
     * @param filePath พาธของไฟล์
     * @return เนื้อหาไฟล์เป็น List ของบรรทัด
     * @throws IOException หากไม่สามารถอ่านไฟล์ได้
     */
    public List<String> readTextFile(String filePath) throws IOException {
        List<String> lines = new ArrayList<>();

        // ใช้ BufferedReader สำหรับอ่านไฟล์ทีละบรรทัด
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                lines.add(line);
            }
        }

        return lines;
    }

    /**
     * อ่านไฟล์ CSV และแปลงเป็น List ของ Map
     * 
     * @param filePath พาธของไฟล์ CSV
     * @return ข้อมูลในรูปแบบ List ของ Map
     * @throws IOException หากไม่สามารถอ่านไฟล์ได้
     */
    public List<Map<String, String>> readCsvFile(String filePath) throws IOException {
        List<Map<String, String>> data = new ArrayList<>();
        List<String> lines = readTextFile(filePath);

        if (lines.isEmpty()) {
            return data;
        }

        // บรรทัดแรกเป็น header
        String[] headers = lines.get(0).split(",");

        // อ่านข้อมูลจากบรรทัดที่ 2 เป็นต้นไป
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
     * อ่านไฟล์ไบนารี (เช่น รูปภาพ)
     * 
     * @param filePath พาธของไฟล์
     * @return ข้อมูลไฟล์เป็น byte array
     * @throws IOException หากไม่สามารถอ่านไฟล์ได้
     */
    public byte[] readBinaryFile(String filePath) throws IOException {
        Path path = Paths.get(filePath);
        return Files.readAllBytes(path);
    }

    // ==================== FILE OUTPUT METHODS ====================

    /**
     * เขียนไฟล์ข้อความ
     * 
     * @param filePath พาธของไฟล์
     * @param content  เนื้อหาที่ต้องการเขียน
     * @throws IOException หากไม่สามารถเขียนไฟล์ได้
     */
    public void writeTextFile(String filePath, String content) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            writer.write(content);
        }
    }

    /**
     * เขียนไฟล์ข้อความหลายบรรทัด
     * 
     * @param filePath พาธของไฟล์
     * @param lines    รายการบรรทัดที่ต้องการเขียน
     * @throws IOException หากไม่สามารถเขียนไฟล์ได้
     */
    public void writeTextFile(String filePath, List<String> lines) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String line : lines) {
                writer.write(line);
                writer.newLine();
            }
        }
    }

    /**
     * บันทึกไฟล์ไบนารี
     * 
     * @param filePath พาธของไฟล์
     * @param data     ข้อมูลที่ต้องการบันทึก
     * @throws IOException หากไม่สามารถบันทึกไฟล์ได้
     */
    public void writeBinaryFile(String filePath, byte[] data) throws IOException {
        Path path = Paths.get(filePath);
        Files.write(path, data);
    }

    // ==================== FILE VALIDATION METHODS ====================

    /**
     * ตรวจสอบขนาดไฟล์
     * 
     * @param fileSize ขนาดไฟล์ (bytes)
     * @return true หากขนาดไม่เกิน MAX_FILE_SIZE
     */
    public boolean validateFileSize(long fileSize) {
        return fileSize <= MAX_FILE_SIZE;
    }

    /**
     * ตรวจสอบนามสกุลไฟล์รูปภาพ
     * 
     * @param fileName ชื่อไฟล์
     * @return true หากเป็นนามสกุลที่อนุญาต
     */
    public boolean validateImageExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return false;
        }

        String extension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        return ALLOWED_IMAGE_EXTENSIONS.contains(extension);
    }

    // ==================== FILE UPLOAD METHODS ====================

    /**
     * อัพโหลดรูปโปรไฟล์
     * 
     * @param username ชื่อผู้ใช้
     * @param file     ไฟล์ที่อัพโหลด (MultipartFile)
     * @return Map ผลการอัพโหลด
     */
    public Map<String, Object> uploadProfileImage(String username, MultipartFile file) {
        Map<String, Object> result = new HashMap<>();

        try {
            // ตรวจสอบไฟล์
            String originalFilename = file.getOriginalFilename();
            Map<String, Object> validation = validateImageFile(originalFilename, file.getSize());

            if (!(boolean) validation.get("valid")) {
                result.put("success", false);
                result.put("validation", validation);
                return result;
            }

            // สร้างโฟลเดอร์ถ้ายังไม่มี
            Path uploadPath = Paths.get(UPLOAD_DIR, PROFILE_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // สร้างชื่อไฟล์ใหม่
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String newFilename = username + "_" + timestamp + extension;

            // บันทึกไฟล์
            Path filePath = uploadPath.resolve(newFilename);
            Files.write(filePath, file.getBytes());

            result.put("success", true);
            result.put("filename", newFilename);
            result.put("path", filePath.toString());
            result.put("size", file.getSize());

        } catch (IOException e) {
            result.put("success", false);
            result.put("error", "ไม่สามารถบันทึกไฟล์ได้: " + e.getMessage());
        }

        return result;
    }

    /**
     * ดึงรูปโปรไฟล์ของผู้ใช้
     * 
     * @param username ชื่อผู้ใช้
     * @return ข้อมูลไฟล์เป็น byte array หรือ null หากไม่พบ
     */
    public byte[] getProfileImage(String username) {
        try {
            Path profileDir = Paths.get(UPLOAD_DIR, PROFILE_DIR);

            if (!Files.exists(profileDir)) {
                return null;
            }

            // ค้นหาไฟล์ที่ขึ้นต้นด้วย username
            Optional<Path> profileFile = Files.list(profileDir)
                    .filter(path -> path.getFileName().toString().startsWith(username + "_"))
                    .sorted(Comparator.reverseOrder()) // เอาไฟล์ล่าสุด
                    .findFirst();

            if (profileFile.isPresent()) {
                return Files.readAllBytes(profileFile.get());
            }

        } catch (IOException e) {
            System.err.println("Error reading profile image: " + e.getMessage());
        }

        return null;
    }
}
```

---

## สรุป OOP Concepts ที่ใช้

| Concept | จำนวน | ที่อยู่ |
|---------|-------|--------|
| **Inheritance** | 4 | User, Booking, BusTrip, BusRoute → BaseEntity |
| **Polymorphism** | 4 | BookingRepository, UserRepository, BusRouteRepository, BusTripRepository |
| **Aggregation** | 3 | BusTrip→Route, Booking→Trip, Booking→User |
| **Composition** | 2 | TripSchedule→TripTimeSlot, UserProfile→ContactInfo/Preferences |
| **Data Sorting** | 2 | BookingService.sortBookings(), BusTripService.sortTripsByDepartureTime() |
| **Data Searching** | 3 | BusRouteService.searchRoutes(), UserService.searchUsersByRole/Name() |
| **File I/O** | 1 | FileService (readTextFile, writeTextFile, uploadProfileImage...) |

**รวม: ครบทุกข้อตามที่กำหนด ✅**
