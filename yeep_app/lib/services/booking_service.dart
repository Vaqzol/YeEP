import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  static const String baseUrl = 'http://10.0.2.2:8081/api/booking';

  // ดึงสายรถทั้งหมด
  static Future<List<Map<String, dynamic>>> getRoutes() async {
    final response = await http.get(Uri.parse('$baseUrl/routes'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['routes']);
      }
    }
    return [];
  }

  // ดึงสายรถตาม ID
  static Future<Map<String, dynamic>?> getRouteById(int routeId) async {
    final response = await http.get(Uri.parse('$baseUrl/routes/$routeId'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success'] == true) {
        return data['route'];
      }
    }
    return null;
  }

  // ดึงเที่ยวรถของสายและวันที่
  static Future<List<Map<String, dynamic>>> getTrips(
    int routeId,
    String date,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips?routeId=$routeId&date=$date'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['trips']);
      }
    }
    return [];
  }

  // ดึงข้อมูลที่นั่งของเที่ยวรถ
  static Future<Map<String, dynamic>?> getTripSeats(int tripId) async {
    final response = await http.get(Uri.parse('$baseUrl/trips/$tripId/seats'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success'] == true) {
        return data;
      }
    }
    return null;
  }

  // จองที่นั่ง
  static Future<Map<String, dynamic>> bookSeats({
    required int tripId,
    required String username,
    required List<String> seatNumbers,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/book'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'tripId': tripId,
        'username': username,
        'seatNumbers': seatNumbers,
      }),
    );
    return json.decode(utf8.decode(response.bodyBytes));
  }

  // ยกเลิกการจอง
  static Future<Map<String, dynamic>> cancelBooking(
    int bookingId,
    String username,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/bookings/$bookingId?username=$username'),
    );
    return json.decode(utf8.decode(response.bodyBytes));
  }

  // ดึงการจองของ user
  static Future<List<Map<String, dynamic>>> getUserBookings(
    String username,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$username/bookings'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['bookings']);
      }
    }
    return [];
  }

  // ดึงประวัติการจองทั้งหมด
  static Future<List<Map<String, dynamic>>> getUserBookingHistory(
    String username,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$username/history'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['bookings']);
      }
    }
    return [];
  }
}
