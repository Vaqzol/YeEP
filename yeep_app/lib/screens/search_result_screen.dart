import 'package:flutter/material.dart';
import '../main.dart';
import '../services/booking_service.dart';
import 'select_seat_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final String username;
  final String origin;
  final String destination;
  final Map<String, dynamic> route;

  const SearchResultScreen({
    super.key,
    required this.username,
    required this.origin,
    required this.destination,
    required this.route,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> trips = [];
  bool isLoading = true;
  String? selectedTime; // สำหรับสายไม่มีเที่ยว

  // เวลาสำหรับสายไม่มีเที่ยว
  List<String> availableTimes = [];

  @override
  void initState() {
    super.initState();
    if (widget.route['hasTrips'] == true) {
      _loadTrips();
    } else {
      _generateAvailableTimes();
      setState(() => isLoading = false);
    }
  }

  void _generateAvailableTimes() {
    // สร้างเวลาจาก timeRange เช่น "06:00 - 21:00"
    final timeRange = widget.route['timeRange'] as String? ?? "07:00 - 18:00";
    final parts = timeRange.split(' - ');
    if (parts.length == 2) {
      final startParts = parts[0].split(':');
      final endParts = parts[1].split(':');

      int startHour = int.tryParse(startParts[0]) ?? 7;
      int endHour = int.tryParse(endParts[0]) ?? 18;

      availableTimes = [];
      for (int h = startHour; h <= endHour; h++) {
        availableTimes.add('${h.toString().padLeft(2, '0')}:00');
        if (h < endHour) {
          availableTimes.add('${h.toString().padLeft(2, '0')}:30');
        }
      }
    }
  }

  Future<void> _loadTrips() async {
    setState(() => isLoading = true);
    final dateStr =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final result = await BookingService.getTrips(widget.route['id'], dateStr);
    setState(() {
      trips = result;
      isLoading = false;
    });
  }

  Color _getRouteColor() {
    switch (widget.route['color']) {
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
      lastDate: DateTime.now().add(const Duration(days: 1)), // เลือกได้แค่วันนี้กับพรุ่งนี้
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      if (widget.route['hasTrips'] == true) {
        _loadTrips();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRouteColor();
    final hasTrips = widget.route['hasTrips'] == true;

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
                          widget.username.isNotEmpty
                              ? (widget.username.length > 8
                                    ? '${widget.username.substring(0, 8)}...'
                                    : widget.username)
                              : 'User',
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
                        "เลือกรอบรถ",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "จาก: ${widget.origin} > ถึง: ${widget.destination}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 15),
                      // Date selector
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                ': วัน/เดือน/ปี',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Content based on hasTrips
                      if (hasTrips)
                        _buildTripsView(color)
                      else
                        _buildTimeSelectionView(color),
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

  // แบบมีเที่ยว (รูปที่ 3)
  Widget _buildTripsView(Color color) {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (trips.isEmpty) {
      return Expanded(
        child: Center(
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
                style: TextStyle(fontSize: 18, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          final available = trip['availableSeats'] as int;
          final isFull = available == 0;

          return GestureDetector(
            onTap: isFull
                ? null
                : () {
                    // ไปหน้าเลือกที่นั่ง
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectSeatScreen(
                          username: widget.username,
                          tripId: trip['id'],
                          routeName: widget.route['name'],
                          routeColor: widget.route['color'],
                          origin: widget.origin,
                          destination: widget.destination,
                          departureTime: trip['departureTime'],
                          arrivalTime: trip['arrivalTime'],
                          tripDate:
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                      ),
                    );
                  },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isFull ? Colors.grey[100] : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isFull
                      ? Colors.grey[300]!
                      : primaryOrange.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // เวลา
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['departureTime'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'ถึง ${trip['arrivalTime']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // เที่ยวที่ + ที่นั่ง
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            'เที่ยวที่ ${trip['tripNumber']} ',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '(${widget.route['name']})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Badge ที่นั่ง
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isFull ? Colors.grey[400] : color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isFull ? 'เต็ม' : 'เหลือ $available ที่',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // แบบไม่มีเที่ยว - เลือกเวลา (รูปที่ 4)
  Widget _buildTimeSelectionView(Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.route['name'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 15),
          // Dropdown เลือกเวลา
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('เลือกเวลา:', style: TextStyle(fontSize: 16)),
                      Icon(Icons.arrow_drop_down, color: color),
                    ],
                  ),
                ),
                // Time options
                ...availableTimes.take(5).map((time) {
                  final isSelected = selectedTime == time;
                  return InkWell(
                    onTap: () {
                      setState(() => selectedTime = time);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.1) : null,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? color : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Spacer(),
          // ปุ่มค้นหาที่นั่ง
          Center(
            child: SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: selectedTime == null
                    ? null
                    : () {
                        // ไปหน้าเลือกที่นั่ง
                        // สำหรับสายไม่มีเที่ยว จะสร้าง trip จำลอง
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectSeatScreen(
                              tripId:
                                  widget.route['id'] * 1000, // ใช้ route id แทน
                              routeName: widget.route['name'],
                              routeColor: widget.route['color'],
                              departureTime: selectedTime!,
                              arrivalTime: _calculateArrivalTime(selectedTime!),
                              tripDate:
                                  '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                              origin: widget.origin,
                              destination: widget.destination,
                              username: widget.username,
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.search),
                label: const Text("ค้นหาที่นั่ง"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _calculateArrivalTime(String departure) {
    final parts = departure.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]) + 30;
    if (minute >= 60) {
      hour += 1;
      minute -= 60;
    }
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
