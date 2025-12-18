package com.yeep.dto;

/**
 * DTO for booking response
 */
public class BookingResponse {
    private Long id;
    private String bookingCode;
    private String seatNumber;
    private String status;
    private String bookedAt;
    private String cancelledAt;
    private TripResponse trip;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getBookingCode() { return bookingCode; }
    public void setBookingCode(String bookingCode) { this.bookingCode = bookingCode; }

    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getBookedAt() { return bookedAt; }
    public void setBookedAt(String bookedAt) { this.bookedAt = bookedAt; }

    public String getCancelledAt() { return cancelledAt; }
    public void setCancelledAt(String cancelledAt) { this.cancelledAt = cancelledAt; }

    public TripResponse getTrip() { return trip; }
    public void setTrip(TripResponse trip) { this.trip = trip; }
}
