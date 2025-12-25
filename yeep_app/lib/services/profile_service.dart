import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ProfileService - บริการจัดการรูปโปรไฟล์
/// ใช้สำหรับแชร์รูปโปรไฟล์ข้ามหน้าจอ
class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();
  
  File? _profileImage;
  String? _currentUsername;
  
  File? get profileImage => _profileImage;
  String? get currentUsername => _currentUsername;
  
  /// โหลดรูปโปรไฟล์จาก SharedPreferences
  Future<void> loadProfileImage(String username) async {
    _currentUsername = username;
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_$username');
    
    if (savedPath != null && File(savedPath).existsSync()) {
      _profileImage = File(savedPath);
    } else {
      _profileImage = null;
    }
    notifyListeners();
  }
  
  /// อัพเดทรูปโปรไฟล์
  void updateProfileImage(File? image) {
    _profileImage = image;
    notifyListeners();
  }
  
  /// ลบรูปโปรไฟล์
  void clearProfileImage() {
    _profileImage = null;
    notifyListeners();
  }
  
  /// ดึงรูปโปรไฟล์แบบ static (สำหรับใช้ใน widget ที่ไม่ใช้ ChangeNotifier)
  static Future<File?> getProfileImageStatic(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_$username');
    
    if (savedPath != null && File(savedPath).existsSync()) {
      return File(savedPath);
    }
    return null;
  }
}
