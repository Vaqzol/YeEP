import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../utils/route_utils.dart';
import '../widgets/app_widgets.dart';
import 'home_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final String username;
  final Map<String, dynamic> booking;

  const BookingDetailScreen({
    super.key,
    required this.username,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final trip = booking['trip'] as Map<String, dynamic>;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppWidgets.orangeGradientBackground,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppWidgets.buildHeader(context: context, username: username),
              AppWidgets.buildWhiteCard(
                child: SingleChildScrollView(
                  child: _buildBookingContent(context, trip),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingContent(BuildContext context, Map<String, dynamic> trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ข้อมูลการจอง",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),

        // วันที่ และ รอบ
        Row(
          children: [
            Expanded(
              child: _buildInfoItem("วันที่ :", trip['tripDate'] ?? '-'),
            ),
            Expanded(
              child: _buildInfoItem(
                "รอบ :",
                "เที่ยวที่ ${trip['tripNumber'] ?? 1}",
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // จาก > ถึง
        _buildInfoItem(
          "จาก:",
          "${trip['origin'] ?? '-'} > ถึง: ${trip['destination'] ?? '-'}",
        ),
        const SizedBox(height: 20),

        // สาย และ ที่นั่ง
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                "สาย :",
                RouteUtils.getThaiColorName(trip['routeColor']),
              ),
            ),
            Expanded(
              child: _buildInfoItem("ที่นั่ง :", booking['seatNumber'] ?? '-'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ชื่อผู้จอง และ วันที่จอง
        Row(
          children: [
            Expanded(child: _buildLabelValue("ชื่อผู้จอง", username)),
            Expanded(
              child: _buildLabelValue(
                "วันที่จอง",
                booking['bookingDate'] ?? trip['tripDate'] ?? '-',
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),

        // เลขที่การจอง
        const Text(
          "เลขที่การจอง",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          booking['bookingCode'] ?? '-',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 40),

        // Buttons
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Flexible(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _goHome(context),
                style: AppWidgets.primaryButtonStyle(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "กลับสู่หน้าหลัก",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _cancelBooking(context),
                style: AppWidgets.primaryButtonStyle(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  "ยกเลิกการจอง",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: 140,
          child: ElevatedButton(
            onPressed: () =>
                AppWidgets.showSuccessSnackBar(context, 'ดาวน์โหลดสำเร็จ'),
            style: AppWidgets.primaryButtonStyle(backgroundColor: Colors.green),
            child: const Text(
              "ดาวน์โหลด",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
      (route) => false,
    );
  }

  Future<void> _cancelBooking(BuildContext context) async {
    final confirm = await AppWidgets.showConfirmDialog(
      context: context,
      title: 'ยกเลิกการจอง',
      content: 'คุณต้องการยกเลิกการจองนี้หรือไม่?',
      confirmText: 'ยกเลิก',
    );

    if (confirm == true) {
      final result = await BookingService.cancelBooking(
        booking['id'],
        username,
      );
      if (result['success'] == true) {
        AppWidgets.showSuccessSnackBar(context, 'ยกเลิกการจองสำเร็จ');
        Navigator.pop(context, true);
      } else {
        AppWidgets.showErrorSnackBar(
          context,
          result['message'] ?? 'เกิดข้อผิดพลาด',
        );
      }
    }
  }
}
