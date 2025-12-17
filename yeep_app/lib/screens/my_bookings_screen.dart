import 'package:flutter/material.dart';
import '../main.dart';
import '../services/booking_service.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final String username;

  const MyBookingsScreen({super.key, required this.username});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);
    final result = await BookingService.getUserBookings(widget.username);
    setState(() {
      bookings = result;
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

  String _getRouteName(String colorName) {
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

  void _showMenu(BuildContext context, Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text('ดูรายละเอียด'),
              onTap: () {
                Navigator.pop(ctx);
                _viewDetail(booking);
              },
            ),
            if (booking['status'] != 'cancelled')
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('ยกเลิกการจอง'),
                onTap: () {
                  Navigator.pop(ctx);
                  _cancelBooking(booking);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _viewDetail(Map<String, dynamic> booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(
          username: widget.username,
          booking: booking,
        ),
      ),
    );
    if (result == true) {
      _loadBookings();
    }
  }

  Future<void> _cancelBooking(Map<String, dynamic> booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('ยกเลิกการจอง'),
        content: const Text('คุณต้องการยกเลิกการจองนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ไม่'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await BookingService.cancelBooking(
        booking['id'],
        widget.username,
      );
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยกเลิกการจองสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookings();
      }
    }
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
                          Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
                          child: const Icon(Icons.person, color: Colors.grey, size: 24),
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
                        "ประวัติการจอง",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Section header
                      const Text(
                        "เสร็จสมบูรณ์",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Booking list
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : bookings.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.history,
                                          size: 80,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'ไม่มีประวัติการจอง',
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
                                        return _buildBookingCard(booking);
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

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final trip = booking['trip'] as Map<String, dynamic>;
    final color = _getRouteColor(trip['routeColor'] ?? '');
    final routeName = _getRouteName(trip['routeColor'] ?? '');
    final isCancelled = booking['status'] == 'cancelled';
    final isConfirmed = booking['status'] == 'confirmed';

    return GestureDetector(
      onTap: () => _viewDetail(booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: primaryOrange.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Badge + Route + Menu
            Row(
              children: [
                // Route badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCancelled ? Colors.grey : color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    routeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Route path
                Expanded(
                  child: Text(
                    '${trip['origin']} - ${trip['destination']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Menu icon
                GestureDetector(
                  onTap: () => _showMenu(context, booking),
                  child: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Trip info row
            Row(
              children: [
                // เที่ยวที่ หรือ เวลา
                if (trip['tripNumber'] != null)
                  Text(
                    'เที่ยวที่${trip['tripNumber']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    'เวลา: ${trip['departureTime']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(width: 15),
                // วันที่
                Text(
                  trip['tripDate'] ?? '-',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Seat and status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ที่นั่ง
                Row(
                  children: [
                    const Text(
                      'ที่นั่ง: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      booking['seatNumber'] ?? '-',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                // สถานะ
                Text(
                  isCancelled
                      ? 'ยกเลิกแล้ว'
                      : isConfirmed
                          ? 'ยืนยันเสร็จสิ้น'
                          : 'ยังไม่ยืนยัน',
                  style: TextStyle(
                    fontSize: 13,
                    color: isCancelled
                        ? Colors.red
                        : isConfirmed
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
