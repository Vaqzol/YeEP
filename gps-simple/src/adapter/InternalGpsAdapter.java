package adapter;

import model.GpsLocation;
import java.util.HashMap;
import java.util.Map;

public class InternalGpsAdapter implements GpsSource {

    private final Map<String, GpsLocation> store = new HashMap<>();

    @Override
    public void update(String busId, GpsLocation location) {
        store.put(busId, location);
    }

    @Override
    public GpsLocation get(String busId) {
        return store.getOrDefault(busId, new GpsLocation(0, 0));
    }

    @Override
    public Map<String, GpsLocation> getAll() {
        return store;
    }
}
