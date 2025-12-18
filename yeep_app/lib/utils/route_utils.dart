import 'package:flutter/material.dart';

/// Utility class for bus route-related helper methods
class RouteUtils {
  // Map for route colors - more efficient than switch statement
  static const Map<String, Color> _colorMap = {
    'purple': Colors.purple,
    'green': Colors.green,
    'orange': Colors.orange,
    'red': Colors.red,
    'blue': Colors.blue,
    'yellow': Colors.amber,
  };

  // Map for Thai color names
  static const Map<String, String> _thaiColorNames = {
    'purple': 'สีม่วง',
    'green': 'สีเขียว',
    'orange': 'สีส้ม',
    'red': 'สีแดง',
    'blue': 'สีน้ำเงิน',
    'yellow': 'สีเหลือง',
  };

  // Map for Thai route names
  static const Map<String, String> _thaiRouteNames = {
    'purple': 'สายสีม่วง',
    'green': 'สายสีเขียว',
    'orange': 'สายสีส้ม',
    'red': 'สายสีแดง',
    'blue': 'สายสีน้ำเงิน',
    'yellow': 'สายสีเหลือง',
  };

  /// Get Color from color name string
  static Color getColor(String? colorName) {
    return _colorMap[colorName] ?? Colors.grey;
  }

  /// Get Thai color name (e.g., "สีเขียว")
  static String getThaiColorName(String? colorName) {
    return _thaiColorNames[colorName] ?? colorName ?? '';
  }

  /// Get Thai route name (e.g., "สายสีเขียว")
  static String getThaiRouteName(String? colorName) {
    return _thaiRouteNames[colorName] ?? colorName ?? '';
  }

  /// Truncate username for display
  static String formatUsername(String username, {int maxLength = 8}) {
    if (username.isEmpty) return 'User';
    if (username.length > maxLength) {
      return '${username.substring(0, maxLength)}...';
    }
    return username;
  }
}
