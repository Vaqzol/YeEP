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
    
    // ลบ bookings ก่อนวันที่กำหนด (ผ่าน trip.tripDate)
    int deleteByTripTripDateBefore(java.time.LocalDate date);
    
    // หาการจองตามสายรถและวันที่ (สำหรับคนขับ)
    @Query("SELECT b FROM Booking b WHERE b.trip.route.id = :routeId AND b.trip.tripDate = :date AND b.status = 'confirmed' ORDER BY b.trip.departureTime, b.seatNumber")
    List<Booking> findByRouteIdAndDate(@Param("routeId") Long routeId, @Param("date") java.time.LocalDate date);
}
