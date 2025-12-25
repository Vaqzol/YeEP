package com.yeep.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

/**
 * BusRoute Entity - สืบทอดจาก BaseEntity
 * ใช้หลักการ Inheritance เพื่อ reuse fields และ methods จาก parent class
 */
@Entity
@Table(name = "bus_routes")
public class BusRoute extends BaseEntity {

    @Column(nullable = false)
    private String name; // สายสีม่วง, สายสีเขียว, etc.

    @Column(nullable = false)
    private String color; // purple, green, orange, red, blue, yellow

    @Column(nullable = false)
    private String origin; // ต้นทาง

    @Column(nullable = false)
    private String destination; // ปลายทาง

    @Column(name = "has_trips")
    private Boolean hasTrips; // true = มีเที่ยว, false = เลือกเวลา

    @Column(name = "time_range")
    private String timeRange; // เช่น "ออกทุก 5 นาที รอบละ 15 นาที"

    // Constructors
    public BusRoute() {
        super();
    }

    public BusRoute(String name, String color, String origin, String destination, Boolean hasTrips, String timeRange) {
        super();
        this.name = name;
        this.color = color;
        this.origin = origin;
        this.destination = destination;
        this.hasTrips = hasTrips;
        this.timeRange = timeRange;
    }

    // Getters and Setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public Boolean getHasTrips() {
        return hasTrips;
    }

    public void setHasTrips(Boolean hasTrips) {
        this.hasTrips = hasTrips;
    }

    public String getTimeRange() {
        return timeRange;
    }

    public void setTimeRange(String timeRange) {
        this.timeRange = timeRange;
    }
}
