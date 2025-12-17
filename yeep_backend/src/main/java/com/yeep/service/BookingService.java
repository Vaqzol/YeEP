package com.yeep.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.yeep.entity.Booking;
import com.yeep.entity.BusTrip;
import com.yeep.entity.User;
import com.yeep.repository.BookingRepository;
import com.yeep.repository.BusTripRepository;
import com.yeep.repository.UserRepository;

@Service
public class BookingService {
    
    @Autowired
    private BookingRepository bookingRepository;
    
    @Autowired
    private BusTripRepository busTripRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    // จองที่นั่ง
    @Transactional
    public Booking createBooking(Long tripId, String username, String seatNumber) throws Exception {
        // ตรวจสอบเที่ยวรถ
        BusTrip trip = busTripRepository.findById(tripId)
                .orElseThrow(() -> new Exception("ไม่พบเที่ยวรถ"));
        
        // ตรวจสอบ user
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new Exception("ไม่พบผู้ใช้"));
        
        // ตรวจสอบว่าที่นั่งว่างหรือไม่
        if (bookingRepository.existsByTripAndSeatNumberAndStatus(trip, seatNumber, "confirmed")) {
            throw new Exception("ที่นั่งนี้ถูกจองแล้ว");
        }
        
        // สร้าง booking code (P0001, P0002, ...)
        String bookingCode = generateBookingCode();
        
        // สร้างการจอง
        Booking booking = new Booking();
        booking.setBookingCode(bookingCode);
        booking.setTrip(trip);
        booking.setUser(user);
        booking.setSeatNumber(seatNumber);
        booking.setStatus("confirmed");
        booking.setBookedAt(LocalDateTime.now());
        
        return bookingRepository.save(booking);
    }
    
    // จองหลายที่นั่งพร้อมกัน
    @Transactional
    public List<Booking> createMultipleBookings(Long tripId, String username, List<String> seatNumbers) throws Exception {
        // ตรวจสอบเที่ยวรถ
        BusTrip trip = busTripRepository.findById(tripId)
                .orElseThrow(() -> new Exception("ไม่พบเที่ยวรถ"));
        
        // ตรวจสอบ user
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new Exception("ไม่พบผู้ใช้"));
        
        // ตรวจสอบที่นั่งทั้งหมด
        for (String seatNumber : seatNumbers) {
            if (bookingRepository.existsByTripAndSeatNumberAndStatus(trip, seatNumber, "confirmed")) {
                throw new Exception("ที่นั่ง " + seatNumber + " ถูกจองแล้ว");
            }
        }
        
        // สร้างการจองทั้งหมด
        List<Booking> bookings = new java.util.ArrayList<>();
        for (String seatNumber : seatNumbers) {
            String bookingCode = generateBookingCode();
            
            Booking booking = new Booking();
            booking.setBookingCode(bookingCode);
            booking.setTrip(trip);
            booking.setUser(user);
            booking.setSeatNumber(seatNumber);
            booking.setStatus("confirmed");
            booking.setBookedAt(LocalDateTime.now());
            
            bookings.add(bookingRepository.save(booking));
        }
        
        return bookings;
    }
    
    // ยกเลิกการจอง
    @Transactional
    public Booking cancelBooking(Long bookingId, String username) throws Exception {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new Exception("ไม่พบการจอง"));
        
        // ตรวจสอบว่าเป็นเจ้าของการจอง
        if (!booking.getUser().getUsername().equals(username)) {
            throw new Exception("คุณไม่มีสิทธิ์ยกเลิกการจองนี้");
        }
        
        // ตรวจสอบสถานะ
        if (!"confirmed".equals(booking.getStatus())) {
            throw new Exception("การจองนี้ถูกยกเลิกไปแล้ว");
        }
        
        booking.setStatus("cancelled");
        booking.setCancelledAt(LocalDateTime.now());
        
        return bookingRepository.save(booking);
    }
    
    // ดึงการจองของ user
    public List<Booking> getUserBookings(String username) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty()) {
            return List.of();
        }
        return bookingRepository.findByUserAndStatusOrderByBookedAtDesc(userOpt.get(), "confirmed");
    }
    
    // ดึงประวัติการจองทั้งหมดของ user
    public List<Booking> getUserBookingHistory(String username) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty()) {
            return List.of();
        }
        return bookingRepository.findByUserOrderByBookedAtDesc(userOpt.get());
    }
    
    // ดึงที่นั่งที่จองแล้วของเที่ยวรถ
    public List<String> getBookedSeats(Long tripId) {
        return bookingRepository.findBookedSeatsByTripId(tripId);
    }
    
    // ดึงการจองจาก booking code
    public Optional<Booking> getBookingByCode(String bookingCode) {
        return bookingRepository.findByBookingCode(bookingCode);
    }
    
    // ลบข้อมูลทั้งหมด
    @Transactional
    public void deleteAll() {
        bookingRepository.deleteAll();
    }
    
    // สร้าง booking code
    private String generateBookingCode() {
        Optional<String> lastCode = bookingRepository.findLastBookingCode();
        if (lastCode.isEmpty()) {
            return "P0001";
        }
        
        // แยกตัวเลขจาก P0001 -> 1
        String last = lastCode.get();
        int number = Integer.parseInt(last.substring(1));
        return String.format("P%04d", number + 1);
    }
}
