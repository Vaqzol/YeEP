package com.yeep.entity;

import java.time.LocalDate;
import java.time.LocalTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * BusTrip Entity - สืบทอดจาก BaseEntity
 * ใช้หลักการ Inheritance เพื่อ reuse fields และ methods จาก parent class
 */
@Entity
@Table(name = "bus_trips")
public class BusTrip extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "route_id", nullable = false)
    private BusRoute route;

    @Column(name = "trip_number")
    private Integer tripNumber; // เที่ยวที่ 1, 2, 3... (null ถ้าไม่มีเที่ยว)

    @Column(name = "departure_time", nullable = false)
    private LocalTime departureTime; // เวลาออก

    @Column(name = "arrival_time")
    private LocalTime arrivalTime; // เวลาถึง

    @Column(name = "trip_date", nullable = false)
    private LocalDate tripDate; // วันที่

    @Column(name = "total_seats")
    private Integer totalSeats = 20; // จำนวนที่นั่งทั้งหมด (20 ที่: 1A-10A, 1B-10B)

    // Constructors
    public BusTrip() {
        super();
    }

    public BusTrip(BusRoute route, Integer tripNumber, LocalTime departureTime, LocalTime arrivalTime,
            LocalDate tripDate) {
        super();
        this.route = route;
        this.tripNumber = tripNumber;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.tripDate = tripDate;
        this.totalSeats = 20;
    }

    // Getters and Setters
    public BusRoute getRoute() {
        return route;
    }

    public void setRoute(BusRoute route) {
        this.route = route;
    }

    public Integer getTripNumber() {
        return tripNumber;
    }

    public void setTripNumber(Integer tripNumber) {
        this.tripNumber = tripNumber;
    }

    public LocalTime getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(LocalTime departureTime) {
        this.departureTime = departureTime;
    }

    public LocalTime getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(LocalTime arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public LocalDate getTripDate() {
        return tripDate;
    }

    public void setTripDate(LocalDate tripDate) {
        this.tripDate = tripDate;
    }

    public Integer getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(Integer totalSeats) {
        this.totalSeats = totalSeats;
    }
}
