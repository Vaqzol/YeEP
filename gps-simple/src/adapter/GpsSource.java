package adapter;

import model.GpsLocation;
import java.util.Map;

public interface GpsSource {
    void update(String busId, GpsLocation location);
    GpsLocation get(String busId);
    Map<String, GpsLocation> getAll();
}
