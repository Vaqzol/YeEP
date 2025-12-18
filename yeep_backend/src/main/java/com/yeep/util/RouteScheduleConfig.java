package com.yeep.util;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

import com.yeep.service.BusTripService.TripTime;

/**
 * Configuration for bus route schedules (มทส. real data)
 * Replaces large switch statements with clean data structure
 */
public class RouteScheduleConfig {
    
    public enum RouteColor {
        GREEN, PURPLE, ORANGE, RED, YELLOW, BLUE
    }
    
    private static final Map<RouteColor, List<TripTime>> SCHEDULES = new EnumMap<>(RouteColor.class);
    
    static {
        initializeSchedules();
    }
    
    private RouteScheduleConfig() {} // Prevent instantiation
    
    private static void initializeSchedules() {
        // สายสีเขียว 07:07-09:30 ห่างกัน 7 นาที
        SCHEDULES.put(RouteColor.GREEN, List.of(
            new TripTime(LocalTime.of(7, 7), LocalTime.of(7, 27)),
            new TripTime(LocalTime.of(7, 14), LocalTime.of(7, 34)),
            new TripTime(LocalTime.of(7, 21), LocalTime.of(7, 41)),
            new TripTime(LocalTime.of(7, 28), LocalTime.of(7, 48)),
            new TripTime(LocalTime.of(7, 35), LocalTime.of(7, 55)),
            new TripTime(LocalTime.of(7, 42), LocalTime.of(8, 2)),
            new TripTime(LocalTime.of(7, 49), LocalTime.of(8, 9)),
            new TripTime(LocalTime.of(7, 56), LocalTime.of(8, 16)),
            new TripTime(LocalTime.of(8, 3), LocalTime.of(8, 23)),
            new TripTime(LocalTime.of(8, 10), LocalTime.of(8, 30)),
            new TripTime(LocalTime.of(9, 0), LocalTime.of(9, 20)),
            new TripTime(LocalTime.of(9, 30), LocalTime.of(9, 50))
        ));
        
        // สายสีม่วง 07:05-09:10 ห่างกัน 5 นาที
        SCHEDULES.put(RouteColor.PURPLE, List.of(
            new TripTime(LocalTime.of(7, 5), LocalTime.of(7, 20)),
            new TripTime(LocalTime.of(7, 10), LocalTime.of(7, 25)),
            new TripTime(LocalTime.of(7, 15), LocalTime.of(7, 30)),
            new TripTime(LocalTime.of(7, 20), LocalTime.of(7, 35)),
            new TripTime(LocalTime.of(7, 25), LocalTime.of(7, 40)),
            new TripTime(LocalTime.of(7, 30), LocalTime.of(7, 45)),
            new TripTime(LocalTime.of(7, 35), LocalTime.of(7, 50)),
            new TripTime(LocalTime.of(7, 40), LocalTime.of(7, 55)),
            new TripTime(LocalTime.of(7, 45), LocalTime.of(8, 0)),
            new TripTime(LocalTime.of(7, 50), LocalTime.of(8, 5)),
            new TripTime(LocalTime.of(8, 30), LocalTime.of(8, 45)),
            new TripTime(LocalTime.of(9, 0), LocalTime.of(9, 15))
        ));
        
        // สายสีส้ม 07:25-08:55 ห่างกัน 15 นาที
        SCHEDULES.put(RouteColor.ORANGE, List.of(
            new TripTime(LocalTime.of(7, 25), LocalTime.of(7, 35)),
            new TripTime(LocalTime.of(7, 40), LocalTime.of(7, 50)),
            new TripTime(LocalTime.of(7, 55), LocalTime.of(8, 5)),
            new TripTime(LocalTime.of(8, 10), LocalTime.of(8, 20)),
            new TripTime(LocalTime.of(8, 25), LocalTime.of(8, 35)),
            new TripTime(LocalTime.of(8, 40), LocalTime.of(8, 50)),
            new TripTime(LocalTime.of(8, 55), LocalTime.of(9, 5))
        ));
        
        // สายสีแดง 09:10-20:40 ห่างกัน 10-15 นาที
        SCHEDULES.put(RouteColor.RED, List.of(
            new TripTime(LocalTime.of(9, 10), LocalTime.of(10, 10)),
            new TripTime(LocalTime.of(10, 20), LocalTime.of(11, 20)),
            new TripTime(LocalTime.of(11, 30), LocalTime.of(12, 30)),
            new TripTime(LocalTime.of(12, 40), LocalTime.of(13, 40)),
            new TripTime(LocalTime.of(13, 50), LocalTime.of(14, 50)),
            new TripTime(LocalTime.of(15, 0), LocalTime.of(16, 0)),
            new TripTime(LocalTime.of(16, 10), LocalTime.of(17, 10)),
            new TripTime(LocalTime.of(17, 20), LocalTime.of(18, 20)),
            new TripTime(LocalTime.of(18, 30), LocalTime.of(19, 30)),
            new TripTime(LocalTime.of(19, 40), LocalTime.of(20, 40))
        ));
        
        // สายสีเหลือง 17:30-19:00 ห่างกัน 30 นาที
        SCHEDULES.put(RouteColor.YELLOW, List.of(
            new TripTime(LocalTime.of(17, 30), LocalTime.of(18, 0)),
            new TripTime(LocalTime.of(18, 0), LocalTime.of(18, 30)),
            new TripTime(LocalTime.of(18, 30), LocalTime.of(19, 0))
        ));
        
        // สายสีน้ำเงิน 3 รอบ: 08:30, 12:00, 16:30
        SCHEDULES.put(RouteColor.BLUE, List.of(
            new TripTime(LocalTime.of(8, 30), LocalTime.of(9, 0)),
            new TripTime(LocalTime.of(12, 0), LocalTime.of(12, 30)),
            new TripTime(LocalTime.of(16, 30), LocalTime.of(17, 0))
        ));
    }
    
    /**
     * Get trip times for a route color
     * @param colorString Color name string (e.g., "green", "purple")
     * @return List of TripTime, or empty list if color not found
     */
    public static List<TripTime> getTripTimes(String colorString) {
        if (colorString == null) {
            return new ArrayList<>();
        }
        
        try {
            RouteColor color = RouteColor.valueOf(colorString.toUpperCase());
            return SCHEDULES.getOrDefault(color, new ArrayList<>());
        } catch (IllegalArgumentException e) {
            return new ArrayList<>();
        }
    }
}
