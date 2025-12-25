package service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import model.GpsLocation;

public class DefaultGpsService implements GpsService {

    private final Map<String, GpsLocation> store = new ConcurrentHashMap<>();

    @Override
    public void updateBus(String busId, GpsLocation location) {
        store.put(busId, location);
        System.out.println("UPDATED BUS " + busId + " -> " +
                location.getLat() + "," + location.getLng());
    }

    @Override
    public GpsLocation getBus(String busId) {
        return store.get(busId);
    }

    @Override
    public Map<String, GpsLocation> getAllBus() {
        return store;
    }

    @Override
    public void removeBus(String busId) {
        store.remove(busId);
        System.out.println("REMOVED BUS " + busId);
    }

    @Override
    public void clearAll() {
        store.clear();
        System.out.println("CLEARED ALL BUS LOCATIONS");
    }
}
