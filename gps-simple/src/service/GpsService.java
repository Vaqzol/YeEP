package service;

import java.util.Map;

import model.GpsLocation;

public interface GpsService {
    void updateBus(String busId, GpsLocation location);
    GpsLocation getBus(String busId);
    Map<String, GpsLocation> getAllBus();
    void removeBus(String busId);
    void clearAll();
}
