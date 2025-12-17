package com.yeep.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.yeep.entity.BusRoute;

@Repository
public interface BusRouteRepository extends JpaRepository<BusRoute, Long> {
    
    // หาสายรถจากต้นทาง-ปลายทาง
    Optional<BusRoute> findByOriginAndDestination(String origin, String destination);
    
    // หาสายรถจากต้นทาง (สำหรับกรณีปลายทางเป็น any)
    List<BusRoute> findByOrigin(String origin);
    
    // หาสายรถจากปลายทาง (สำหรับกรณีต้นทางเป็น any)
    List<BusRoute> findByDestination(String destination);
    
    // หาสายรถจากชื่อ
    Optional<BusRoute> findByName(String name);
    
    // ค้นหาแบบยืดหยุ่น
    @Query("SELECT r FROM BusRoute r WHERE " +
           "(r.origin = :origin OR :origin IS NULL) AND " +
           "(r.destination = :destination OR :destination IS NULL)")
    List<BusRoute> searchRoutes(@Param("origin") String origin, @Param("destination") String destination);
}
