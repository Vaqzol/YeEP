package com.yeep.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "bookings")
public class Booking {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
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
        this.bookedAt = LocalDateTime.now();
        this.status = "confirmed";
    }
    
    public Booking(String bookingCode, BusTrip trip, User user, String seatNumber) {
        this.bookingCode = bookingCode;
        this.trip = trip;
        this.user = user;
        this.seatNumber = seatNumber;
        this.status = "confirmed";
        this.bookedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getBookingCode() { return bookingCode; }
    public void setBookingCode(String bookingCode) { this.bookingCode = bookingCode; }
    
    public BusTrip getTrip() { return trip; }
    public void setTrip(BusTrip trip) { this.trip = trip; }
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public LocalDateTime getBookedAt() { return bookedAt; }
    public void setBookedAt(LocalDateTime bookedAt) { this.bookedAt = bookedAt; }
    
    public LocalDateTime getCancelledAt() { return cancelledAt; }
    public void setCancelledAt(LocalDateTime cancelledAt) { this.cancelledAt = cancelledAt; }
}
