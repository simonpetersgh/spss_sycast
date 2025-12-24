// APP LEVEL THEME SETTINGS
import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color.fromARGB(255, 10, 140, 150); // Pink/Studio vibe
  static const darkBg = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBg,
    cardColor: surface,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      surface: surface,
    ),
    useMaterial3: true,
  );
}