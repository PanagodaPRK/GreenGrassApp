import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());
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
                _buildBackButton(),

                const SizedBox(height: 24),

                // Header
                _buildHeader(isSmallScreen),

                const SizedBox(height: 32),

                // Registration form
                _buildRegistrationForm(context, controller, isSmallScreen),

                const SizedBox(height: 24),

                // Terms & conditions
                _buildTermsAndConditions(controller, isSmallScreen),

                const SizedBox(height: 32),

                // Register button
                _buildRegisterButton(controller, isSmallScreen),

                const SizedBox(height: 40),

                // Login text
                _buildLoginText(isSmallScreen),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => Get.back(),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dividerDark, width: 1),
        ),
        child: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
      iconSize: 16,
      splashRadius: 24,
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Register to access all features',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(
    BuildContext context,
    RegisterController controller,
    bool isSmallScreen,
  ) {
    return Form(
      key: controller.registerFormKey,
      child: Column(
        children: [
          // Full name field
          CustomTextField(
            controller: controller.fullNameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            validator: controller.validateFullName,
          ),

          const SizedBox(height: 20),

          // Email field
          CustomTextField(
            controller: controller.emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
          ),

          const SizedBox(height: 20),

          // Mobile number field
          CustomTextField(
            controller: controller.mobileController,
            labelText: 'Mobile Number',
            hintText: 'Enter your mobile number',
            prefixIcon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            validator: controller.validateMobile,
          ),

          const SizedBox(height: 20),

          // Password field
          Obx(
            () => CustomTextField(
              controller: controller.passwordController,
              labelText: 'Password',
              hintText: 'Create a password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !controller.isPasswordVisible.value,
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              validator: controller.validatePassword,
            ),
          ),

          const SizedBox(height: 20),

          // Confirm password field
          Obx(
            () => CustomTextField(
              controller: controller.confirmPasswordController,
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !controller.isConfirmPasswordVisible.value,
              suffixIcon: IconButton(
                onPressed: controller.toggleConfirmPasswordVisibility,
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              validator: controller.validateConfirmPassword,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(
    RegisterController controller,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: controller.agreedToTerms.value,
            onChanged: (value) => controller.toggleTermsAgreement(),
            fillColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return AppColors.surfaceDark;
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.dividerDark, width: 1.5),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              children: [
                TextSpan(
                  text: 'Terms & Conditions',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () => controller.openTermsAndConditions(),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () => controller.openPrivacyPolicy(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(
    RegisterController controller,
    bool isSmallScreen,
  ) {
    return Obx(
      () => ElevatedButton(
        onPressed:
            controller.isLoading.value || !controller.agreedToTerms.value
                ? null
                : () => controller.register(Get.context!),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14.0 : 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
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
                  'Register',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Widget _buildLoginText(bool isSmallScreen) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          children: [
            TextSpan(
              text: 'Login',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              recognizer:
                  TapGestureRecognizer()..onTap = () => Get.toNamed('/login'),
            ),
          ],
        ),
      ),
    );
  }
}
