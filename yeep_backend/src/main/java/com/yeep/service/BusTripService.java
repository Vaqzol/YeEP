package com.yeep.service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yeep.entity.BusRoute;
import com.yeep.entity.BusTrip;
import com.yeep.repository.BookingRepository;
import com.yeep.repository.BusTripRepository;

@Service
public class BusTripService {
    
    @Autowired
    private BusTripRepository busTripRepository;
    
    @Autowired
    private BookingRepository bookingRepository;
    
    // ดึงเที่ยวรถตาม ID
    public Optional<BusTrip> getTripById(Long id) {
        return busTripRepository.findById(id);
    }
    
    // ดึงเที่ยวรถของสายและวันที่
    public List<BusTrip> getTripsByRouteAndDate(BusRoute route, LocalDate date) {
        return busTripRepository.findByRouteAndTripDateOrderByDepartureTime(route, date);
    }
    
    // ดึงเที่ยวรถพร้อมข้อมูลที่นั่งว่าง
    public List<TripWithAvailability> getTripsWithAvailability(Long routeId, LocalDate date) {
        List<BusTrip> trips = busTripRepository.findByRouteIdAndTripDate(routeId, date);
        List<TripWithAvailability> result = new ArrayList<>();
        
        for (BusTrip trip : trips) {
            int bookedSeats = bookingRepository.countBookedSeatsByTripId(trip.getId());
            int availableSeats = trip.getTotalSeats() - bookedSeats;
            result.add(new TripWithAvailability(trip, availableSeats, bookedSeats));
        }
        
        return result;
    }
    
    // สร้างเที่ยวรถสำหรับสายที่มีเที่ยว
    public void createTripsForRoute(BusRoute route, LocalDate date, List<TripTime> tripTimes) {
        int tripNumber = 1;
        for (TripTime time : tripTimes) {
            BusTrip trip = new BusTrip();
            trip.setRoute(route);
            trip.setTripNumber(tripNumber++);
            trip.setDepartureTime(time.departure);
            trip.setArrivalTime(time.arrival);
            trip.setTripDate(date);
            trip.setTotalSeats(20);
            busTripRepository.save(trip);
        }
    }
    
    // ลบข้อมูลทั้งหมด
    public void deleteAll() {
        busTripRepository.deleteAll();
    }
    
    // Inner class สำหรับข้อมูลเวลาเที่ยวรถ
    public static class TripTime {
        public LocalTime departure;
        public LocalTime arrival;
        
        public TripTime(LocalTime departure, LocalTime arrival) {
            this.departure = departure;
            this.arrival = arrival;
        }
    }
    
    // Inner class สำหรับเที่ยวรถพร้อมจำนวนที่นั่ง
    public static class TripWithAvailability {
        public BusTrip trip;
        public int availableSeats;
        public int bookedSeats;
        
        public TripWithAvailability(BusTrip trip, int availableSeats, int bookedSeats) {
            this.trip = trip;
            this.availableSeats = availableSeats;
            this.bookedSeats = bookedSeats;
        }
    }
}
