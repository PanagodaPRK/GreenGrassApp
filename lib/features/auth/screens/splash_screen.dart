import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/splash_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final SplashController controller = Get.put(SplashController());

    // Set system UI overlay style for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.backgroundDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark.withOpacity(0.8),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        // Media icons in a circular pattern
                        Positioned(
                          top: 10,
                          child: Icon(
                            Icons.movie_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          child: Icon(
                            Icons.tv_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        Positioned(
                          left: 10,
                          child: Icon(
                            Icons.music_note_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        Positioned(
                          right: 10,
                          child: Icon(
                            Icons.book_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        // Star in the center
                        Icon(
                          Icons.star_rate_rounded,
                          color: AppColors.primary,
                          size: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // App name animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: const Text(
                  'GreenGrass',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tagline animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: const Text(
                  'Media Reviews & Ratings',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondaryDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle animation for media types
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: const Text(
                  'Movies • TV Shows • Music • Books',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Loading indicator
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeIn,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withOpacity(0.8),
                  ),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
