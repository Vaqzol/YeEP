package server;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.InetSocketAddress;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import model.GpsLocation;
import service.GpsService;

public class GpsHttpServer {

    private final HttpServer server;
    private final GpsService service;

    public GpsHttpServer(int port, GpsService service) throws IOException {
        this.service = service;
        // สร้าง Server
        server = HttpServer.create(new InetSocketAddress(port), 0);

        // กำหนด Route (URL)
        server.createContext("/", this::handleStatic);
        server.createContext("/send-gps", this::handleSendGps);
        server.createContext("/gps", this::handleGetGps);     // ดึงทีละคัน
        server.createContext("/all-gps", this::handleGetAllGps); // ดึงทุกคัน (สำหรับเพื่อน)
        server.createContext("/clear-gps", this::handleClearGps); // ล้างข้อมูล GPS (optional bus param)
    }

    public void start() {
        server.start();
        System.out.println("✅ API Server started at port " + server.getAddress().getPort());
        System.out.println("   - Single Bus API: /gps?bus=1");
        System.out.println("   - All Buses API:  /all-gps");
    }

    // ================= API: ล้างข้อมูล GPS (GET) =================
    // /clear-gps -> clear all
    // /clear-gps?bus=driver1 -> remove that bus only
    private void handleClearGps(HttpExchange ex) throws IOException {
        addCorsHeaders(ex);
        if (ex.getRequestMethod().equalsIgnoreCase("OPTIONS")) {
            ex.sendResponseHeaders(204, -1);
            return;
        }

        Map<String, String> q = parse(ex.getRequestURI().getQuery());
        String bus = q.get("bus");
        if (bus != null && !bus.isEmpty()) {
            service.removeBus(bus);
            byte[] out = ("Removed " + bus).getBytes(StandardCharsets.UTF_8);
            ex.getResponseHeaders().add("Content-Type", "text/plain; charset=utf-8");
            ex.sendResponseHeaders(200, out.length);
            ex.getResponseBody().write(out);
            ex.close();
            return;
        }

        // clear all
        service.clearAll();
        byte[] out = "OK".getBytes(StandardCharsets.UTF_8);
        ex.getResponseHeaders().add("Content-Type", "text/plain; charset=utf-8");
        ex.sendResponseHeaders(200, out.length);
        ex.getResponseBody().write(out);
        ex.close();
    }

    // ================= HELPER: เพิ่ม CORS Header =================
    // สำคัญมาก! ต้องใส่เพื่อให้เว็บเพื่อนดึงข้อมูลข้ามเครื่องได้
    private void addCorsHeaders(HttpExchange ex) {
        ex.getResponseHeaders().add("Access-Control-Allow-Origin", "*"); // อนุญาตทุกเว็บ
        ex.getResponseHeaders().add("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        ex.getResponseHeaders().add("Access-Control-Allow-Headers", "Content-Type");
    }

    // ================= STATIC FILES =================
    private void handleStatic(HttpExchange ex) throws IOException {
        String path = ex.getRequestURI().getPath();
        if (path.equals("/")) path = "/map.html";

        File file = new File(System.getProperty("user.dir") + "/src/web" + path);
        if (!file.exists() || file.isDirectory()) {
            ex.sendResponseHeaders(404, -1);
            return;
        }

        String mime = "text/html";
        if(path.endsWith(".css")) mime = "text/css";
        else if(path.endsWith(".js")) mime = "application/javascript";
        // serve static files with UTF-8 charset for text types
        String contentType = mime;
        if (mime.startsWith("text") || mime.equals("application/javascript")) {
            contentType = mime + "; charset=utf-8";
        }
        ex.getResponseHeaders().add("Content-Type", contentType);
        byte[] data = Files.readAllBytes(file.toPath());
        ex.sendResponseHeaders(200, data.length);
        ex.getResponseBody().write(data);
        ex.close();
    }

    // ================= API: ส่ง GPS เข้ามา (POST) =================
    private void handleSendGps(HttpExchange ex) throws IOException {
        addCorsHeaders(ex); // ใส่ CORS
        if (ex.getRequestMethod().equalsIgnoreCase("OPTIONS")) {
            ex.sendResponseHeaders(204, -1);
            return;
        }

        if (!ex.getRequestMethod().equalsIgnoreCase("POST")) {
            ex.sendResponseHeaders(405, -1);
            return;
        }

        String body = new String(ex.getRequestBody().readAllBytes());
        Map<String, String> data = parse(body);

        String bus = data.get("bus");
        if(bus != null) {
            double lat = Double.parseDouble(data.get("lat"));
            double lng = Double.parseDouble(data.get("lng"));
            String routeId = data.get("routeId");
            String routeName = data.get("routeName");
            String routeColor = data.get("routeColor");
            service.updateBus(bus, new GpsLocation(lat, lng, routeId, routeName, routeColor));
        }

        byte[] res = "OK".getBytes();
        ex.sendResponseHeaders(200, res.length);
        ex.getResponseBody().write(res);
        ex.close();
    }

    // ================= API: ดึง GPS คันเดียว (GET) =================
    private void handleGetGps(HttpExchange ex) throws IOException {
        addCorsHeaders(ex); // ใส่ CORS

        Map<String, String> q = parse(ex.getRequestURI().getQuery());
        String bus = q.get("bus");

        GpsLocation loc = service.getBus(bus);
        if (loc == null) loc = new GpsLocation(0, 0);

        String json = String.format("{\"lat\":%f,\"lng\":%f}", loc.getLat(), loc.getLng());

        byte[] out = json.getBytes(StandardCharsets.UTF_8);
        ex.getResponseHeaders().add("Content-Type", "application/json; charset=utf-8");
        ex.sendResponseHeaders(200, out.length);
        ex.getResponseBody().write(out);
        ex.close();
    }

    // ================= API: ดึง GPS ทุกคัน (GET) =================
    // เพื่อนคุณน่าจะชอบอันนี้ที่สุด
    private void handleGetAllGps(HttpExchange ex) throws IOException {
        addCorsHeaders(ex); // ใส่ CORS

        Map<String, GpsLocation> all = service.getAllBus();

        // สร้าง JSON String: {"1": {"lat":..., "lng":...}, "2": ...}
        StringBuilder json = new StringBuilder("{");
        int i = 0;
        for (Map.Entry<String, GpsLocation> entry : all.entrySet()) {
            if (i > 0) json.append(",");
            json.append("\"").append(entry.getKey()).append("\":");
                // include optional route metadata if present
                GpsLocation loc = entry.getValue();
                String routePart = "";
                if (loc.getRouteName() != null) {
                routePart = String.format(",\"routeName\":\"%s\",\"routeColor\":\"%s\",\"routeId\":\"%s\"",
                    escape(loc.getRouteName()), escape(loc.getRouteColor()), escape(loc.getRouteId()));
                }

                // derive displayName from busId: if username pattern driverN -> BusN, else use busId
                String displayName = keyToDisplayName(entry.getKey());
                String displayPart = String.format(",\"displayName\":\"%s\"", escape(displayName));

                json.append(String.format("{\"lat\":%f,\"lng\":%f%s%s}",
                    loc.getLat(), loc.getLng(), routePart, displayPart));
            i++;
        }
        json.append("}");

        byte[] out = json.toString().getBytes(StandardCharsets.UTF_8);
        ex.getResponseHeaders().add("Content-Type", "application/json; charset=utf-8");
        ex.sendResponseHeaders(200, out.length);
        ex.getResponseBody().write(out);
        ex.close();
    }

    private Map<String, String> parse(String q) throws UnsupportedEncodingException {
        Map<String, String> map = new HashMap<>();
        if (q == null) return map;
        for (String s : q.split("&")) {
            String[] p = s.split("=");
            if (p.length == 2) {
                map.put(URLDecoder.decode(p[0], "UTF-8"), URLDecoder.decode(p[1], "UTF-8"));
            }
        }
        return map;
    }

    // simple JSON string escaper for route names
    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    // derive a friendly display name for a bus/user id
    private String keyToDisplayName(String key) {
        if (key == null) return "";
        // simple mapping: replace prefix 'driver' with 'Bus' if present
        String lower = key.toLowerCase();
        if (lower.startsWith("driver")) {
            String suffix = key.substring(6); // keep original case for suffix
            if (!suffix.isEmpty()) return "Bus" + suffix;
            return "Bus";
        }
        return key;
    }
}