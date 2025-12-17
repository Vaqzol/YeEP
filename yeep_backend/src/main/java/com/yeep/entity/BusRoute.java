package com.yeep.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "bus_routes")
public class BusRoute {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
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
    public BusRoute() {}
    
    public BusRoute(String name, String color, String origin, String destination, Boolean hasTrips, String timeRange) {
        this.name = name;
        this.color = color;
        this.origin = origin;
        this.destination = destination;
        this.hasTrips = hasTrips;
        this.timeRange = timeRange;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }
    
    public String getOrigin() { return origin; }
    public void setOrigin(String origin) { this.origin = origin; }
    
    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }
    
    public Boolean getHasTrips() { return hasTrips; }
    public void setHasTrips(Boolean hasTrips) { this.hasTrips = hasTrips; }
    
    public String getTimeRange() { return timeRange; }
    public void setTimeRange(String timeRange) { this.timeRange = timeRange; }
}
