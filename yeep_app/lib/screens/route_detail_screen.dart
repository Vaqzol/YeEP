import 'package:flutter/material.dart';
import '../main.dart';

// Model สำหรับข้อมูลสายรถ
class BusRoute {
  final String name;
  final Color color;
  final String destination;
  final String timeRange;
  final String?
  subtitle; // เช่น "ออกทุก 5 นาที รอบละ 15 นาที" หรือ "ระยะทาง 16 กม."
  final String displayType; // 'trips', 'grid', 'twoColumn', 'singleColumn'
  final List<TripSchedule>? trips; // สำหรับแบบ trips
  final List<List<String>>? gridData; // สำหรับแบบ grid
  final List<String>? columnData; // สำหรับแบบ single/two column

  BusRoute({
    required this.name,
    required this.color,
    required this.destination,
    required this.timeRange,
    this.subtitle,
    required this.displayType,
    this.trips,
    this.gridData,
    this.columnData,
  });
}

class TripSchedule {
  final int tripNumber;
  final List<String> times;

  TripSchedule({required this.tripNumber, required this.times});
}

// ข้อมูลสายรถทั้งหมด
class BusRouteData {
  static BusRoute purpleLine = BusRoute(
    name: "สายสีม่วง",
    color: Colors.purple,
    destination: "หอพักหญิง-เรียนรวม",
    timeRange: "ออกทุก 5 นาที รอบละ 15 นาที",
    displayType: 'trips',
    trips: [
      TripSchedule(tripNumber: 1, times: ["07:05", "07:10", "07:15", "07:20"]),
      TripSchedule(tripNumber: 2, times: ["07:25", "07:30", "07:35", "07:40"]),
      TripSchedule(tripNumber: 3, times: ["07:45", "07:50", "07:55", "08:00"]),
      TripSchedule(tripNumber: 4, times: ["08:05", "08:10", "08:15", "08:20"]),
      TripSchedule(tripNumber: 5, times: ["08:25", "08:30", "08:35", "08:40"]),
    ],
  );

  static BusRoute greenLine = BusRoute(
    name: "สายสีเขียว",
    color: Colors.green,
    destination: "หอพักชาย-เรียนรวม",
    timeRange: "ออกทุก 7 นาที รอบละ 21 นาที",
    displayType: 'trips',
    trips: [
      TripSchedule(
        tripNumber: 1,
        times: ["07:07", "07:14", "07:21", "07:28", "07:35"],
      ),
      TripSchedule(
        tripNumber: 2,
        times: ["07:42", "07:49", "07:56", "08:03", "08:10"],
      ),
      TripSchedule(
        tripNumber: 3,
        times: ["08:17", "08:24", "08:31", "08:38", "08:45"],
      ),
    ],
  );

  static BusRoute orangeLine = BusRoute(
    name: "สายสีส้ม",
    color: primaryOrange,
    destination: "เรียนรวม-ขนส่ง",
    timeRange: "เวลา 07:10 น. ถึง 08:37 น.",
    displayType: 'tripsTwo',
    trips: [
      TripSchedule(tripNumber: 1, times: ["07:10", "07:20"]),
      TripSchedule(tripNumber: 2, times: ["07:30", "07:40"]),
      TripSchedule(tripNumber: 3, times: ["07:50", "08:00"]),
      TripSchedule(tripNumber: 4, times: ["08:10", "08:20"]),
    ],
  );

  static BusRoute redLine = BusRoute(
    name: "สายสีแดง",
    color: Colors.red,
    destination: "หอพักชาย-หอพักหญิง",
    timeRange: "เวลา 09:00 น. ถึง 21:00 น.",
    subtitle: "ระยะทาง 16 กม.",
    displayType: 'grid',
    gridData: [
      ["08:45", "10:40", "12:30", "14:20", "16:10", "18:00"],
      ["09:00", "10:50", "12:40", "14:30", "16:20", "18:10"],
      ["09:10", "11:00", "12:50", "14:40", "16:30", "18:20"],
      ["09:20", "11:10", "13:00", "14:50", "16:40", "18:30"],
      ["09:30", "11:20", "13:10", "15:00", "16:50", "18:40"],
      ["09:40", "11:30", "13:20", "15:10", "17:00", "18:50"],
      ["09:50", "11:40", "13:30", "15:20", "17:10", "19:00"],
      ["10:00", "11:50", "13:40", "15:30", "17:20", "19:10"],
      ["10:10", "12:00", "13:50", "15:40", "17:30", "19:20"],
      ["10:20", "12:10", "14:00", "15:50", "17:40", "20:10"],
      ["10:30", "12:20", "14:10", "16:00", "17:50", "20:40"],
    ],
  );

  static BusRoute blueLine = BusRoute(
    name: "สายสีน้ำเงิน",
    color: Colors.blue,
    destination: "โรงพยาบาล",
    timeRange: "เวลา 07:00 น. ถึง 18:00 น.",
    displayType: 'twoColumn',
    columnData: [
      "07:00",
      "13:30",
      "08:00",
      "15:00",
      "09:00",
      "16:00",
      "10:30",
      "17:00",
      "12:00",
      "18:00",
    ],
  );

  static BusRoute yellowLine = BusRoute(
    name: "สายสีเหลือง",
    color: Colors.amber,
    destination: "ตลาดหน้ามอ",
    timeRange: "เวลา 18:30 น. ถึง 20:00 น.",
    displayType: 'singleColumn',
    columnData: ["18:30", "19:00", "19:30", "20:00"],
  );
}

class RouteDetailScreen extends StatelessWidget {
  final String username;
  final BusRoute route;

  const RouteDetailScreen({
    super.key,
    required this.username,
    required this.route,
  });

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
                          username.isNotEmpty
                              ? (username.length > 8
                                    ? '${username.substring(0, 8)}...'
                                    : username)
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
                        "ตารางเดินรถ",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        route.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: route.color,
                        ),
                      ),
                      Text(
                        route.destination,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        route.timeRange,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (route.subtitle != null) ...[
                        Text(
                          route.subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Content based on display type
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: _buildContent(),
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

  Widget _buildContent() {
    switch (route.displayType) {
      case 'trips':
        return _buildTripsView();
      case 'tripsTwo':
        return _buildTripsTwoView();
      case 'grid':
        return _buildGridView();
      case 'twoColumn':
        return _buildTwoColumnView();
      case 'singleColumn':
        return _buildSingleColumnView();
      default:
        return const SizedBox();
    }
  }

  // แบบเที่ยว - หลายเวลา (สายสีม่วง, สายสีเขียว)
  Widget _buildTripsView() {
    return Column(
      children: [
        ...route.trips!.map((trip) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: primaryOrange.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "เที่ยวที่ ${trip.tripNumber}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "เวลา  ",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    ...trip.times.map(
                      (time) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 30), // เพิ่ม padding ด้านล่าง
      ],
    );
  }

  // แบบเที่ยว - 2 เวลา (สายสีส้ม)
  Widget _buildTripsTwoView() {
    return Column(
      children: route.trips!.map((trip) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryOrange.withOpacity(0.5), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "เที่ยวที่ ${trip.tripNumber}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "เวลา",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    trip.times[0],
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(width: 80),
                  Text(
                    trip.times[1],
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // แบบตาราง Grid (สายสีแดง)
  Widget _buildGridView() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: primaryOrange.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        border: TableBorder.all(
          color: primaryOrange.withOpacity(0.3),
          width: 1,
        ),
        children: route.gridData!.map((row) {
          return TableRow(
            children: row.map((time) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 5,
                ),
                child: Text(
                  time,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  // แบบ 2 คอลัมน์ (สายสีน้ำเงิน)
  Widget _buildTwoColumnView() {
    List<List<String>> rows = [];
    for (int i = 0; i < route.columnData!.length; i += 2) {
      rows.add([
        route.columnData![i],
        i + 1 < route.columnData!.length ? route.columnData![i + 1] : "",
      ]);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: primaryOrange.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        border: TableBorder.all(
          color: primaryOrange.withOpacity(0.3),
          width: 1,
        ),
        children: rows.map((row) {
          return TableRow(
            children: row.map((time) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                child: Text(
                  time,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  // แบบ 1 คอลัมน์ (สายสีเหลือง)
  Widget _buildSingleColumnView() {
    return Center(
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          border: Border.all(color: primaryOrange.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: route.columnData!.asMap().entries.map((entry) {
            int idx = entry.key;
            String time = entry.value;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: idx < route.columnData!.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: primaryOrange.withOpacity(0.3),
                          width: 1,
                        ),
                      )
                    : null,
              ),
              child: Text(
                time,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
