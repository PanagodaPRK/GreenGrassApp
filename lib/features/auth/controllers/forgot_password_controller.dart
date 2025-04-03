import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  Future<void> sendResetLink() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;

        final success = await _authService.forgotPassword(
          email: emailController.text.trim(),
        );

        // Navigate to reset password screen
        Get.toNamed('/reset-password', arguments: emailController.text.trim());
      } catch (e) {
        Get.snackbar(
          'Error',
          'An error occurred: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}
