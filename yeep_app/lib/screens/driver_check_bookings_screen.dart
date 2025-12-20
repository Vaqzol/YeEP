import 'package:flutter/material.dart';
import '../main.dart';
import '../services/booking_service.dart';
import 'driver_booking_detail_screen.dart';

class DriverCheckBookingsScreen extends StatefulWidget {
  final String username;

  const DriverCheckBookingsScreen({super.key, required this.username});

  @override
  State<DriverCheckBookingsScreen> createState() =>
      _DriverCheckBookingsScreenState();
}

class _DriverCheckBookingsScreenState extends State<DriverCheckBookingsScreen> {
  List<Map<String, dynamic>> routes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final result = await BookingService.getRoutes();
    setState(() {
      routes = result;
      isLoading = false;
    });
  }

  Color _getRouteColor(String colorName) {
    switch (colorName) {
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

  String _getThaiColorName(String colorName) {
    switch (colorName) {
      case 'purple':
        return 'สายสีม่วง';
      case 'green':
        return 'สายสีเขียว';
      case 'orange':
        return 'สายสีส้ม';
      case 'red':
        return 'สายสีแดง';
      case 'blue':
        return 'สายสีน้ำเงิน';
      case 'yellow':
        return 'สายสีเหลือง';
      default:
        return colorName;
    }
  }

  String _getShortRouteName(String? origin, String? destination) {
    if (origin == null || destination == null) return '';

    // ย่อชื่อให้สั้นลง
    String shortOrigin = origin
        .replaceAll('หอพัก ', '')
        .replaceAll('อาคาร', '')
        .replaceAll('เรียนรวม 1', 'เรียนรวม')
        .replaceAll('ขนส่ง', 'ขนส่ง');
    String shortDest = destination
        .replaceAll('หอพัก ', '')
        .replaceAll('อาคาร', '')
        .replaceAll('เรียนรวม 1', 'เรียนรวม')
        .replaceAll('ขนส่ง', 'ขนส่ง');

    return '$shortOrigin-$shortDest';
  }

  @override
  Widget build(BuildContext context) {
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
                        "ตรวจสอบรายการจอง",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Routes list
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: routes.length,
                                itemBuilder: (context, index) {
                                  final route = routes[index];
                                  final color = _getRouteColor(
                                    route['color'] ?? '',
                                  );

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DriverBookingDetailScreen(
                                                username: widget.username,
                                                routeId: route['id'],
                                                routeName: _getThaiColorName(
                                                  route['color'] ?? '',
                                                ),
                                                routeColor:
                                                    route['color'] ?? '',
                                                origin: route['origin'] ?? '',
                                                destination:
                                                    route['destination'] ?? '',
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getThaiColorName(
                                              route['color'] ?? '',
                                            ),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _getShortRouteName(
                                              route['origin'],
                                              route['destination'],
                                            ),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
