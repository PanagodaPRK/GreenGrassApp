import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../navigation_menu.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _initSplash();
  }

  void _initSplash() async {
    // Simulate loading necessary data
    await Future.delayed(const Duration(seconds: 3));

    // Check if user is already logged in
    final isLoggedIn = _authService.isLoggedIn;

    // Navigate to welcome or home based on auth status
    if (isLoggedIn) {
      Get.to(const NavigationMenu());
    } else {
      Get.offAllNamed('/welcome');
    }
  }
}
