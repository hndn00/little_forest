import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const forestDeep = Color(0xFF1A3A2A);
  static const forestLight = Color(0xFF4A8C62);
  static const mintSoft = Color(0xFFA8D5B5);
  static const skyTop = Color(0xFFB8DCF0);
  static const skyBottom = Color(0xFFE8F5E9);
  static const grassGreen = Color(0xFF6DBE6D);
  static const sunYellow = Color(0xFFFFC94D);
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    textTheme: GoogleFonts.poppinsTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.forestDeep,
    ),
    scaffoldBackgroundColor: AppColors.white,
  );
}