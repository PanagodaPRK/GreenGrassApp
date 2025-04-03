import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greengrass/navigation_menu.dart';

import '../../../core/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      try {
        isLoading.value = true;

        // Use the updated login method that returns Map<String, dynamic>
        final result = await _authService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (result['success']) {
          // Login successful
          Get.to(const NavigationMenu());
        } else {
          // Check if the error is related to email verification
          if (result['message']?.contains('verify your email') == true) {
            // Show verification message with resend option
            Get.snackbar(
              'Email Not Verified',
              result['message'] ??
                  'Please verify your email before logging in.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 5),
              mainButton: TextButton(
                onPressed: () async {
                  await _authService.resendVerificationCode(
                    emailController.text.trim(),
                  );
                  Get.snackbar(
                    'Verification Email Sent',
                    'A new verification email has been sent to your email address.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                  );
                },
                child: const Text(
                  'Resend',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          } else {
            // Show the specific error message from the result
            Get.snackbar(
              'Login Failed',
              result['message'] ?? 'Incorrect email or password',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // This should be handled by the AuthService now, but keeping as fallback
        String errorMessage = 'An error occurred during login';

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is invalid';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled';
            break;
          case 'email-not-verified':
            errorMessage = 'Please verify your email before logging in';
            break;
          case 'too-many-requests':
            errorMessage =
                'Too many failed login attempts. Please try again later';
            break;
          default:
            errorMessage = e.message ?? 'Login failed. Please try again.';
        }

        Get.snackbar(
          'Login Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } catch (e) {
        print('Unhandled login error: $e');
        Get.snackbar(
          'Error',
          'An unexpected error occurred. Please try again later.',
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
