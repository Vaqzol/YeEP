package com.yeep.controller;

import java.time.LocalDate;
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

import com.yeep.dto.BookingResponse;
import com.yeep.dto.SeatResponse;
import com.yeep.dto.TripResponse;
import com.yeep.entity.Booking;
import com.yeep.entity.BusRoute;
import com.yeep.entity.BusTrip;
import com.yeep.service.BookingService;
import com.yeep.service.BusRouteService;
import com.yeep.service.BusTripService;
import com.yeep.util.EntityMapper;
import com.yeep.util.RouteScheduleConfig;

@RestController
@RequestMapping("/api/booking")
public class BookingController {
    
    @Autowired
    private BusRouteService busRouteService;
    
    @Autowired
    private BusTripService busTripService;
    
    @Autowired
    private BookingService bookingService;

    // ==================== LOCATION & ROUTE ENDPOINTS ====================
    
    @GetMapping("/locations")
    public ResponseEntity<Map<String, Object>> getLocations() {
        return successResponse("locations", busRouteService.getAllLocations());
    }
    
    @GetMapping("/routes")
    public ResponseEntity<Map<String, Object>> getRoutes() {
        return successResponse("routes", busRouteService.getAllRoutes());
    }
    
    @GetMapping("/search-route")
    public ResponseEntity<Map<String, Object>> searchRoutes(
            @RequestParam(required = false) String origin,
            @RequestParam(required = false) String destination) {
        List<BusRoute> routes = busRouteService.searchRoutes(origin, destination);
        return successResponse("routes", routes);
    }
    
    @GetMapping("/routes/{id}")
    public ResponseEntity<Map<String, Object>> getRouteById(@PathVariable Long id) {
        Optional<BusRoute> route = busRouteService.getRouteById(id);
        if (route.isEmpty()) {
            return errorResponse("ไม่พบสายรถ");
        }
        return successResponse("route", route.get());
    }

    // ==================== TRIP ENDPOINTS ====================
    
    @GetMapping("/trips")
    public ResponseEntity<Map<String, Object>> getTrips(
            @RequestParam Long routeId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        // Ensure route exists
        Optional<BusRoute> routeOpt = busRouteService.getRouteById(routeId);
        if (routeOpt.isEmpty()) {
            return errorResponse("ไม่พบสายรถ");
        }
        BusRoute route = routeOpt.get();

        var trips = busTripService.getTripsWithAvailability(routeId, date);

        // If no trips exist for the requested date and this route normally has trips,
        // generate trips for that date on-demand using the schedule config.
        if (trips.isEmpty() && Boolean.TRUE.equals(route.getHasTrips())) {
            var times = RouteScheduleConfig.getTripTimes(route.getColor());
            if (!times.isEmpty()) {
                busTripService.createTripsForRoute(route, date, times);
                trips = busTripService.getTripsWithAvailability(routeId, date);
            }
        }

        List<TripResponse> tripList = EntityMapper.toTripResponseList(trips);
        return successResponse("trips", tripList);
    }
    
    @GetMapping("/trips/{tripId}/seats")
    public ResponseEntity<Map<String, Object>> getTripSeats(@PathVariable Long tripId) {
        Optional<BusTrip> tripOpt = busTripService.getTripById(tripId);
        if (tripOpt.isEmpty()) {
            return errorResponse("ไม่พบเที่ยวรถ");
        }
        
        BusTrip trip = tripOpt.get();
        List<String> bookedSeats = bookingService.getBookedSeats(tripId);
        List<SeatResponse> seats = EntityMapper.generateSeatResponses(bookedSeats);
        TripResponse tripInfo = EntityMapper.toTripResponse(trip);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("trip", tripInfo);
        response.put("seats", seats);
        response.put("bookedSeats", bookedSeats);
        return ResponseEntity.ok(response);
    }

    // ==================== BOOKING ENDPOINTS ====================
    
    @PostMapping("/book")
    public ResponseEntity<Map<String, Object>> bookSeats(@RequestBody Map<String, Object> request) {
        try {
            Long tripId = Long.valueOf(request.get("tripId").toString());
            String username = request.get("username").toString();
            @SuppressWarnings("unchecked")
            List<String> seatNumbers = (List<String>) request.get("seatNumbers");
            
            List<Booking> bookings = seatNumbers.size() == 1
                    ? List.of(bookingService.createBooking(tripId, username, seatNumbers.get(0)))
                    : bookingService.createMultipleBookings(tripId, username, seatNumbers);
            
            List<BookingResponse> bookingList = EntityMapper.toBookingResponseList(bookings);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "จองที่นั่งสำเร็จ");
            response.put("bookings", bookingList);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return errorResponse(e.getMessage());
        }
    }
    
    @DeleteMapping("/bookings/{bookingId}")
    public ResponseEntity<Map<String, Object>> cancelBooking(
            @PathVariable Long bookingId,
            @RequestParam String username) {
        try {
            Booking booking = bookingService.cancelBooking(bookingId, username);
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "ยกเลิกการจองสำเร็จ");
            response.put("bookingCode", booking.getBookingCode());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return errorResponse(e.getMessage());
        }
    }
    
    @GetMapping("/user/{username}/bookings")
    public ResponseEntity<Map<String, Object>> getUserBookings(@PathVariable String username) {
        List<Booking> bookings = bookingService.getUserBookings(username);
        List<BookingResponse> bookingList = EntityMapper.toBookingResponseListWithTrips(bookings);
        return successResponse("bookings", bookingList);
    }
    
    @GetMapping("/user/{username}/history")
    public ResponseEntity<Map<String, Object>> getUserBookingHistory(@PathVariable String username) {
        List<Booking> bookings = bookingService.getUserBookingHistory(username);
        List<BookingResponse> bookingList = EntityMapper.toBookingResponseListWithTrips(bookings);
        return successResponse("bookings", bookingList);
    }

    // ==================== DRIVER ENDPOINTS ====================
    
    @GetMapping("/driver/bookings")
    public ResponseEntity<Map<String, Object>> getBookingsByRoute(
            @RequestParam Long routeId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        List<Booking> bookings = bookingService.getBookingsByRouteAndDate(routeId, date);
        List<BookingResponse> bookingList = EntityMapper.toBookingResponseListWithTrips(bookings);
        return successResponse("bookings", bookingList);
    }

    // ==================== DATA INITIALIZATION ====================
    
    @PostMapping("/init-data")
    public ResponseEntity<Map<String, Object>> initializeData() {
        try {
            busRouteService.initializeRoutes();
            createTripsForRoutes(LocalDate.now(), LocalDate.now().plusDays(1));
            return successResponse("message", "สร้างข้อมูลเริ่มต้นสำเร็จ");
        } catch (Exception e) {
            return errorResponse("เกิดข้อผิดพลาด: " + e.getMessage());
        }
    }
    
    @PostMapping("/reset-data")
    public ResponseEntity<Map<String, Object>> resetData() {
        try {
            // ลบข้อมูลเก่าทั้งหมด
            bookingService.deleteAll();
            busTripService.deleteAll();
            busRouteService.deleteAll();
            
            // สร้างข้อมูลใหม่
            busRouteService.initializeRoutes();
            createTripsForRoutes(LocalDate.now(), LocalDate.now().plusDays(1));
            
            return successResponse("message", "รีเซ็ตข้อมูลสำเร็จ");
        } catch (Exception e) {
            return errorResponse("เกิดข้อผิดพลาด: " + e.getMessage());
        }
    }

    // ==================== PRIVATE HELPER METHODS ====================
    
    private void createTripsForRoutes(LocalDate... dates) {
        List<BusRoute> routes = busRouteService.getAllRoutes();
        
        for (BusRoute route : routes) {
            if (Boolean.TRUE.equals(route.getHasTrips())) {
                var times = RouteScheduleConfig.getTripTimes(route.getColor());
                
                for (LocalDate date : dates) {
                    if (busTripService.getTripsWithAvailability(route.getId(), date).isEmpty()) {
                        busTripService.createTripsForRoute(route, date, times);
                    }
                }
            }
        }
    }
    
    private ResponseEntity<Map<String, Object>> successResponse(String key, Object data) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put(key, data);
        return ResponseEntity.ok(response);
    }
    
    private ResponseEntity<Map<String, Object>> errorResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        return ResponseEntity.badRequest().body(response);
    }
}
