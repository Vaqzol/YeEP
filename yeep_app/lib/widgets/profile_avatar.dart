import 'dart:io';
import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../main.dart';

/// ProfileAvatar - Widget สำหรับแสดงรูปโปรไฟล์
/// ใช้ได้ทุกหน้าที่ต้องการแสดงรูปโปรไฟล์
class ProfileAvatar extends StatefulWidget {
  final String username;
  final double size;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color borderColor;
  
  const ProfileAvatar({
    super.key,
    required this.username,
    this.size = 40,
    this.onTap,
    this.showBorder = true,
    this.borderColor = Colors.white,
  });
  
  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  File? _profileImage;
  
  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }
  
  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      _loadProfileImage();
    }
  }
  
  Future<void> _loadProfileImage() async {
    final image = await ProfileService.getProfileImageStatic(widget.username);
    if (mounted) {
      setState(() {
        _profileImage = image;
      });
    }
  }
  
  /// รีโหลดรูปภาพ (เรียกจากภายนอกได้)
  void reload() {
    _loadProfileImage();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: widget.showBorder 
            ? Border.all(color: widget.borderColor, width: 2)
            : null,
        ),
        child: ClipOval(
          child: _profileImage != null
            ? Image.file(
                _profileImage!,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
              )
            : Icon(
                Icons.person,
                color: Colors.grey,
                size: widget.size * 0.6,
              ),
        ),
      ),
    );
  }
}

/// ProfileAvatarWithRefresh - ProfileAvatar พร้อมความสามารถ refresh เมื่อกลับมา
class ProfileAvatarWithRefresh extends StatefulWidget {
  final String username;
  final double size;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color borderColor;
  
  const ProfileAvatarWithRefresh({
    super.key,
    required this.username,
    this.size = 40,
    this.onTap,
    this.showBorder = true,
    this.borderColor = Colors.white,
  });
  
  @override
  State<ProfileAvatarWithRefresh> createState() => ProfileAvatarWithRefreshState();
}

class ProfileAvatarWithRefreshState extends State<ProfileAvatarWithRefresh> 
    with WidgetsBindingObserver {
  File? _profileImage;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileImage();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfileImage();
    }
  }
  
  Future<void> _loadProfileImage() async {
    final image = await ProfileService.getProfileImageStatic(widget.username);
    if (mounted) {
      setState(() {
        _profileImage = image;
      });
    }
  }
  
  /// Public method to refresh the profile image
  void refresh() {
    _loadProfileImage();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: widget.showBorder 
            ? Border.all(color: widget.borderColor, width: 2)
            : null,
        ),
        child: ClipOval(
          child: _profileImage != null
            ? Image.file(
                _profileImage!,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
              )
            : Icon(
                Icons.person,
                color: Colors.grey,
                size: widget.size * 0.6,
              ),
        ),
      ),
    );
  }
}
