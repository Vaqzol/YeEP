package com.yeep.controller;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.yeep.entity.Booking;
import com.yeep.entity.BusRoute;
import com.yeep.entity.BusTrip;
import com.yeep.service.BookingService;
import com.yeep.service.BusRouteService;
import com.yeep.service.BusTripService;

@RestController
@RequestMapping("/api/booking")
public class BookingController {
    
    @Autowired
    private BusRouteService busRouteService;
    
    @Autowired
    private BusTripService busTripService;
    
    @Autowired
    private BookingService bookingService;
    
    // ดึงสถานที่ทั้งหมด
    @GetMapping("/locations")
    public ResponseEntity<Map<String, Object>> getLocations() {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("locations", busRouteService.getAllLocations());
        return ResponseEntity.ok(response);
    }
    
    // ดึงสายรถทั้งหมด
    @GetMapping("/routes")
    public ResponseEntity<Map<String, Object>> getRoutes() {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("routes", busRouteService.getAllRoutes());
        return ResponseEntity.ok(response);
    }
    
    // ค้นหาสายรถตามต้นทาง-ปลายทาง
    @GetMapping("/search-route")
    public ResponseEntity<Map<String, Object>> searchRoutes(
            @RequestParam(required = false) String origin,
            @RequestParam(required = false) String destination) {
        Map<String, Object> response = new HashMap<>();
        List<BusRoute> routes = busRouteService.searchRoutes(origin, destination);
        response.put("success", true);
        response.put("routes", routes);
        return ResponseEntity.ok(response);
    }
    
    // ดึงสายรถตาม ID
    @GetMapping("/routes/{id}")
    public ResponseEntity<Map<String, Object>> getRouteById(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        Optional<BusRoute> route = busRouteService.getRouteById(id);
        
        if (route.isEmpty()) {
            response.put("success", false);
            response.put("message", "ไม่พบสายรถ");
            return ResponseEntity.badRequest().body(response);
        }
        
        response.put("success", true);
        response.put("route", route.get());
        return ResponseEntity.ok(response);
    }
    
    // ดึงเที่ยวรถของสายและวันที่
    @GetMapping("/trips")
    public ResponseEntity<Map<String, Object>> getTrips(
            @RequestParam Long routeId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Map<String, Object> response = new HashMap<>();
        
        List<BusTripService.TripWithAvailability> trips = busTripService.getTripsWithAvailability(routeId, date);
        
        // แปลงเป็น format ที่ Flutter ต้องการ
        List<Map<String, Object>> tripList = new ArrayList<>();
        for (BusTripService.TripWithAvailability twa : trips) {
            Map<String, Object> tripMap = new HashMap<>();
            tripMap.put("id", twa.trip.getId());
            tripMap.put("tripNumber", twa.trip.getTripNumber());
            tripMap.put("departureTime", twa.trip.getDepartureTime().format(DateTimeFormatter.ofPattern("HH:mm")));
            tripMap.put("arrivalTime", twa.trip.getArrivalTime().format(DateTimeFormatter.ofPattern("HH:mm")));
            tripMap.put("tripDate", twa.trip.getTripDate().toString());
            tripMap.put("totalSeats", twa.trip.getTotalSeats());
            tripMap.put("availableSeats", twa.availableSeats);
            tripMap.put("bookedSeats", twa.bookedSeats);
            tripList.add(tripMap);
        }
        
        response.put("success", true);
        response.put("trips", tripList);
        return ResponseEntity.ok(response);
    }
    
    // ดึงข้อมูลที่นั่งของเที่ยวรถ
    @GetMapping("/trips/{tripId}/seats")
    public ResponseEntity<Map<String, Object>> getTripSeats(@PathVariable Long tripId) {
        Map<String, Object> response = new HashMap<>();
        
        Optional<BusTrip> tripOpt = busTripService.getTripById(tripId);
        if (tripOpt.isEmpty()) {
            response.put("success", false);
            response.put("message", "ไม่พบเที่ยวรถ");
            return ResponseEntity.badRequest().body(response);
        }
        
        BusTrip trip = tripOpt.get();
        List<String> bookedSeats = bookingService.getBookedSeats(tripId);
        
        // สร้างข้อมูลที่นั่งทั้งหมด (20 ที่นั่ง: 1A-10A, 1B-10B)
        List<Map<String, Object>> seats = new ArrayList<>();
        for (int i = 1; i <= 10; i++) {
            // ที่นั่งฝั่ง A
            Map<String, Object> seatA = new HashMap<>();
            String seatNumberA = i + "A";
            seatA.put("seatNumber", seatNumberA);
            seatA.put("isBooked", bookedSeats.contains(seatNumberA));
            seats.add(seatA);
            
            // ที่นั่งฝั่ง B
            Map<String, Object> seatB = new HashMap<>();
            String seatNumberB = i + "B";
            seatB.put("seatNumber", seatNumberB);
            seatB.put("isBooked", bookedSeats.contains(seatNumberB));
            seats.add(seatB);
        }
        
        Map<String, Object> tripInfo = new HashMap<>();
        tripInfo.put("id", trip.getId());
        tripInfo.put("tripNumber", trip.getTripNumber());
        tripInfo.put("departureTime", trip.getDepartureTime().format(DateTimeFormatter.ofPattern("HH:mm")));
        tripInfo.put("arrivalTime", trip.getArrivalTime().format(DateTimeFormatter.ofPattern("HH:mm")));
        tripInfo.put("tripDate", trip.getTripDate().toString());
        tripInfo.put("routeName", trip.getRoute().getName());
        tripInfo.put("routeColor", trip.getRoute().getColor());
        tripInfo.put("origin", trip.getRoute().getOrigin());
        tripInfo.put("destination", trip.getRoute().getDestination());
        
        response.put("success", true);
        response.put("trip", tripInfo);
        response.put("seats", seats);
        response.put("bookedSeats", bookedSeats);
        return ResponseEntity.ok(response);
    }
    
    // จองที่นั่ง
    @PostMapping("/book")
    public ResponseEntity<Map<String, Object>> bookSeats(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Long tripId = Long.valueOf(request.get("tripId").toString());
            String username = request.get("username").toString();
            @SuppressWarnings("unchecked")
            List<String> seatNumbers = (List<String>) request.get("seatNumbers");
            
            List<Booking> bookings;
            if (seatNumbers.size() == 1) {
                Booking booking = bookingService.createBooking(tripId, username, seatNumbers.get(0));
                bookings = List.of(booking);
            } else {
                bookings = bookingService.createMultipleBookings(tripId, username, seatNumbers);
            }
            
            // แปลงเป็น response
            List<Map<String, Object>> bookingList = new ArrayList<>();
            for (Booking b : bookings) {
                Map<String, Object> bMap = new HashMap<>();
                bMap.put("id", b.getId());
                bMap.put("bookingCode", b.getBookingCode());
                bMap.put("seatNumber", b.getSeatNumber());
                bMap.put("status", b.getStatus());
                bMap.put("bookedAt", b.getBookedAt().toString());
                bookingList.add(bMap);
            }
            
            response.put("success", true);
            response.put("message", "จองที่นั่งสำเร็จ");
            response.put("bookings", bookingList);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    // ยกเลิกการจอง
    @DeleteMapping("/bookings/{bookingId}")
    public ResponseEntity<Map<String, Object>> cancelBooking(
            @PathVariable Long bookingId,
            @RequestParam String username) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Booking booking = bookingService.cancelBooking(bookingId, username);
            response.put("success", true);
            response.put("message", "ยกเลิกการจองสำเร็จ");
            response.put("bookingCode", booking.getBookingCode());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    // ดึงการจองของ user
    @GetMapping("/user/{username}/bookings")
    public ResponseEntity<Map<String, Object>> getUserBookings(@PathVariable String username) {
        Map<String, Object> response = new HashMap<>();
        
        List<Booking> bookings = bookingService.getUserBookings(username);
        
        List<Map<String, Object>> bookingList = new ArrayList<>();
        for (Booking b : bookings) {
            Map<String, Object> bMap = new HashMap<>();
            bMap.put("id", b.getId());
            bMap.put("bookingCode", b.getBookingCode());
            bMap.put("seatNumber", b.getSeatNumber());
            bMap.put("status", b.getStatus());
            bMap.put("bookedAt", b.getBookedAt().toString());
            
            // ข้อมูลเที่ยวรถ
            BusTrip trip = b.getTrip();
            Map<String, Object> tripMap = new HashMap<>();
            tripMap.put("id", trip.getId());
            tripMap.put("tripNumber", trip.getTripNumber());
            tripMap.put("departureTime", trip.getDepartureTime().format(DateTimeFormatter.ofPattern("HH:mm")));
            tripMap.put("arrivalTime", trip.getArrivalTime().format(DateTimeFormatter.ofPattern("HH:mm")));
            tripMap.put("tripDate", trip.getTripDate().toString());
            tripMap.put("routeName", trip.getRoute().getName());
            tripMap.put("routeColor", trip.getRoute().getColor());
            tripMap.put("origin", trip.getRoute().getOrigin());
            tripMap.put("destination", trip.getRoute().getDestination());
            bMap.put("trip", tripMap);
            
            bookingList.add(bMap);
        }
        
        response.put("success", true);
        response.put("bookings", bookingList);
        return ResponseEntity.ok(response);
    }
    
    // ดึงประวัติการจองทั้งหมดของ user
    @GetMapping("/user/{username}/history")
    public ResponseEntity<Map<String, Object>> getUserBookingHistory(@PathVariable String username) {
        Map<String, Object> response = new HashMap<>();
        
        List<Booking> bookings = bookingService.getUserBookingHistory(username);
        
        List<Map<String, Object>> bookingList = new ArrayList<>();
        for (Booking b : bookings) {
            Map<String, Object> bMap = new HashMap<>();
            bMap.put("id", b.getId());
            bMap.put("bookingCode", b.getBookingCode());
            bMap.put("seatNumber", b.getSeatNumber());
            bMap.put("status", b.getStatus());
            bMap.put("bookedAt", b.getBookedAt().toString());
            if (b.getCancelledAt() != null) {
                bMap.put("cancelledAt", b.getCancelledAt().toString());
            }
            
            // ข้อมูลเที่ยวรถ
            BusTrip trip = b.getTrip();
            Map<String, Object> tripMap = new HashMap<>();
            tripMap.put("id", trip.getId());
            tripMap.put("tripNumber", trip.getTripNumber());
            tripMap.put("departureTime", trip.getDepartureTime().format(DateTimeFormatter.ofPattern("HH:mm")));
            tripMap.put("arrivalTime", trip.getArrivalTime().format(DateTimeFormatter.ofPattern("HH:mm")));
            tripMap.put("tripDate", trip.getTripDate().toString());
            tripMap.put("routeName", trip.getRoute().getName());
            tripMap.put("routeColor", trip.getRoute().getColor());
            tripMap.put("origin", trip.getRoute().getOrigin());
            tripMap.put("destination", trip.getRoute().getDestination());
            bMap.put("trip", tripMap);
            
            bookingList.add(bMap);
        }
        
        response.put("success", true);
        response.put("bookings", bookingList);
        return ResponseEntity.ok(response);
    }
    
    // Initialize data endpoint
    @PostMapping("/init-data")
    public ResponseEntity<Map<String, Object>> initializeData() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // สร้างสายรถ
            busRouteService.initializeRoutes();
            
            // สร้างเที่ยวรถสำหรับวันนี้และพรุ่งนี้
            List<BusRoute> routes = busRouteService.getAllRoutes();
            LocalDate today = LocalDate.now();
            LocalDate tomorrow = today.plusDays(1);
            
            for (BusRoute route : routes) {
                if (route.getHasTrips() != null && route.getHasTrips()) {
                    // สายที่มีเที่ยว - สร้างเที่ยวรถ
                    List<BusTripService.TripTime> times = createTripTimes(route.getColor());
                    
                    // ตรวจสอบว่ายังไม่มีเที่ยวรถวันนี้
                    if (busTripService.getTripsWithAvailability(route.getId(), today).isEmpty()) {
                        busTripService.createTripsForRoute(route, today, times);
                    }
                    if (busTripService.getTripsWithAvailability(route.getId(), tomorrow).isEmpty()) {
                        busTripService.createTripsForRoute(route, tomorrow, times);
                    }
                }
            }
            
            response.put("success", true);
            response.put("message", "สร้างข้อมูลเริ่มต้นสำเร็จ");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "เกิดข้อผิดพลาด: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    // Reset data endpoint - ลบข้อมูลทั้งหมดและสร้างใหม่
    @PostMapping("/reset-data")
    public ResponseEntity<Map<String, Object>> resetData() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // ลบข้อมูลเก่าทั้งหมด
            bookingService.deleteAll();
            busTripService.deleteAll();
            busRouteService.deleteAll();
            
            // สร้างข้อมูลใหม่
            busRouteService.initializeRoutes();
            
            // สร้างเที่ยวรถสำหรับวันนี้และพรุ่งนี้
            List<BusRoute> routes = busRouteService.getAllRoutes();
            LocalDate today = LocalDate.now();
            LocalDate tomorrow = today.plusDays(1);
            
            for (BusRoute route : routes) {
                if (route.getHasTrips() != null && route.getHasTrips()) {
                    List<BusTripService.TripTime> times = createTripTimes(route.getColor());
                    busTripService.createTripsForRoute(route, today, times);
                    busTripService.createTripsForRoute(route, tomorrow, times);
                }
            }
            
            response.put("success", true);
            response.put("message", "รีเซ็ตข้อมูลสำเร็จ");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "เกิดข้อผิดพลาด: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    // สร้างเวลาเที่ยวรถตามสี (ข้อมูลจริง มทส.)
    private List<BusTripService.TripTime> createTripTimes(String color) {
        List<BusTripService.TripTime> times = new ArrayList<>();
        
        switch (color) {
            case "green":
                // สายสีเขียว 07:07-09:30 ห่างกัน 7 นาที
                times.add(new BusTripService.TripTime(LocalTime.of(7, 7), LocalTime.of(7, 27)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 14), LocalTime.of(7, 34)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 21), LocalTime.of(7, 41)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 28), LocalTime.of(7, 48)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 35), LocalTime.of(7, 55)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 42), LocalTime.of(8, 2)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 49), LocalTime.of(8, 9)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 56), LocalTime.of(8, 16)));
                times.add(new BusTripService.TripTime(LocalTime.of(8, 3), LocalTime.of(8, 23)));
                times.add(new BusTripService.TripTime(LocalTime.of(8, 10), LocalTime.of(8, 30)));
                times.add(new BusTripService.TripTime(LocalTime.of(9, 0), LocalTime.of(9, 20)));
                times.add(new BusTripService.TripTime(LocalTime.of(9, 30), LocalTime.of(9, 50)));
                break;
            case "purple":
                // สายสีม่วง 07:05-09:10 ห่างกัน 5 นาที
                times.add(new BusTripService.TripTime(LocalTime.of(7, 5), LocalTime.of(7, 20)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 10), LocalTime.of(7, 25)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 15), LocalTime.of(7, 30)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 20), LocalTime.of(7, 35)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 25), LocalTime.of(7, 40)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 30), LocalTime.of(7, 45)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 35), LocalTime.of(7, 50)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 40), LocalTime.of(7, 55)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 45), LocalTime.of(8, 0)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 50), LocalTime.of(8, 5)));
                times.add(new BusTripService.TripTime(LocalTime.of(8, 30), LocalTime.of(8, 45)));
                times.add(new BusTripService.TripTime(LocalTime.of(9, 0), LocalTime.of(9, 15)));
                break;
            case "orange":
                // สายสีส้ม 07:25-08:55 ห่างกัน 15 นาที
                times.add(new BusTripService.TripTime(LocalTime.of(7, 25), LocalTime.of(7, 35)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 40), LocalTime.of(7, 50)));
                times.add(new BusTripService.TripTime(LocalTime.of(7, 55), LocalTime.of(8, 5)));
                times.add(new BusTripService.TripTime(LocalTime.of(8, 10), LocalTime.of(8, 20)));
                times.add(new BusTripService.TripTime(LocalTime.of(8, 25), LocalTime.of(8, 35)));
                times.add(new BusTripService.TripTime(LocalTime.of(8, 40), LocalTime.of(8, 50)));
                times.add(new BusTripService.TripTime(LocalTime.of(8, 55), LocalTime.of(9, 5)));
                break;
            case "red":
                // สายสีแดง 09:10-20:40 ห่างกัน 10-15 นาที
                times.add(new BusTripService.TripTime(LocalTime.of(9, 10), LocalTime.of(10, 10)));
                times.add(new BusTripService.TripTime(LocalTime.of(10, 20), LocalTime.of(11, 20)));
                times.add(new BusTripService.TripTime(LocalTime.of(11, 30), LocalTime.of(12, 30)));
                times.add(new BusTripService.TripTime(LocalTime.of(12, 40), LocalTime.of(13, 40)));
                times.add(new BusTripService.TripTime(LocalTime.of(13, 50), LocalTime.of(14, 50)));
                times.add(new BusTripService.TripTime(LocalTime.of(15, 0), LocalTime.of(16, 0)));
                times.add(new BusTripService.TripTime(LocalTime.of(16, 10), LocalTime.of(17, 10)));
                times.add(new BusTripService.TripTime(LocalTime.of(17, 20), LocalTime.of(18, 20)));
                times.add(new BusTripService.TripTime(LocalTime.of(18, 30), LocalTime.of(19, 30)));
                times.add(new BusTripService.TripTime(LocalTime.of(19, 40), LocalTime.of(20, 40)));
                break;
            case "yellow":
                // สายสีเหลือง 17:30-19:00 ห่างกัน 30 นาที
                times.add(new BusTripService.TripTime(LocalTime.of(17, 30), LocalTime.of(18, 0)));
                times.add(new BusTripService.TripTime(LocalTime.of(18, 0), LocalTime.of(18, 30)));
                times.add(new BusTripService.TripTime(LocalTime.of(18, 30), LocalTime.of(19, 0)));
                break;
            case "blue":
                // สายสีน้ำเงิน 3 รอบ: 08:30, 12:00, 16:30
                times.add(new BusTripService.TripTime(LocalTime.of(8, 30), LocalTime.of(9, 0)));
                times.add(new BusTripService.TripTime(LocalTime.of(12, 0), LocalTime.of(12, 30)));
                times.add(new BusTripService.TripTime(LocalTime.of(16, 30), LocalTime.of(17, 0)));
                break;
            default:
                break;
        }
        
        return times;
    }
}
