// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class ThemeController extends GetxController {
//   // Singleton-like access method
//   final ThemeController themeController = Get.put(ThemeController());

//   final _box = GetStorage();
//   final _key = 'isDarkMode';

//   final Rx<ThemeMode> _themeMode = ThemeMode.light.obs;

//   ThemeMode get themeMode => _themeMode.value;
//   bool get isDarkMode => _themeMode.value == ThemeMode.dark;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadThemeFromStorage();
//   }

//   void _loadThemeFromStorage() {
//     // Corrected syntax for reading from storage
//     final isDarkMode = _box.read(_key) ?? false;
//     _themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
//     Get.changeThemeMode(_themeMode.value);
//   }

//   void toggleTheme() {
//     _themeMode.value =
//         _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//     Get.changeThemeMode(_themeMode.value);
//     _saveThemeToStorage();
//   }

//   void _saveThemeToStorage() {
//     // Corrected syntax for writing to storage
//     _box.write(_key, isDarkMode);
//   }

//   void changeThemeMode(ThemeMode themeMode) {
//     _themeMode.value = themeMode;
//     Get.changeThemeMode(_themeMode.value);
//     _saveThemeToStorage();
//   }

//   void setDarkMode() {
//     _themeMode.value = ThemeMode.dark;
//     Get.changeThemeMode(_themeMode.value);
//     _saveThemeToStorage();
//   }

//   void setLightMode() {
//     _themeMode.value = ThemeMode.light;
//     Get.changeThemeMode(_themeMode.value);
//     _saveThemeToStorage();
//   }
// }
