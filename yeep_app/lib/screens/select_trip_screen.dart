import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/booking_service.dart';
import 'select_seat_screen.dart';

class SelectTripScreen extends StatefulWidget {
  final int routeId;
  final String routeName;
  final String routeColor;
  final String origin;
  final String destination;
  final String username;

  const SelectTripScreen({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.routeColor,
    required this.origin,
    required this.destination,
    required this.username,
  });

  @override
  State<SelectTripScreen> createState() => _SelectTripScreenState();
}

class _SelectTripScreenState extends State<SelectTripScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> trips = [];
  bool isLoading = true;

  // ตัวเลือกการเรียงลำดับ
  String _sortBy = 'time'; // 'time' หรือ 'seats'

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => isLoading = true);
    final dateStr =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final result = await BookingService.getTrips(widget.routeId, dateStr);
    setState(() {
      trips = result;
      _sortTrips(); // เรียงลำดับหลังโหลด
      isLoading = false;
    });
  }

  // ฟังก์ชันเรียงลำดับข้อมูล
  void _sortTrips() {
    if (_sortBy == 'time') {
      // เรียงตามเวลา (ค่าเริ่มต้น)
      trips.sort(
        (a, b) => (a['departureTime'] as String).compareTo(
          b['departureTime'] as String,
        ),
      );
    } else if (_sortBy == 'seats') {
      // เรียงตามที่นั่งว่างมากไปน้อย
      trips.sort(
        (a, b) =>
            (b['availableSeats'] as int).compareTo(a['availableSeats'] as int),
      );
    }
  }

  // เปลี่ยนการเรียงลำดับ
  void _changeSortOrder(String? value) {
    if (value != null && value != _sortBy) {
      setState(() {
        _sortBy = value;
        _sortTrips();
      });
    }
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 1),
      ), // เลือกได้แค่วันนี้กับพรุ่งนี้
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      _loadTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRouteColor();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(
          'เลือกเที่ยวรถ',
          style: GoogleFonts.prompt(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Route info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.routeName,
                  style: GoogleFonts.prompt(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.origin,
                        style: GoogleFonts.prompt(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_downward,
                  color: Colors.white54,
                  size: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flag, color: Colors.white70, size: 18),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.destination,
                        style: GoogleFonts.prompt(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date picker
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: color, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: GoogleFonts.prompt(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Sort dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      icon: Icon(Icons.sort, color: color),
                      style: GoogleFonts.prompt(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      onChanged: _changeSortOrder,
                      items: [
                        DropdownMenuItem(
                          value: 'time',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text('เวลา', style: GoogleFonts.prompt()),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'seats',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event_seat,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text('ที่นั่งว่าง', style: GoogleFonts.prompt()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trips list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : trips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ไม่มีเที่ยวรถในวันที่เลือก',
                          style: GoogleFonts.prompt(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      final available = trip['availableSeats'] as int;
                      final isFull = available == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${trip['tripNumber']}',
                                style: GoogleFonts.prompt(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            '${trip['departureTime']} - ${trip['arrivalTime']}',
                            style: GoogleFonts.prompt(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(
                                isFull ? Icons.event_busy : Icons.event_seat,
                                size: 16,
                                color: isFull ? Colors.red : Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isFull ? 'เต็ม' : 'ว่าง $available ที่นั่ง',
                                style: GoogleFonts.prompt(
                                  color: isFull ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: isFull
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SelectSeatScreen(
                                          tripId: trip['id'],
                                          routeName: widget.routeName,
                                          routeColor: widget.routeColor,
                                          departureTime: trip['departureTime'],
                                          arrivalTime: trip['arrivalTime'],
                                          tripDate: trip['tripDate'],
                                          origin: widget.origin,
                                          destination: widget.destination,
                                          username: widget.username,
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('เลือก', style: GoogleFonts.prompt()),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
