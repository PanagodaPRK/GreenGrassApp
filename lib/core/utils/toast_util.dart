import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastUtil {
  static void showSuccess(String message) {
    _showToast(
      message,
      backgroundColor: Colors.green.shade800,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showError(String message) {
    _showToast(
      message,
      backgroundColor: Colors.red.shade800,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showWarning(String message) {
    _showToast(
      message,
      backgroundColor: Colors.amber.shade900,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void showInfo(String message) {
    _showToast(
      message,
      backgroundColor: Colors.blue.shade800,
      icon: Icons.info_outline_rounded,
    );
  }

  static void _showToast(
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      '', // Title (empty)
      '', // Message (empty, using custom content)
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      // Custom layout
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      // No title text
      titleText: const SizedBox.shrink(),
    );
  }
}
