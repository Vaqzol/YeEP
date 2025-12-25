import service.DefaultGpsService;
import service.GpsService;
import server.GpsHttpServer;

public class Main {
    public static void main(String[] args) throws Exception {
        GpsService service = new DefaultGpsService();
        GpsHttpServer server = new GpsHttpServer(8090, service);
        server.start();

        System.out.println("Server running on http://localhost:8090");
    }
}
