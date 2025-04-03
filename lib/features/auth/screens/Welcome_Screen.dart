import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greengrass/navigation_menu.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/routes.dart';
import '../controllers/welcome_controller.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WelcomeController controller = Get.put(WelcomeController());
    final Size size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.changePage,
                itemCount: controller.onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = controller.onboardingPages[index];
                  return _buildOnboardingPage(context, page, isSmallScreen);
                },
              ),
            ),
            _buildBottomSection(controller, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context,
    OnboardingPage page,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20.0 : 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo at the top
          Hero(
            tag: 'app_logo',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(page.icon, color: AppColors.primary, size: 40),
            ),
          ),

          const SizedBox(height: 16),

          // App name
          const Text(
            'GreenGrass',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          // App tagline
          const Text(
            'Media Reviews & Ratings',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondaryDark,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 40),

          // Illustration
          Container(
            height: isSmallScreen ? 180 : 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child:
                page.imagePath.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(page.imagePath, fit: BoxFit.cover),
                    )
                    : Center(
                      child: Icon(
                        page.icon,
                        size: 80,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: isSmallScreen ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: AppColors.textSecondaryDark,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(WelcomeController controller, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 16.0 : 24.0,
        horizontal: isSmallScreen ? 20.0 : 24.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page indicator
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.onboardingPages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: controller.currentPage.value == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color:
                        controller.currentPage.value == index
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Auth buttons
          Row(
            children: [
              // Login button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceDark,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 12.0 : 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Register button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 12.0 : 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Continue as guest
          TextButton(
            onPressed: () => Get.to(const NavigationMenu()),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondaryDark,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue as guest',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
