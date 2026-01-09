import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/api_service.dart';

/// AccountScreen - หน้าจอบัญชีผู้ใช้พร้อมฟีเจอร์อัพโหลดรูปโปรไฟล์
/// 
/// ฟีเจอร์ File Input:
/// - เลือกรูปจาก Gallery หรือถ่ายรูปใหม่
/// - ตรวจสอบขนาดไฟล์ไม่เกิน 5MB
/// - บันทึกรูปลง Local Storage
class AccountScreen extends StatefulWidget {
  final String username;

  const AccountScreen({super.key, required this.username});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isLoading = false;
  
  // ขนาดไฟล์สูงสุด 5MB
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  
  @override
  void initState() {
    super.initState();
    _loadSavedProfileImage();
  }
  
  /// โหลดรูปโปรไฟล์ที่บันทึกไว้
  Future<void> _loadSavedProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_${widget.username}');
    
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() {
        _profileImage = File(savedPath);
      });
    }
  }
  
  /// แสดง Dialog เลือกวิธีเลือกรูป
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'เลือกรูปโปรไฟล์',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: primaryOrange),
              title: const Text('ถ่ายรูป'),
              subtitle: const Text('ใช้กล้องถ่ายรูปใหม่'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: primaryOrange),
              title: const Text('เลือกจากแกลเลอรี่'),
              subtitle: const Text('เลือกรูปจากคลังภาพ'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('ลบรูปโปรไฟล์'),
                subtitle: const Text('ใช้รูปเริ่มต้น'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfileImage();
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  
  /// เลือกรูปจาก Gallery หรือ Camera แล้วอัพโหลดไป Java Backend
  /// 
  /// Flow:
  /// 1. Flutter: เลือก/ถ่ายรูป (image_picker)
  /// 2. Flutter: ส่งรูปไป Java Backend API (/api/files/profile/{username})
  /// 3. Java: FileController รับ request
  /// 4. Java: FileService.uploadProfileImage() บันทึกไฟล์ (FILE OUTPUT)
  /// 5. Java: ส่ง response กลับ
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      
      // 1. เลือก/ถ่ายรูป
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      // 2. ตรวจสอบขนาดไฟล์
      final File imageFile = File(pickedFile.path);
      final int fileSize = await imageFile.length();
      
      if (fileSize > maxFileSizeBytes) {
        if (mounted) {
          _showErrorDialog(
            'ไฟล์มีขนาดใหญ่เกินไป',
            'ขนาดไฟล์ต้องไม่เกิน 5MB\n'
            'ขนาดไฟล์ปัจจุบัน: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)}MB',
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // 3. อัพโหลดไป Java Backend (FILE I/O ผ่าน Java!)
      final result = await ApiService.uploadProfileImage(
        widget.username,
        pickedFile.path,
      );
      
      if (result['success'] == true) {
        // 4. บันทึก path ลง Local ด้วย (สำหรับ cache)
        final savedPath = await _saveImageToLocal(imageFile);
        
        if (savedPath != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image_${widget.username}', savedPath);
          
          setState(() {
            _profileImage = File(savedPath);
            _isLoading = false;
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อัพโหลดรูปโปรไฟล์ไป Server สำเร็จ!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // ถ้า upload ไป server ไม่สำเร็จ ก็บันทึก local อย่างเดียว
        final savedPath = await _saveImageToLocal(imageFile);
        
        if (savedPath != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image_${widget.username}', savedPath);
          
          setState(() {
            _profileImage = File(savedPath);
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('บันทึกรูปใน Local แล้ว (Server ไม่ตอบสนอง)'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('เกิดข้อผิดพลาด', e.toString());
      }
    }
  }
  
  /// บันทึกรูปภาพลง Local Storage
  Future<String?> _saveImageToLocal(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${widget.username}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${directory.path}/$fileName';
      
      await imageFile.copy(savedPath);
      return savedPath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }
  
  /// ลบรูปโปรไฟล์
  Future<void> _removeProfileImage() async {
    try {
      // ลบไฟล์
      if (_profileImage != null && _profileImage!.existsSync()) {
        await _profileImage!.delete();
      }
      
      // ลบ path จาก SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_${widget.username}');
      
      setState(() {
        _profileImage = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบรูปโปรไฟล์แล้ว'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error removing image: $e');
    }
  }
  
  /// แสดง Dialog แจ้งเตือน Error
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
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
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header with Back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
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
              const SizedBox(height: 40),
              // Profile Avatar - ปรับให้รองรับรูปภาพ
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.grey[200],
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : ClipOval(
                              child: _profileImage != null
                                  ? Image.file(
                                      _profileImage!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                            ),
                    ),
                    // ปุ่มแก้ไข
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: primaryOrange,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // ข้อความแนะนำ
              const Text(
                'แตะเพื่อเปลี่ยนรูป (สูงสุด 5MB)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 25),
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
                          "เกี่ยวกับบัญชี",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Username field
                        const Text(
                          "ชื่อผู้ใช้งาน",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Text(
                                widget.username,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Password field
                        const Text(
                          "รหัสผ่าน",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '••••••',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.visibility_off, color: Colors.grey),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
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
}
