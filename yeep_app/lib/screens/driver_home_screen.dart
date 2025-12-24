import 'package:flutter/material.dart';
import '../main.dart';
import 'login_screen.dart';
import 'driver_account_screen.dart';
import 'driver_check_bookings_screen.dart';
import '../services/tracking_service.dart';
import '../services/booking_service.dart';

class DriverHomeScreen extends StatefulWidget {
  final String username;

  const DriverHomeScreen({super.key, required this.username});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _showDropdown = false;
  bool _isTracking = false;
  String? _trackingError;
  List<Map<String, dynamic>> _routes = [];
  Map<String, dynamic>? _selectedRoute;

  void _toggleDropdown() {
    setState(() {
      _showDropdown = !_showDropdown;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goToAccount() {
    setState(() {
      _showDropdown = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverAccountScreen(username: widget.username),
      ),
    );
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
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  // Header with Back button and Profile
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            children: const [
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
                        // Profile section
                        GestureDetector(
                          onTap: _toggleDropdown,
                          child: Row(
                            children: [
                              Text(
                                widget.username.isNotEmpty
                                    ? (widget.username.length > 8
                                          ? '${widget.username.substring(0, 8)}...'
                                          : widget.username)
                                    : 'Driver',
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
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
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
                            Container(
                              height: 3,
                              width: 25,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 3,
                              width: 15,
                              color: Colors.white,
                            ),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "เมนูหลัก",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 50),
                            // 3 ปุ่มสี่เหลี่ยมโค้ง
                            _buildMenuButton(
                              icon: Icons.location_on,
                              label: _isTracking
                                  ? "หยุดแชร์ตำแหน่ง"
                                  : "แชร์ตำแหน่ง",
                              onTap: () async {
                                if (_isTracking) {
                                  try {
                                    await TrackingService.instance
                                        .stopTracking();
                                  } catch (e) {
                                    // ignore; stopTracking logs errors
                                  }
                                  setState(() {
                                    _isTracking = false;
                                    _trackingError = null;
                                    _selectedRoute = null;
                                  });
                                  return;
                                }

                                setState(() {
                                  _trackingError = null;
                                });

                                // Load routes from backend
                                try {
                                  _routes = await BookingService.getRoutes();
                                } catch (e) {
                                  _routes = [];
                                }

                                // Show dialog to pick a route and confirm
                                await showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    Map<String, String> colorMap = {
                                      'green': '#22c55e',
                                      'purple': '#8b5cf6',
                                      'orange': '#f97316',
                                      'red': '#FF4500',
                                      'blue': '#2563EB',
                                      'yellow': '#f59e0b',
                                    };

                                    return StatefulBuilder(
                                      builder: (context, setDialogState) {
                                        return AlertDialog(
                                          title: const Text(
                                            'เลือกสายรถเพื่อแชร์ตำแหน่ง',
                                          ),
                                          content: SizedBox(
                                            width: double.maxFinite,
                                            child: _routes.isEmpty
                                                ? const Text('ไม่พบสายรถ')
                                                : Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      DropdownButton<
                                                        Map<String, dynamic>
                                                      >(
                                                        isExpanded: true,
                                                        value: _selectedRoute,
                                                        hint: const Text(
                                                          'เลือกสายรถ',
                                                        ),
                                                        items: _routes.map((r) {
                                                          final hex =
                                                              colorMap[r['color']] ??
                                                              '#888888';
                                                          return DropdownMenuItem<
                                                            Map<String, dynamic>
                                                          >(
                                                            value: r,
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 12,
                                                                  height: 12,
                                                                  decoration: BoxDecoration(
                                                                    color: Color(
                                                                      int.parse(
                                                                        '0xff' +
                                                                            hex.replaceFirst(
                                                                              '#',
                                                                              '',
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          3,
                                                                        ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    r['name'] ??
                                                                        r['id']
                                                                            .toString(),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (v) {
                                                          setDialogState(() {
                                                            _selectedRoute = v;
                                                          });
                                                          // also update outer state to preserve selection
                                                          setState(() {
                                                            _selectedRoute = v;
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      const Text(
                                                        'ระบบจะส่งตำแหน่งของคุณไปยังเซิร์ฟเวอร์ทุก 5 วินาที\n\nคุณต้องอนุญาต Location และเปิด GPS',
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('ยกเลิก'),
                                            ),
                                            ElevatedButton(
                                              onPressed: _selectedRoute == null
                                                  ? null
                                                  : () async {
                                                      Navigator.pop(ctx);
                                                      setState(() {
                                                        _isTracking = true;
                                                      });
                                                      try {
                                                        final route =
                                                            _selectedRoute!;
                                                        await TrackingService
                                                            .instance
                                                            .startTracking(
                                                              busId: widget
                                                                  .username,
                                                              intervalSeconds:
                                                                  5,
                                                              routeId: route['id']
                                                                  .toString(),
                                                              routeName:
                                                                  route['name']
                                                                      ?.toString(),
                                                              routeColor:
                                                                  route['color']
                                                                      ?.toString(),
                                                            );
                                                      } catch (e) {
                                                        setState(() {
                                                          _isTracking = false;
                                                          _trackingError = e
                                                              .toString();
                                                        });
                                                      }
                                                    },
                                              child: const Text('เริ่มแชร์'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            if (_trackingError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _trackingError!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            const SizedBox(height: 20),
                            _buildMenuButton(
                              icon: Icons.list_alt,
                              label: "ตรวจสอบรายการจอง",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DriverCheckBookingsScreen(
                                      username: widget.username,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildMenuButton(
                              icon: Icons.qr_code,
                              label: "แชร์รหัส",
                              onTap: () {
                                // TODO: Implement share code
                              },
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Dropdown Menu
              if (_showDropdown)
                Positioned(
                  top: 70,
                  right: 20,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: _goToAccount,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: const Text(
                                "เกี่ยวกับบัญชี",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1, thickness: 1),
                          InkWell(
                            onTap: _logout,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: const Text(
                                "ออกจากระบบ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper สร้างปุ่มเมนู
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: primaryOrange,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
