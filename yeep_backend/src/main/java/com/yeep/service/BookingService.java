package com.yeep.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.yeep.entity.Booking;
import com.yeep.entity.BusTrip;
import com.yeep.entity.User;
import com.yeep.repository.BookingRepository;
import com.yeep.repository.BusTripRepository;
import com.yeep.repository.UserRepository;

/**
 * BookingService - ใช้หลักการ Data Sorting
 * 
 * Service นี้สาธิตการใช้เทคนิค Data Sorting ด้วย Comparator
 * รองรับการเรียงลำดับตามหลายเงื่อนไข
 */
@Service
public class BookingService {

    private static final String STATUS_CONFIRMED = "confirmed";
    private static final String STATUS_CANCELLED = "cancelled";
    private static final String BOOKING_CODE_PREFIX = "P";

    // ==================== SORTING CONSTANTS ====================
    public static final String SORT_BY_DATE = "date";
    public static final String SORT_BY_STATUS = "status";
    public static final String SORT_BY_ROUTE = "route";
    public static final String SORT_BY_SEAT = "seat";
    public static final String ORDER_ASC = "asc";
    public static final String ORDER_DESC = "desc";

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private BusTripRepository busTripRepository;

    @Autowired
    private UserRepository userRepository;

    // ==================== PUBLIC METHODS ====================

    /**
     * จองที่นั่งเดียว
     */
    @Transactional
    public Booking createBooking(Long tripId, String username, String seatNumber) throws Exception {
        BusTrip trip = findTripOrThrow(tripId);
        User user = findUserOrThrow(username);
        validateSeatAvailable(trip, seatNumber);

        return saveBooking(trip, user, seatNumber);
    }

    /**
     * จองหลายที่นั่งพร้อมกัน
     */
    @Transactional
    public List<Booking> createMultipleBookings(Long tripId, String username, List<String> seatNumbers)
            throws Exception {
        BusTrip trip = findTripOrThrow(tripId);
        User user = findUserOrThrow(username);

        // ตรวจสอบที่นั่งทั้งหมดก่อน
        for (String seatNumber : seatNumbers) {
            validateSeatAvailable(trip, seatNumber);
        }

        // สร้างการจองทั้งหมด
        List<Booking> bookings = new ArrayList<>();
        for (String seatNumber : seatNumbers) {
            bookings.add(saveBooking(trip, user, seatNumber));
        }

        return bookings;
    }

    /**
     * ยกเลิกการจอง
     */
    @Transactional
    public Booking cancelBooking(Long bookingId, String username) throws Exception {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new Exception("ไม่พบการจอง"));

        validateBookingOwner(booking, username);
        validateBookingNotCancelled(booking);

        booking.setStatus(STATUS_CANCELLED);
        booking.setCancelledAt(LocalDateTime.now());

        return bookingRepository.save(booking);
    }

    /**
     * ดึงการจองที่ยืนยันแล้วของ user
     */
    public List<Booking> getUserBookings(String username) {
        return findUserByUsername(username)
                .map(user -> bookingRepository.findByUserAndStatusOrderByBookedAtDesc(user, STATUS_CONFIRMED))
                .orElse(List.of());
    }

    /**
     * ดึงประวัติการจองทั้งหมดของ user
     */
    public List<Booking> getUserBookingHistory(String username) {
        return findUserByUsername(username)
                .map(bookingRepository::findByUserOrderByBookedAtDesc)
                .orElse(List.of());
    }

    // ==================== DATA SORTING METHODS ====================

    /**
     * ดึงการจองพร้อมเรียงลำดับ (Data Sorting)
     * 
     * @param username ชื่อผู้ใช้
     * @param sortBy   ฟิลด์ที่ต้องการเรียง: date, status, route, seat
     * @param order    ลำดับ: asc หรือ desc
     * @return รายการจองที่เรียงลำดับแล้ว
     */
    public List<Booking> getUserBookingsSorted(String username, String sortBy, String order) {
        List<Booking> bookings = getUserBookingHistory(username);
        return sortBookings(bookings, sortBy, order);
    }

    /**
     * เรียงลำดับการจอง (Data Sorting)
     * ใช้ Comparator chains สำหรับการเรียงลำดับข้อมูล
     */
    public List<Booking> sortBookings(List<Booking> bookings, String sortBy, String order) {
        Comparator<Booking> comparator = getComparator(sortBy);

        // กลับลำดับถ้าเป็น DESC
        if (ORDER_DESC.equalsIgnoreCase(order)) {
            comparator = comparator.reversed();
        }

        return bookings.stream()
                .sorted(comparator)
                .collect(Collectors.toList());
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

    /**
     * ดึงการจองตามสายรถและวันที่ พร้อมเรียงลำดับ
     */
    public List<Booking> getBookingsByRouteAndDateSorted(Long routeId, LocalDate date,
            String sortBy, String order) {
        List<Booking> bookings = bookingRepository.findByRouteIdAndDate(routeId, date);
        return sortBookings(bookings, sortBy, order);
    }

    /**
     * ดึงที่นั่งที่จองแล้วของเที่ยวรถ
     */
    public List<String> getBookedSeats(Long tripId) {
        return bookingRepository.findBookedSeatsByTripId(tripId);
    }

    /**
     * ดึงการจองจาก booking code
     */
    public Optional<Booking> getBookingByCode(String bookingCode) {
        return bookingRepository.findByBookingCode(bookingCode);
    }

    /**
     * ลบข้อมูลทั้งหมด
     */
    @Transactional
    public void deleteAll() {
        bookingRepository.deleteAll();
    }

    /**
     * ลบ bookings ก่อนวันที่กำหนด
     */
    @Transactional
    public int deleteBookingsBeforeDate(LocalDate date) {
        return bookingRepository.deleteByTripTripDateBefore(date);
    }

    /**
     * ดึงรายการจองตามสายรถและวันที่ (สำหรับคนขับ)
     */
    public List<Booking> getBookingsByRouteAndDate(Long routeId, LocalDate date) {
        return bookingRepository.findByRouteIdAndDate(routeId, date);
    }

    // ==================== PRIVATE HELPER METHODS ====================

    private BusTrip findTripOrThrow(Long tripId) throws Exception {
        return busTripRepository.findById(tripId)
                .orElseThrow(() -> new Exception("ไม่พบเที่ยวรถ"));
    }

    private User findUserOrThrow(String username) throws Exception {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new Exception("ไม่พบผู้ใช้"));
    }

    private Optional<User> findUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    private void validateSeatAvailable(BusTrip trip, String seatNumber) throws Exception {
        if (bookingRepository.existsByTripAndSeatNumberAndStatus(trip, seatNumber, STATUS_CONFIRMED)) {
            throw new Exception("ที่นั่ง " + seatNumber + " ถูกจองแล้ว");
        }
    }

    private void validateBookingOwner(Booking booking, String username) throws Exception {
        if (!booking.getUser().getUsername().equals(username)) {
            throw new Exception("คุณไม่มีสิทธิ์ยกเลิกการจองนี้");
        }
    }

    private void validateBookingNotCancelled(Booking booking) throws Exception {
        if (!STATUS_CONFIRMED.equals(booking.getStatus())) {
            throw new Exception("การจองนี้ถูกยกเลิกไปแล้ว");
        }
    }

    private Booking saveBooking(BusTrip trip, User user, String seatNumber) {
        Booking booking = new Booking();
        booking.setBookingCode(generateBookingCode());
        booking.setTrip(trip);
        booking.setUser(user);
        booking.setSeatNumber(seatNumber);
        booking.setStatus(STATUS_CONFIRMED);
        booking.setBookedAt(LocalDateTime.now());

        return bookingRepository.save(booking);
    }

    private String generateBookingCode() {
        return bookingRepository.findLastBookingCode()
                .map(lastCode -> {
                    int number = Integer.parseInt(lastCode.substring(1));
                    return String.format("%s%04d", BOOKING_CODE_PREFIX, number + 1);
                })
                .orElse(BOOKING_CODE_PREFIX + "0001");
    }
}
