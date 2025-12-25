# Class Diagram - YeEP Bus Ticketing System

## 📊 ภาพรวม Entity และความสัมพันธ์

```mermaid
classDiagram
    %% ==================== BASE CLASS (Inheritance) ====================
    class BaseEntity {
        <<abstract>>
        #Long id
        #LocalDateTime createdAt
        #LocalDateTime updatedAt
        +getId() Long
        +setId(Long id)
        +getCreatedAt() LocalDateTime
        +getUpdatedAt() LocalDateTime
        +isNew() boolean
        #onCreate()
        #onUpdate()
    }
    
    %% ==================== ENTITY CLASSES ====================
    class User {
        -String username
        -String email
        -String phone
        -String password
        -String role
        -String profilePicture
        +getUsername() String
        +setUsername(String)
        +getRole() String
    }
    
    class BusRoute {
        -String name
        -String color
        -String origin
        -String destination
        -Boolean hasTrips
        -String timeRange
        +getName() String
        +getColor() String
    }
    
    class BusTrip {
        -Integer tripNumber
        -LocalTime departureTime
        -LocalTime arrivalTime
        -LocalDate tripDate
        -Integer totalSeats
        +getDepartureTime() LocalTime
        +getTripDate() LocalDate
    }
    
    class Booking {
        -String bookingCode
        -String seatNumber
        -String status
        -LocalDateTime bookedAt
        -LocalDateTime cancelledAt
        +getBookingCode() String
        +getStatus() String
    }
    
    %% ==================== INHERITANCE ====================
    BaseEntity <|-- User : extends
    BaseEntity <|-- BusRoute : extends
    BaseEntity <|-- BusTrip : extends
    BaseEntity <|-- Booking : extends
    
    %% ==================== ASSOCIATIONS (Aggregation/Composition) ====================
    BusRoute "1" --> "*" BusTrip : has trips
    BusTrip "1" --> "*" Booking : contains bookings
    User "1" --> "*" Booking : makes bookings
```

---

## 🔧 Service Layer - Polymorphism

```mermaid
classDiagram
    %% ==================== INTERFACE (Polymorphism) ====================
    class NotificationService {
        <<interface>>
        +sendNotification(String to, String subject, String message) boolean
        +sendBookingConfirmation(String to, String bookingCode, String routeName, String seatNumber) boolean
        +sendCancellationNotification(String to, String bookingCode) boolean
        +isAvailable() boolean
        +getType() String
    }
    
    %% ==================== IMPLEMENTATIONS ====================
    class EmailNotificationService {
        -String TYPE = "EMAIL"
        +sendNotification() boolean
        +sendBookingConfirmation() boolean
        +sendCancellationNotification() boolean
        +isAvailable() boolean
        +getType() String
    }
    
    class SmsNotificationService {
        -String TYPE = "SMS"
        +sendNotification() boolean
        +sendBookingConfirmation() boolean
        +sendCancellationNotification() boolean
        +isAvailable() boolean
        +getType() String
    }
    
    class PushNotificationService {
        -String TYPE = "PUSH"
        +sendNotification() boolean
        +sendBookingConfirmation() boolean
        +sendCancellationNotification() boolean
        +isAvailable() boolean
        +getType() String
    }
    
    %% ==================== POLYMORPHISM ====================
    NotificationService <|.. EmailNotificationService : implements
    NotificationService <|.. SmsNotificationService : implements
    NotificationService <|.. PushNotificationService : implements
    
    %% ==================== MANAGER ====================
    class NotificationManager {
        -Map~String, NotificationService~ notificationServices
        +sendNotification(String type, String to, String subject, String message) boolean
        +sendBookingConfirmationToAll() void
        +sendCancellationToAll() void
        +getService(String type) NotificationService
        +getAvailableServices() List~String~
    }
    
    NotificationManager --> NotificationService : uses
```

---

## 📦 Complete Backend Architecture

```mermaid
classDiagram
    %% ==================== CONTROLLERS ====================
    class BookingController {
        -BusRouteService busRouteService
        -BusTripService busTripService
        -BookingService bookingService
        +getRoutes() ResponseEntity
        +getTrips() ResponseEntity
        +bookSeats() ResponseEntity
        +cancelBooking() ResponseEntity
    }
    
    class UserController {
        -UserService userService
        +login() ResponseEntity
        +register() ResponseEntity
        +updatePassword() ResponseEntity
    }
    
    %% ==================== SERVICES ====================
    class BookingService {
        -BookingRepository bookingRepository
        -BusTripRepository busTripRepository
        -UserRepository userRepository
        +createBooking() Booking
        +cancelBooking() Booking
        +getUserBookingsSorted() List~Booking~
        +sortBookings() List~Booking~
    }
    
    class UserService {
        -UserRepository userRepository
        +register() UserResponse
        +login() UserResponse
        +updatePassword() void
        +hashPassword() String
    }
    
    %% ==================== REPOSITORIES ====================
    class BookingRepository {
        <<interface>>
        +findByUserAndStatusOrderByBookedAtDesc() List~Booking~
        +findBookedSeatsByTripId() List~String~
        +findByRouteIdAndDate() List~Booking~
    }
    
    class UserRepository {
        <<interface>>
        +findByUsername() Optional~User~
        +findByEmail() Optional~User~
        +existsByUsername() boolean
    }
    
    %% ==================== DEPENDENCIES ====================
    BookingController --> BookingService
    BookingController --> BusRouteService
    BookingController --> BusTripService
    UserController --> UserService
    
    BookingService --> BookingRepository
    BookingService --> BusTripRepository
    BookingService --> UserRepository
    UserService --> UserRepository
```

---

## 📝 หมายเหตุ

### Inheritance (การสืบทอด)
- ทุก Entity (`User`, `BusRoute`, `BusTrip`, `Booking`) สืบทอดจาก `BaseEntity`
- `BaseEntity` เป็น abstract class ที่มี fields และ methods ที่ใช้ร่วมกัน

### Polymorphism (ความหลากหลายของรูปแบบ)
- `NotificationService` เป็น Interface
- มี 3 implementation: `EmailNotificationService`, `SmsNotificationService`, `PushNotificationService`
- `NotificationManager` ใช้ Polymorphism ในการจัดการ service ต่างๆ

### Aggregation/Composition
- `BusRoute` มี `BusTrip` หลายๆ ตัว (One-to-Many)
- `BusTrip` มี `Booking` หลายๆ ตัว (One-to-Many)
- `User` มี `Booking` หลายๆ ตัว (One-to-Many)
