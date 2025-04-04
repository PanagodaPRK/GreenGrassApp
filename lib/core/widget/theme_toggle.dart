// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../theme/theme_controller.dart';
// import '../constants/app_colors.dart';

// class ThemeToggle extends StatelessWidget {
//   const ThemeToggle({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ThemeController themeController = Get.put(ThemeController());

//     return Obx(
//       () => IconButton(
//         icon: Icon(
//           themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
//           color:
//               Theme.of(context).brightness == Brightness.dark
//                   ? AppColors.textPrimaryDark
//                   : AppColors.textPrimary,
//         ),
//         onPressed: () {
//           themeController.toggleTheme();
//         },
//         tooltip:
//             themeController.isDarkMode
//                 ? 'Switch to Light Mode'
//                 : 'Switch to Dark Mode',
//       ),
//     );
//   }
// }

// // A more elaborate theme toggle with animation
// class AnimatedThemeToggle extends StatelessWidget {
//   const AnimatedThemeToggle({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ThemeController themeController = Get.find<ThemeController>();

//     return Obx(() {
//       final isDark = themeController.isDarkMode;

//       return GestureDetector(
//         onTap: () {
//           themeController.toggleTheme();
//         },
//         child: Container(
//           width: 70,
//           height: 35,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),
//             color: isDark ? AppColors.surfaceDark : AppColors.primaryLight,
//             boxShadow: [
//               if (!isDark)
//                 BoxShadow(
//                   color: AppColors.primary.withOpacity(0.3),
//                   blurRadius: 8,
//                   spreadRadius: 1,
//                   offset: const Offset(0, 2),
//                 ),
//             ],
//           ),
//           padding: const EdgeInsets.all(3),
//           child: Stack(
//             children: [
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 250),
//                 curve: Curves.easeInOut,
//                 left: isDark ? 38 : 4,
//                 top: 3,
//                 child: Container(
//                   width: 26,
//                   height: 26,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isDark ? AppColors.primary : Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 4,
//                         spreadRadius: 0,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Icon(
//                       isDark ? Icons.nightlight_round : Icons.wb_sunny,
//                       size: 16,
//                       color: isDark ? Colors.white : AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               // Sun icon on the left
//               Positioned(
//                 left: 8,
//                 top: 8,
//                 child: Opacity(
//                   opacity: isDark ? 1.0 : 0.0,
//                   child: const Icon(
//                     Icons.wb_sunny,
//                     size: 18,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               // Moon icon on the right
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: Opacity(
//                   opacity: isDark ? 0.0 : 1.0,
//                   child: const Icon(
//                     Icons.nightlight_round,
//                     size: 18,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }

// // A theme toggle switch with text labels
// class ThemeToggleSwitch extends StatelessWidget {
//   const ThemeToggleSwitch({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ThemeController themeController = Get.find<ThemeController>();
//     final isSmallScreen = MediaQuery.of(context).size.width < 600;

//     return Obx(() {
//       final isDark = themeController.isDarkMode;

//       return Container(
//         decoration: BoxDecoration(
//           color:
//               Theme.of(context).brightness == Brightness.dark
//                   ? AppColors.surfaceDark
//                   : Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Light mode option
//               GestureDetector(
//                 onTap: () => themeController.setLightMode(),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isSmallScreen ? 12 : 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color:
//                         !isDark
//                             ? Theme.of(context).primaryColor
//                             : Colors.transparent,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.wb_sunny_outlined,
//                         size: 16,
//                         color:
//                             !isDark
//                                 ? Colors.white
//                                 : Theme.of(context).brightness ==
//                                     Brightness.dark
//                                 ? Colors.white70
//                                 : Colors.black54,
//                       ),
//                       if (!isSmallScreen) ...[
//                         const SizedBox(width: 4),
//                         Text(
//                           'Light',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight:
//                                 !isDark ? FontWeight.bold : FontWeight.normal,
//                             color:
//                                 !isDark
//                                     ? Colors.white
//                                     : Theme.of(context).brightness ==
//                                         Brightness.dark
//                                     ? Colors.white70
//                                     : Colors.black54,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),

//               // Dark mode option
//               GestureDetector(
//                 onTap: () => themeController.setDarkMode(),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isSmallScreen ? 12 : 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color:
//                         isDark
//                             ? Theme.of(context).primaryColor
//                             : Colors.transparent,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.nightlight_round,
//                         size: 16,
//                         color:
//                             isDark
//                                 ? Colors.white
//                                 : Theme.of(context).brightness ==
//                                     Brightness.dark
//                                 ? Colors.white70
//                                 : Colors.black54,
//                       ),
//                       if (!isSmallScreen) ...[
//                         const SizedBox(width: 4),
//                         Text(
//                           'Dark',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight:
//                                 isDark ? FontWeight.bold : FontWeight.normal,
//                             color:
//                                 isDark
//                                     ? Colors.white
//                                     : Theme.of(context).brightness ==
//                                         Brightness.dark
//                                     ? Colors.white70
//                                     : Colors.black54,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }

// // A floating action button style theme toggle
// class ThemeToggleFAB extends StatelessWidget {
//   final double size;

//   const ThemeToggleFAB({super.key, this.size = 56.0});

//   @override
//   Widget build(BuildContext context) {
//     final ThemeController themeController = Get.find<ThemeController>();

//     return Obx(() {
//       final isDark = themeController.isDarkMode;

//       return SizedBox(
//         width: size,
//         height: size,
//         child: FloatingActionButton(
//           onPressed: () {
//             themeController.toggleTheme();
//           },
//           backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             transitionBuilder: (Widget child, Animation<double> animation) {
//               return RotationTransition(
//                 turns: animation,
//                 child: ScaleTransition(scale: animation, child: child),
//               );
//             },
//             child: Icon(
//               isDark ? Icons.light_mode : Icons.dark_mode,
//               key: ValueKey<bool>(isDark),
//               color: Colors.white,
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
