import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BusMapScreen extends StatefulWidget {
  const BusMapScreen({super.key});

  @override
  State<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends State<BusMapScreen> {
  Map<String, Marker> _busMarkers = {};
  Timer? _timer;
  static final LatLng _center = LatLng(14.8800, 102.0250); // SUT

  @override
  void initState() {
    super.initState();
    _fetchAndUpdate();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchAndUpdate(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAndUpdate() async {
    final gpsHost = dotenv.env['GPS_SERVER'] ?? 'http://10.0.2.2:8090';
    final url = Uri.parse('$gpsHost/all-gps');
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final newMarkers = <String, Marker>{};
        data.forEach((busId, loc) {
          final lat = (loc['lat'] as num?)?.toDouble() ?? 0.0;
          final lng = (loc['lng'] as num?)?.toDouble() ?? 0.0;
          if (lat == 0 && lng == 0) return;
          newMarkers[busId] = Marker(
            markerId: MarkerId(busId),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: 'BUS $busId'),
            icon: BitmapDescriptor.defaultMarkerWithHue(_getHue(busId)),
          );
        });
        setState(() {
          _busMarkers = newMarkers;
        });
      }
    } catch (e) {
      // ignore error, just don't update
    }
  }

  double _getHue(String busId) {
    // ตัวอย่าง: 1-3 แดง, 4-6 น้ำเงิน, อื่นๆ เขียว
    if (["1", "2", "3"].contains(busId)) return BitmapDescriptor.hueRed;
    if (["4", "5", "6"].contains(busId)) return BitmapDescriptor.hueBlue;
    return BitmapDescriptor.hueGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แผนที่รถโดยสาร')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _center, zoom: 14),
        markers: Set<Marker>.of(_busMarkers.values),
        onMapCreated: (_) {},
      ),
    );
  }
}
