package model;

public class GpsLocation {
    private double lat;
    private double lng;
    private String routeId;
    private String routeName;
    private String routeColor;

    public GpsLocation(double lat, double lng) {
        this(lat, lng, null, null, null);
    }

    public GpsLocation(double lat, double lng, String routeId, String routeName, String routeColor) {
        this.lat = lat;
        this.lng = lng;
        this.routeId = routeId;
        this.routeName = routeName;
        this.routeColor = routeColor;
    }

    public double getLat() {
        return lat;
    }

    public double getLng() {
        return lng;
    }

    public String getRouteId() {
        return routeId;
    }

    public String getRouteName() {
        return routeName;
    }

    public String getRouteColor() {
        return routeColor;
    }
}
