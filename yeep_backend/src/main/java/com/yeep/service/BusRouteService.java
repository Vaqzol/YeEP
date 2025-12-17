package com.yeep.service;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yeep.entity.BusRoute;
import com.yeep.repository.BusRouteRepository;

@Service
public class BusRouteService {
    
    @Autowired
    private BusRouteRepository busRouteRepository;
    
    // ดึงสายรถทั้งหมด
    public List<BusRoute> getAllRoutes() {
        return busRouteRepository.findAll();
    }
    
    // ดึงสายรถตาม ID
    public Optional<BusRoute> getRouteById(Long id) {
        return busRouteRepository.findById(id);
    }
    
    // ค้นหาสายรถตามต้นทาง-ปลายทาง
    public List<BusRoute> searchRoutes(String origin, String destination) {
        if (origin != null && destination != null) {
            Optional<BusRoute> route = busRouteRepository.findByOriginAndDestination(origin, destination);
            return route.map(List::of).orElse(List.of());
        } else if (origin != null) {
            return busRouteRepository.findByOrigin(origin);
        } else if (destination != null) {
            return busRouteRepository.findByDestination(destination);
        }
        return busRouteRepository.findAll();
    }
    
    // ดึงรายการสถานที่ทั้งหมด (ไม่ซ้ำ)
    public List<String> getAllLocations() {
        List<BusRoute> routes = busRouteRepository.findAll();
        return routes.stream()
                .flatMap(route -> Arrays.asList(route.getOrigin(), route.getDestination()).stream())
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }
    
    // สร้างข้อมูลเริ่มต้น (ข้อมูลจริง มทส.)
    public void initializeRoutes() {
        if (busRouteRepository.count() == 0) {
            // สายสีเขียว - หอพัก S16-S18 → อาคารเรียนรวม 1
            BusRoute green = new BusRoute();
            green.setName("สายสีเขียว");
            green.setColor("green");
            green.setOrigin("หอพัก S16-S18");
            green.setDestination("อาคารเรียนรวม 1");
            green.setHasTrips(true);
            green.setTimeRange("07:07 - 09:30");
            busRouteRepository.save(green);
            
            // สายสีม่วง - หอพัก S4 → อาคารเรียนรวม 1
            BusRoute purple = new BusRoute();
            purple.setName("สายสีม่วง");
            purple.setColor("purple");
            purple.setOrigin("หอพัก S4");
            purple.setDestination("อาคารเรียนรวม 1");
            purple.setHasTrips(true);
            purple.setTimeRange("07:05 - 09:10");
            busRouteRepository.save(purple);
            
            // สายสีส้ม - อาคารเรียนรวม 1 → อาคารขนส่ง
            BusRoute orange = new BusRoute();
            orange.setName("สายสีส้ม");
            orange.setColor("orange");
            orange.setOrigin("อาคารเรียนรวม 1");
            orange.setDestination("อาคารขนส่ง");
            orange.setHasTrips(true);
            orange.setTimeRange("07:25 - 08:55");
            busRouteRepository.save(orange);
            
            // สายสีแดง - อาคารขนส่ง → หอพัก S16-S18
            BusRoute red = new BusRoute();
            red.setName("สายสีแดง");
            red.setColor("red");
            red.setOrigin("อาคารขนส่ง");
            red.setDestination("หอพัก S16-S18");
            red.setHasTrips(true);
            red.setTimeRange("09:10 - 20:40");
            busRouteRepository.save(red);
            
            // สายสีเหลือง - หอพัก S13 → ตลาดหน้า ม.
            BusRoute yellow = new BusRoute();
            yellow.setName("สายสีเหลือง");
            yellow.setColor("yellow");
            yellow.setOrigin("หอพัก S13");
            yellow.setDestination("ตลาดหน้า ม.");
            yellow.setHasTrips(true);
            yellow.setTimeRange("17:30 - 19:00");
            busRouteRepository.save(yellow);
            
            // สายสีน้ำเงิน - อาคารขนส่ง → โรงพยาบาล มทส. (3 รอบ)
            BusRoute blue = new BusRoute();
            blue.setName("สายสีน้ำเงิน");
            blue.setColor("blue");
            blue.setOrigin("อาคารขนส่ง");
            blue.setDestination("โรงพยาบาล มทส.");
            blue.setHasTrips(true);
            blue.setTimeRange("08:30, 12:00, 16:30");
            busRouteRepository.save(blue);
        }
    }
    
    // ลบข้อมูลทั้งหมด
    public void deleteAll() {
        busRouteRepository.deleteAll();
    }
}
