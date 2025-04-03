import 'package:get/get.dart';
import 'package:greengrass/features/auth/screens/reset_password_screen.dart'
    show ResetLinkSentScreen, ResetPasswordScreen;
import 'package:greengrass/features/profile/screens/faq_screen.dart';
import 'package:greengrass/features/profile/screens/help_support_screen.dart';

import '../../features/auth/screens/Welcome_Screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/verification_success_screen.dart';
import '../../features/home/screens/HomeScreen.dart';
import '../../features/media/screens/medai_details_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../services/auth_service.dart';
import 'routes.dart';

class AppRouter {
  static String get initialRoute {
    // Check if user is logged in
    final authService = Get.find<AuthService>();
    return Routes
        .splash; // Always start with splash, then redirect based on auth
  }

  static final routes = [
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: Routes.login, page: () => const LoginScreen()),
    GetPage(name: Routes.register, page: () => const RegisterScreen()),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetLinkSentScreen(),
    ),
    GetPage(name: Routes.verifyEmail, page: () => const VerifyEmailScreen()),
    GetPage(
      name: Routes.verificationSuccess,
      page: () => const VerificationSuccessScreen(),
    ),
    GetPage(name: Routes.resetSuccess, page: () => const ResetSuccessScreen()),
    GetPage(name: Routes.home, page: () => const HomeScreen()),
    GetPage(name: Routes.profile, page: () => const ProfileScreen()),
    // Uncomment as you implement these screens
    GetPage(name: Routes.mediaDetails, page: () => const MediaDetailsScreen()),
    GetPage(name: Routes.faq, page: () => const FAQScreen()),
    GetPage(name: Routes.helpSupport, page: () => const HelpSupportScreen()),
  ];
}
