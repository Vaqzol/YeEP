import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/booking_service.dart';
import 'booking_confirm_screen.dart';

class SelectSeatScreen extends StatefulWidget {
  final int tripId;
  final String routeName;
  final String routeColor;
  final String departureTime;
  final String arrivalTime;
  final String tripDate;
  final String origin;
  final String destination;
  final String username;

  const SelectSeatScreen({
    super.key,
    required this.tripId,
    required this.routeName,
    required this.routeColor,
    required this.departureTime,
    required this.arrivalTime,
    required this.tripDate,
    required this.origin,
    required this.destination,
    required this.username,
  });

  @override
  State<SelectSeatScreen> createState() => _SelectSeatScreenState();
}

class _SelectSeatScreenState extends State<SelectSeatScreen> {
  List<Map<String, dynamic>> seats = [];
  List<String> selectedSeats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    final data = await BookingService.getTripSeats(widget.tripId);
    if (data != null) {
      setState(() {
        seats = List<Map<String, dynamic>>.from(data['seats']);
        isLoading = false;
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

  void _toggleSeat(String seatNumber, bool isBooked) {
    if (isBooked) return;

    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }
    });
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
          'เลือกที่นั่ง',
          style: GoogleFonts.prompt(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Trip info header
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.departureTime} - ${widget.arrivalTime}',
                        style: GoogleFonts.prompt(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.tripDate,
                        style: GoogleFonts.prompt(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Legend
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegend(Colors.grey[300]!, 'ว่าง'),
                      _buildLegend(color, 'เลือก'),
                      _buildLegend(Colors.red[300]!, 'จองแล้ว'),
                    ],
                  ),
                ),

                // Bus layout
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        // Driver area
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.airline_seat_recline_extra,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'คนขับ',
                                style: GoogleFonts.prompt(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        // Seats grid
                        Expanded(
                          child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: (context, row) {
                              final seatA = '${row + 1}A';
                              final seatB = '${row + 1}B';
                              final seatAData = seats.firstWhere(
                                (s) => s['seatNumber'] == seatA,
                                orElse: () => {
                                  'seatNumber': seatA,
                                  'booked': false,
                                },
                              );
                              final seatBData = seats.firstWhere(
                                (s) => s['seatNumber'] == seatB,
                                orElse: () => {
                                  'seatNumber': seatB,
                                  'booked': false,
                                },
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Seat A (left)
                                    _buildSeat(
                                      seatA,
                                      seatAData['booked'] as bool,
                                      color,
                                    ),
                                    // Aisle
                                    Container(
                                      width: 40,
                                      child: Text(
                                        '${row + 1}',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.prompt(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    // Seat B (right)
                                    _buildSeat(
                                      seatB,
                                      seatBData['booked'] as bool,
                                      color,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Selected seats info and confirm button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (selectedSeats.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              'ที่นั่งที่เลือก: ',
                              style: GoogleFonts.prompt(fontSize: 16),
                            ),
                            Expanded(
                              child: Text(
                                selectedSeats.join(', '),
                                style: GoogleFonts.prompt(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: selectedSeats.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookingConfirmScreen(
                                            tripId: widget.tripId,
                                            routeName: widget.routeName,
                                            routeColor: widget.routeColor,
                                            departureTime: widget.departureTime,
                                            arrivalTime: widget.arrivalTime,
                                            tripDate: widget.tripDate,
                                            origin: widget.origin,
                                            destination: widget.destination,
                                            selectedSeats: selectedSeats,
                                            username: widget.username,
                                          ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            selectedSeats.isEmpty
                                ? 'กรุณาเลือกที่นั่ง'
                                : 'ยืนยัน (${selectedSeats.length} ที่นั่ง)',
                            style: GoogleFonts.prompt(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.prompt()),
      ],
    );
  }

  Widget _buildSeat(String seatNumber, bool isBooked, Color selectedColor) {
    final isSelected = selectedSeats.contains(seatNumber);

    Color bgColor;
    Color textColor;

    if (isBooked) {
      bgColor = Colors.red[300]!;
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = selectedColor;
      textColor = Colors.white;
    } else {
      bgColor = Colors.grey[300]!;
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: () => _toggleSeat(seatNumber, isBooked),
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: selectedColor.withOpacity(0.5), width: 3)
              : null,
        ),
        child: Center(
          child: Text(
            seatNumber,
            style: GoogleFonts.prompt(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
