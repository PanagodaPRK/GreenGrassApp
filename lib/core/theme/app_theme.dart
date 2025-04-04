import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import 'button_theme.dart';
import 'input_theme.dart';
import 'text_theme.dart';

class AppTheme {
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent,
        secondaryContainer: AppColors.accentLight,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: AppTextTheme.darkTextTheme.copyWith(
        bodyLarge: AppTextTheme.darkTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: AppTextTheme.darkTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        titleLarge: AppTextTheme.darkTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      elevatedButtonTheme: AppButtonTheme.darkElevatedButtonTheme,
      inputDecorationTheme: AppInputTheme.darkInputDecorationTheme,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.primaryLight,
      ),
    );
  }
}
