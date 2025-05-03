import 'package:flutter/material.dart';

/// Nord color palette
class NordColors {
  // Polar Night
  static const nord0 = Color(0xFF2E3440); // Dark background
  static const nord1 = Color(0xFF3B4252); // Lighter background
  static const nord2 = Color(0xFF434C5E); // Lighter background
  static const nord3 = Color(0xFF4C566A); // Lightest background

  // Snow Storm
  static const nord4 = Color(0xFFD8DEE9); // Bright foreground
  static const nord5 = Color(0xFFE5E9F0); // Brighter foreground
  static const nord6 = Color(0xFFECEFF4); // Brightest foreground

  // Frost
  static const nord7 = Color(0xFF8FBCBB); // Bluish accent
  static const nord8 = Color(0xFF88C0D0); // Light blue
  static const nord9 = Color(0xFF81A1C1); // Medium blue
  static const nord10 = Color(0xFF5E81AC); // Dark blue

  // Aurora
  static const nord11 = Color(0xFFBF616A); // Red/error
  static const nord12 = Color(0xFFD08770); // Orange/warning
  static const nord13 = Color(0xFFEBCB8B); // Yellow
  static const nord14 = Color(0xFFA3BE8C); // Green/success
  static const nord15 = Color(0xFFB48EAD); // Purple
}

/// Nord theme data for light and dark themes
class NordTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: NordColors.nord10,
        onPrimary: NordColors.nord6,
        secondary: NordColors.nord7,
        onSecondary: NordColors.nord0,
        error: NordColors.nord11,
        background: NordColors.nord6,
        surface: NordColors.nord5,
        onSurface: NordColors.nord0,
      ),
      scaffoldBackgroundColor: NordColors.nord6,
      textTheme: const TextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: NordColors.nord10,
        foregroundColor: NordColors.nord6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NordColors.nord10,
          foregroundColor: NordColors.nord6,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: NordColors.nord8,
        onPrimary: NordColors.nord0,
        secondary: NordColors.nord7,
        onSecondary: NordColors.nord0,
        error: NordColors.nord11,
        background: NordColors.nord0,
        surface: NordColors.nord1,
        onSurface: NordColors.nord4,
      ),
      scaffoldBackgroundColor: NordColors.nord0,
      textTheme: const TextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: NordColors.nord1,
        foregroundColor: NordColors.nord4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NordColors.nord8,
          foregroundColor: NordColors.nord0,
        ),
      ),
    );
  }
} 