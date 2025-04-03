// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greengrass/features/auth/screens/splash_screen.dart';
import '../core/navigation/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/services/firebase_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const MyApp({super.key, this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    _initializeServices();

    // Don't use both home and initialRoute - it causes navigation conflicts
    return GetMaterialApp(
      title: 'Review App',
      theme: AppTheme.darkTheme(),
      navigatorKey: navigatorKey,
      getPages: AppRouter.routes,
      defaultTransition: Transition.fadeIn,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }

  void _initializeServices() {
    // Using lazyPut with fenix:true ensures services are created only once
    // and won't be duplicated, preventing resource conflicts
    if (!Get.isRegistered<FirebaseService>()) {
      final firebaseService = FirebaseService();
      Get.put(firebaseService, permanent: true);
      Get.put(AuthService(firebaseService), permanent: true);
      Get.put(StorageService(firebaseService), permanent: true);
    }
  }
}
