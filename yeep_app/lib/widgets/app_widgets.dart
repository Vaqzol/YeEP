import 'package:flutter/material.dart';
import '../main.dart';

/// Reusable UI components for the app
class AppWidgets {
  /// Orange gradient header with YeEP logo
  static Widget buildHeader({
    required BuildContext context,
    required String username,
    String backText = "Back",
    VoidCallback? onBack,
  }) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Navigation row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBack ?? () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      backText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildUserAvatar(username),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Logo
        _buildLogo(),
        const SizedBox(height: 30),
      ],
    );
  }

  static Widget _buildUserAvatar(String username) {
    final displayName = username.isEmpty
        ? 'User'
        : (username.length > 8 ? '${username.substring(0, 8)}...' : username);

    return Row(
      children: [
        Text(
          displayName,
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
    );
  }

  static Widget _buildLogo() {
    return Padding(
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
    );
  }

  /// White card container with rounded top corners
  static Widget buildWhiteCard({required Widget child}) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(30, 35, 30, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: child,
      ),
    );
  }

  /// Orange gradient background
  static BoxDecoration get orangeGradientBackground => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [secondaryOrange, primaryOrange],
    ),
  );

  /// Standard button style
  static ButtonStyle primaryButtonStyle({
    Color? backgroundColor,
    double borderRadius = 25,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? Colors.green,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'ไม่',
    String confirmText = 'ยืนยัน',
    Color confirmColor = Colors.red,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
