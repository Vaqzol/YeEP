import 'package:flutter/material.dart';
import '../main.dart';
import '../services/booking_service.dart';

class DriverBookingDetailScreen extends StatefulWidget {
  final String username;
  final int routeId;
  final String routeName;
  final String routeColor;
  final String origin;
  final String destination;

  const DriverBookingDetailScreen({
    super.key,
    required this.username,
    required this.routeId,
    required this.routeName,
    required this.routeColor,
    required this.origin,
    required this.destination,
  });

  @override
  State<DriverBookingDetailScreen> createState() =>
      _DriverBookingDetailScreenState();
}

class _DriverBookingDetailScreenState extends State<DriverBookingDetailScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);
    final dateStr =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final result = await BookingService.getBookingsByRoute(
      widget.routeId,
      dateStr,
    );
    setState(() {
      bookings = result;
      isLoading = false;
    });
  }

  Color _getRouteColor() {
    switch (widget.routeColor) {
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getShortRouteName() {
    String shortOrigin = widget.origin
        .replaceAll('หอพัก ', '')
        .replaceAll('อาคาร', '')
        .replaceAll('เรียนรวม 1', 'เรียนรวม');
    String shortDest = widget.destination
        .replaceAll('หอพัก ', '')
        .replaceAll('อาคาร', '')
        .replaceAll('เรียนรวม 1', 'เรียนรวม');
    return '$shortOrigin-$shortDest';
  }

  String _formatThaiDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year + 543}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      _loadBookings();
    }
  }

  // จัดกลุ่มรายการจองตามเที่ยว
  Map<String, List<Map<String, dynamic>>> _groupBookingsByTrip() {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var booking in bookings) {
      final trip = booking['trip'];
      if (trip != null) {
        final tripKey =
            '${trip['tripNumber'] ?? ''}_${trip['departureTime'] ?? ''}';
        if (!grouped.containsKey(tripKey)) {
          grouped[tripKey] = [];
        }
        grouped[tripKey]!.add(booking);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRouteColor();
    final groupedBookings = _groupBookingsByTrip();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [secondaryOrange, primaryOrange],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Back",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          widget.username.length > 8
                              ? '${widget.username.substring(0, 8)}...'
                              : widget.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 3, width: 25, color: Colors.white),
                        const SizedBox(height: 5),
                        Container(height: 3, width: 15, color: Colors.white),
                      ],
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "YeEP",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // White Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(30, 35, 30, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "รอบเที่ยว",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Route name
                      Text(
                        widget.routeName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      // Route path
                      Text(
                        _getShortRouteName(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Date selector
                      GestureDetector(
                        onTap: _selectDate,
                        child: Row(
                          children: [
                            Text(
                              'วันที่ ${_formatThaiDate(selectedDate)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bookings list
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : bookings.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 80,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'ไม่มีรายการจองในวันนี้',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadBookings,
                                child: ListView.builder(
                                  itemCount: bookings.length,
                                  itemBuilder: (context, index) {
                                    final booking = bookings[index];
                                    final trip = booking['trip'];
                                    final hasTrip =
                                        trip != null &&
                                        trip['tripNumber'] != null;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // แสดงเที่ยวที่ หรือ เวลา
                                                if (hasTrip)
                                                  Text(
                                                    'เที่ยวที่${trip['tripNumber']}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                else if (trip != null &&
                                                    trip['departureTime'] !=
                                                        null)
                                                  Text(
                                                    'เวลา ${trip['departureTime']} น.',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                // ที่นั่ง
                                                Text(
                                                  'ที่นั่ง:  ${booking['seatNumber'] ?? '-'}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // สถานะ
                                          Text(
                                            booking['status'] == 'confirmed'
                                                ? 'ยืนยันเสร็จสิ้น'
                                                : 'ยังไม่ยืนยัน',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  booking['status'] ==
                                                      'confirmed'
                                                  ? Colors.grey[600]
                                                  : Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
