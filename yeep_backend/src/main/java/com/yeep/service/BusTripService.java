package com.yeep.service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    // ลบ trips ก่อนวันที่กำหนด
    @Transactional
    public int deleteTripsBeforeDate(LocalDate date) {
        return busTripRepository.deleteByTripDateBefore(date);
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

    // ==================== DATA SORTING (Selection Sort #2) ====================
    /**
     * เรียงลำดับเที่ยวรถตามเวลาออก ด้วย Selection Sort Algorithm
     * 
     * Selection Sort Algorithm:
     * 1. หาค่าที่น้อยที่สุดในส่วนที่ยังไม่ได้เรียง
     * 2. สลับกับตำแหน่งแรกของส่วนที่ยังไม่ได้เรียง
     * 3. ทำซ้ำจนครบ
     * 
     * Time Complexity: O(n²)
     * Space Complexity: O(1)
     * 
     * @param trips     รายการเที่ยวรถ
     * @param ascending true = เรียงจากเช้าไปเย็น, false = เรียงจากเย็นไปเช้า
     * @return รายการเที่ยวรถที่เรียงลำดับแล้ว
     */
    public List<BusTrip> sortTripsByDepartureTime(List<BusTrip> trips, boolean ascending) {
        if (trips == null || trips.size() <= 1) {
            return trips;
        }

        // สร้าง copy เพื่อไม่แก้ไข list ต้นฉบับ
        List<BusTrip> result = new ArrayList<>(trips);
        int n = result.size();

        // Selection Sort Algorithm
        for (int i = 0; i < n - 1; i++) {
            int selectedIndex = i;

            for (int j = i + 1; j < n; j++) {
                LocalTime timeJ = result.get(j).getDepartureTime();
                LocalTime timeSelected = result.get(selectedIndex).getDepartureTime();

                boolean shouldSwap = ascending
                        ? timeJ.isBefore(timeSelected) // เรียงน้อยไปมาก
                        : timeJ.isAfter(timeSelected); // เรียงมากไปน้อย

                if (shouldSwap) {
                    selectedIndex = j;
                }
            }

            // สลับค่า (Swap)
            if (selectedIndex != i) {
                BusTrip temp = result.get(i);
                result.set(i, result.get(selectedIndex));
                result.set(selectedIndex, temp);
            }
        }

        return result;
    }

    // ==================== COMPOSITION EXAMPLE #1 ====================
    /**
     * TripSchedule - ตัวอย่าง Composition
     * 
     * Composition: TripSchedule "owns" TripTimeSlot objects
     * ถ้า TripSchedule ถูกลบ, TripTimeSlot ทั้งหมดจะถูกลบด้วย
     * 
     * ความแตกต่างจาก Aggregation:
     * - Composition: Part ไม่สามารถอยู่ได้โดยไม่มี Whole (TripTimeSlot ต้องมี
     * TripSchedule)
     * - Aggregation: Part สามารถอยู่ได้โดยไม่มี Whole (Booking อาจอยู่ได้โดยไม่มี
     * User)
     */
    public static class TripSchedule {
        private String scheduleName;
        private LocalDate date;
        // Composition: TripSchedule owns these TripTimeSlots
        private List<TripTimeSlot> timeSlots;

        public TripSchedule(String scheduleName, LocalDate date) {
            this.scheduleName = scheduleName;
            this.date = date;
            this.timeSlots = new ArrayList<>(); // Composition: สร้างพร้อมกับ parent
        }

        // เพิ่ม time slot ใหม่ (สร้างภายใน parent)
        public void addTimeSlot(LocalTime departure, LocalTime arrival, int capacity) {
            // Composition: TripTimeSlot ถูกสร้างและ owned โดย TripSchedule
            timeSlots.add(new TripTimeSlot(departure, arrival, capacity));
        }

        // ลบ time slot
        public void removeTimeSlot(int index) {
            if (index >= 0 && index < timeSlots.size()) {
                timeSlots.remove(index); // ลบ TripTimeSlot ออกจาก parent
            }
        }

        // ล้าง time slots ทั้งหมด (Composition: ลบ part ทั้งหมดเมื่อ whole ถูกทำลาย)
        public void clearAllTimeSlots() {
            timeSlots.clear();
        }

        public String getScheduleName() {
            return scheduleName;
        }

        public LocalDate getDate() {
            return date;
        }

        public List<TripTimeSlot> getTimeSlots() {
            return new ArrayList<>(timeSlots);
        }

        public int getTimeSlotsCount() {
            return timeSlots.size();
        }

        // Composition: Part class ที่ขึ้นอยู่กับ Whole
        public static class TripTimeSlot {
            private LocalTime departure;
            private LocalTime arrival;
            private int capacity;

            // Package-private constructor: สร้างได้เฉพาะจาก TripSchedule
            TripTimeSlot(LocalTime departure, LocalTime arrival, int capacity) {
                this.departure = departure;
                this.arrival = arrival;
                this.capacity = capacity;
            }

            public LocalTime getDeparture() {
                return departure;
            }

            public LocalTime getArrival() {
                return arrival;
            }

            public int getCapacity() {
                return capacity;
            }
        }
    }
}
