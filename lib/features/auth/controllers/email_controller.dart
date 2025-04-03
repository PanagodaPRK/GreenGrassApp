import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';

class VerifyEmailController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

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

  void verifyOtp(String otp) {
    _verificationCode = otp;
  }

  Future<void> verifyEmail() async {
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

    try {
      isLoading.value = true;

      final success = await _authService.verifyEmail(
        email: email.value,
        code: _verificationCode,
      );

      if (success) {
        Get.offAllNamed('/verification-success');
      } else {
        Get.snackbar(
          'Verification Failed',
          'Invalid verification code. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
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

  Future<void> resendCode() async {
    try {
      isLoading.value = true;

      final success = await _authService.resendVerificationCode(email.value);

      if (success) {
        Get.snackbar(
          'Success',
          'Verification code sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        startTimer();
      } else {
        Get.snackbar(
          'Failed',
          'Failed to send verification code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
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
