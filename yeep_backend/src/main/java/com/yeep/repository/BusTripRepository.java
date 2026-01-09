package com.yeep.repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.yeep.entity.BusRoute;
import com.yeep.entity.BusTrip;

@Repository
public interface BusTripRepository extends JpaRepository<BusTrip, Long> {

    // หาเที่ยวรถจากสายรถและวันที่ (พร้อม ORDER BY - สำหรับใช้งานทั่วไป)
    List<BusTrip> findByRouteAndTripDateOrderByDepartureTime(BusRoute route, LocalDate tripDate);

    // หาเที่ยวรถจากสายรถและวันที่ (ไม่มี ORDER BY - สำหรับ Selection Sort)
    List<BusTrip> findByRouteAndTripDate(BusRoute route, LocalDate tripDate);

    // หาเที่ยวรถจาก route id และวันที่ (ไม่มี ORDER BY - สำหรับ Selection Sort)
    @Query("SELECT t FROM BusTrip t WHERE t.route.id = :routeId AND t.tripDate = :tripDate")
    List<BusTrip> findByRouteIdAndTripDate(@Param("routeId") Long routeId, @Param("tripDate") LocalDate tripDate);

    // หาเที่ยวรถจาก route id
    List<BusTrip> findByRouteIdOrderByDepartureTime(Long routeId);

    // ลบเที่ยวรถก่อนวันที่กำหนด
    int deleteByTripDateBefore(LocalDate date);
}
