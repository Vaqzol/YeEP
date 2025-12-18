import 'package:flutter/material.dart';
import '../main.dart';
import '../services/booking_service.dart';
import '../utils/route_utils.dart';
import '../widgets/app_widgets.dart';
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

  void _showMenu(BuildContext context, Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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

  Future<void> _viewDetail(Map<String, dynamic> booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BookingDetailScreen(username: widget.username, booking: booking),
      ),
    );
    if (result == true) _loadBookings();
  }

  Future<void> _cancelBooking(Map<String, dynamic> booking) async {
    final confirm = await AppWidgets.showConfirmDialog(
      context: context,
      title: 'ยกเลิกการจอง',
      content: 'คุณต้องการยกเลิกการจองนี้หรือไม่?',
      confirmText: 'ยกเลิก',
    );

    if (confirm == true) {
      final result = await BookingService.cancelBooking(
        booking['id'],
        widget.username,
      );
      if (result['success'] == true) {
        AppWidgets.showSuccessSnackBar(context, 'ยกเลิกการจองสำเร็จ');
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
        decoration: AppWidgets.orangeGradientBackground,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppWidgets.buildHeader(
                context: context,
                username: widget.username,
              ),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
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
            const Text(
              "เสร็จสมบูรณ์",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(child: _buildBookingList()),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'ไม่มีประวัติการจอง',
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (_, index) => _BookingCard(
          booking: bookings[index],
          onTap: () => _viewDetail(bookings[index]),
          onMenuTap: () => _showMenu(context, bookings[index]),
        ),
      ),
    );
  }
}

/// Extracted booking card widget for better performance
class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final trip = booking['trip'] as Map<String, dynamic>;
    final colorName = trip['routeColor'] ?? '';
    final color = RouteUtils.getColor(colorName);
    final routeName = RouteUtils.getThaiRouteName(colorName);
    final isCancelled = booking['status'] == 'cancelled';
    final isConfirmed = booking['status'] == 'confirmed';

    return GestureDetector(
      onTap: onTap,
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
            // Header row
            Row(
              children: [
                _buildRouteBadge(routeName, isCancelled ? Colors.grey : color),
                const SizedBox(width: 10),
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
                GestureDetector(
                  onTap: onMenuTap,
                  child: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Trip info row
            Row(
              children: [
                Text(
                  trip['tripNumber'] != null
                      ? 'เที่ยวที่${trip['tripNumber']}'
                      : 'เวลา: ${trip['departureTime']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  trip['tripDate'] ?? '-',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Seat and status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                Text(
                  _getStatusText(isCancelled, isConfirmed),
                  style: TextStyle(
                    fontSize: 13,
                    color: _getStatusColor(isCancelled, isConfirmed),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteBadge(String routeName, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
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
    );
  }

  String _getStatusText(bool isCancelled, bool isConfirmed) {
    if (isCancelled) return 'ยกเลิกแล้ว';
    if (isConfirmed) return 'ยืนยันเสร็จสิ้น';
    return 'ยังไม่ยืนยัน';
  }

  Color _getStatusColor(bool isCancelled, bool isConfirmed) {
    if (isCancelled) return Colors.red;
    if (isConfirmed) return Colors.green;
    return Colors.orange;
  }
}
