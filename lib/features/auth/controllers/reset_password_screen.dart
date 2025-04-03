import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';

class ResetPasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxString email = ''.obs;
  final RxBool canResend = false.obs;
  final RxInt secondsRemaining = 60.obs;

  Timer? _timer;
  String _verificationCode = '';

  @override
  void onInit() {
    super.onInit();
    // Get email from arguments
    if (Get.arguments != null) {
      email.value = Get.arguments as String;
    }
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void startTimer() {
    canResend.value = false;
    secondsRemaining.value = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void verifyOtp(String otp) {
    _verificationCode = otp;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> resetPassword() async {
    if (_verificationCode.isEmpty || _verificationCode.length < 6) {
      Get.snackbar(
        'Error',
        'Please enter the verification code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // if (formKey.currentState!.validate()) {
    //   try {
    //     isLoading.value = true;

    //     // This approach uses Firebase's custom reset password flow with verification code
    //     // For a simpler approach with just an email link, use the commented code below
    //     final success = await _authService.resetPassword(
    //       email: email.value,
    //       code: _verificationCode,
    //       newPassword: passwordController.text,
    //     );

    //     if (success) {
    //       Get.offAllNamed(Routes.resetSuccess);
    //     } else {
    //       Get.snackbar(
    //         'Error',
    //         'Failed to reset password. Please try again.',
    //         snackPosition: SnackPosition.BOTTOM,
    //         backgroundColor: Colors.red,
    //         colorText: Colors.white,
    //         margin: const EdgeInsets.all(16),
    //       );
    //     }

    //     // Alternative simpler approach using Firebase's email link:
    //     // await _authService.resetPassword(email.value);
    //     // Get.offAllNamed(Routes.resetLinkSent);
    //   } catch (e) {
    //     Get.snackbar(
    //       'Error',
    //       'An error occurred: ${e.toString()}',
    //       snackPosition: SnackPosition.BOTTOM,
    //       backgroundColor: Colors.red,
    //       colorText: Colors.white,
    //       margin: const EdgeInsets.all(16),
    //     );
    //   } finally {
    //     isLoading.value = false;
    //   }
    // }
  }

  Future<void> resendCode() async {
    try {
      isLoading.value = true;

      final success = await _authService.forgotPassword(email: email.value);

      Get.snackbar(
        'Success',
        'Verification code sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      startTimer();
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
