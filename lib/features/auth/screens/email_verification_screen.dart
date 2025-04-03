import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/otp_input_field.dart';
import '../controllers/email_controller.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VerifyEmailController controller = Get.put(VerifyEmailController());
    final Size size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.dividerDark,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  iconSize: 16,
                  splashRadius: 24,
                ),

                const SizedBox(height: 32),

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Verify Your Email',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Obx(
                          () => Text(
                            'We have sent a verification code to ${controller.email.value}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: AppColors.textSecondaryDark,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // OTP verification
                OtpInputField(
                  onCompleted: (otp) => controller.verifyOtp(otp),
                  onChanged: (value) {},
                  length: 6,
                ),

                const SizedBox(height: 24),

                // Timer and resend code
                Center(
                  child: Obx(
                    () =>
                        controller.canResend.value
                            ? TextButton(
                              onPressed: controller.resendCode,
                              child: const Text(
                                'Resend Code',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : RichText(
                              text: TextSpan(
                                text: 'Resend code in ',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        '${controller.secondsRemaining.value}s',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 48),

                // Verify button
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : controller.verifyEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 14.0 : 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      disabledBackgroundColor: AppColors.primary.withOpacity(
                        0.5,
                      ),
                    ),
                    child:
                        controller.isLoading.value
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                            : const Text(
                              'Verify Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 24),

                // Change email
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Entered wrong email? ",
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      children: [
                        TextSpan(
                          text: 'Change Email',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer:
                              TapGestureRecognizer()..onTap = () => Get.back(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
