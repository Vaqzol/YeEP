package com.yeep.util;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import com.yeep.dto.BookingResponse;
import com.yeep.dto.SeatResponse;
import com.yeep.dto.TripResponse;
import com.yeep.entity.Booking;
import com.yeep.entity.BusRoute;
import com.yeep.entity.BusTrip;
import com.yeep.service.BusTripService.TripWithAvailability;

/**
 * Utility class for converting entities to DTOs
 * Eliminates code duplication in controllers
 */
public class EntityMapper {
    
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");
    private static final int TOTAL_ROWS = 10;
    private static final String[] SEAT_COLUMNS = {"A", "B"};
    
    private EntityMapper() {} // Prevent instantiation
    
    /**
     * Convert BusTrip entity to TripResponse DTO
     */
    public static TripResponse toTripResponse(BusTrip trip) {
        if (trip == null) return null;
        
        TripResponse response = new TripResponse();
        response.setId(trip.getId());
        response.setTripNumber(trip.getTripNumber());
        response.setDepartureTime(trip.getDepartureTime().format(TIME_FORMATTER));
        response.setArrivalTime(trip.getArrivalTime().format(TIME_FORMATTER));
        response.setTripDate(trip.getTripDate().toString());
        response.setTotalSeats(trip.getTotalSeats());
        
        // Add route info if available
        BusRoute route = trip.getRoute();
        if (route != null) {
            response.setRouteName(route.getName());
            response.setRouteColor(route.getColor());
            response.setOrigin(route.getOrigin());
            response.setDestination(route.getDestination());
        }
        
        return response;
    }
    
    /**
     * Convert TripWithAvailability to TripResponse DTO
     */
    public static TripResponse toTripResponse(TripWithAvailability twa) {
        TripResponse response = toTripResponse(twa.trip);
        response.setAvailableSeats(twa.availableSeats);
        response.setBookedSeats(twa.bookedSeats);
        return response;
    }
    
    /**
     * Convert list of TripWithAvailability to list of TripResponse
     */
    public static List<TripResponse> toTripResponseList(List<TripWithAvailability> trips) {
        return trips.stream()
                .map(EntityMapper::toTripResponse)
                .toList();
    }
    
    /**
     * Convert Booking entity to BookingResponse DTO (simple)
     */
    public static BookingResponse toBookingResponse(Booking booking) {
        if (booking == null) return null;
        
        BookingResponse response = new BookingResponse();
        response.setId(booking.getId());
        response.setBookingCode(booking.getBookingCode());
        response.setSeatNumber(booking.getSeatNumber());
        response.setStatus(booking.getStatus());
        response.setBookedAt(booking.getBookedAt().toString());
        
        if (booking.getCancelledAt() != null) {
            response.setCancelledAt(booking.getCancelledAt().toString());
        }
        
        return response;
    }
    
    /**
     * Convert Booking entity to BookingResponse DTO (with trip info)
     */
    public static BookingResponse toBookingResponseWithTrip(Booking booking) {
        BookingResponse response = toBookingResponse(booking);
        if (response != null && booking.getTrip() != null) {
            response.setTrip(toTripResponse(booking.getTrip()));
        }
        return response;
    }
    
    /**
     * Convert list of Bookings to list of BookingResponse (simple)
     */
    public static List<BookingResponse> toBookingResponseList(List<Booking> bookings) {
        return bookings.stream()
                .map(EntityMapper::toBookingResponse)
                .toList();
    }
    
    /**
     * Convert list of Bookings to list of BookingResponse (with trip info)
     */
    public static List<BookingResponse> toBookingResponseListWithTrips(List<Booking> bookings) {
        return bookings.stream()
                .map(EntityMapper::toBookingResponseWithTrip)
                .toList();
    }
    
    /**
     * Generate all seat responses for a trip
     * @param bookedSeats List of already booked seat numbers
     * @return List of SeatResponse for all seats (20 seats: 1A-10B)
     */
    public static List<SeatResponse> generateSeatResponses(List<String> bookedSeats) {
        List<SeatResponse> seats = new ArrayList<>();
        
        for (int row = 1; row <= TOTAL_ROWS; row++) {
            for (String col : SEAT_COLUMNS) {
                String seatNumber = row + col;
                boolean isBooked = bookedSeats.contains(seatNumber);
                seats.add(new SeatResponse(seatNumber, isBooked));
            }
        }
        
        return seats;
    }
}
