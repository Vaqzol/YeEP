package com.yeep.dto;

/**
 * DTO for seat information
 */
public class SeatResponse {
    private String seatNumber;
    private boolean isBooked;

    public SeatResponse() {}

    public SeatResponse(String seatNumber, boolean isBooked) {
        this.seatNumber = seatNumber;
        this.isBooked = isBooked;
    }

    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }

    public boolean isBooked() { return isBooked; }
    public void setBooked(boolean booked) { isBooked = booked; }
}
