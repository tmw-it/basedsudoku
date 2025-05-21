import 'package:flutter/material.dart';
import 'package:based_sudoku/theme/nord_theme.dart';

class AndroidTheme {
  static ThemeData get light {
    final baseTheme = NordTheme.light;
    return baseTheme.copyWith(
      // Android-specific adjustments
      appBarTheme: baseTheme.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NordColors.nord10,
          foregroundColor: NordColors.nord6,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final baseTheme = NordTheme.dark;
    return baseTheme.copyWith(
      // Android-specific adjustments
      appBarTheme: baseTheme.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NordColors.nord8,
          foregroundColor: NordColors.nord0,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 