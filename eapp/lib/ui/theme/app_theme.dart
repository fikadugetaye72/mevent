import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF0B132B);
  static const Color secondaryBlue = Color(0xFF00B4D8);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color bgLight = Color(0xFFF8FAFC);
}

class AppTheme {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryBlue,
      error: AppColors.accentCoral,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primaryDark,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 1,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryBlue,
      error: AppColors.accentCoral,
      surface: Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF0C101F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0B132B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF0F172A),
      elevation: 1,
    ),
  );
}
