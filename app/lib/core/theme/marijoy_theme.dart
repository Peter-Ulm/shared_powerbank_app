import 'package:flutter/material.dart';
import 'marijoy_colors.dart';

class MariJoyTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: MariJoyColors.chargeGreen,
      primary: MariJoyColors.chargeGreen,
      secondary: MariJoyColors.marigold,
      error: MariJoyColors.error,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: Colors.white,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}
