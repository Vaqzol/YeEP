import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

/// TrackingService: ให้ไดรเวอร์ส่งตำแหน่งแบบ periodical ไปยัง gps-simple
/// วิธีใช้ (ตัวอย่าง):
///   await TrackingService.instance.startTracking(busId: '1', intervalSeconds: 5);
///   ...
///   TrackingService.instance.stopTracking();
class TrackingService {
  TrackingService._private();
  static final TrackingService instance = TrackingService._private();

  Timer? _timer;
  String? _busId;
  String? _routeId;
  String? _routeName;
  String? _routeColor;

  /// เริ่มส่งตำแหน่งทุก [intervalSeconds]
  Future<void> startTracking({
    required String busId,
    int intervalSeconds = 5,
    String? routeId,
    String? routeName,
    String? routeColor,
  }) async {
    _busId = busId;
    _routeId = routeId;
    _routeName = routeName;
    _routeColor = routeColor;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Please enable it in app settings.',
      );
    }

    // Cancel previous timer if any
    stopTracking();

    // Immediately send once, then schedule periodic
    await _sendOnce();

    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      await _sendOnce();
    });
  }

  /// หยุดส่งตำแหน่ง
  void stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendOnce() async {
    if (_busId == null) return;
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final lat = pos.latitude;
      final lng = pos.longitude;
      await _postGps(busId: _busId!, lat: lat, lng: lng);
    } catch (e) {
      // ไม่ throw เพื่อไม่ให้ timer หยุด — เก็บ log ใน console
      print('TrackingService: send error: $e');
    }
  }

  Future<void> _postGps({
    required String busId,
    required double lat,
    required double lng,
  }) async {
    // อ่าน GPS server จาก .env หากมี (เช่น GPS_SERVER=http://192.168.x.x:8090)
    final gpsHost = dotenv.env['GPS_SERVER'] ?? 'http://10.0.2.2:8090';
    final uri = Uri.parse('$gpsHost/send-gps');

    try {
      final body = {'bus': busId, 'lat': lat.toString(), 'lng': lng.toString()};
      if (_routeId != null) body['routeId'] = _routeId!;
      if (_routeName != null) body['routeName'] = _routeName!;
      if (_routeColor != null) body['routeColor'] = _routeColor!;

      final resp = await http
          .post(uri, body: body)
          .timeout(const Duration(seconds: 5));

      if (resp.statusCode != 200) {
        print('TrackingService: server returned ${resp.statusCode}');
      }
    } catch (e) {
      print('TrackingService: post error: $e');
    }
  }
}
