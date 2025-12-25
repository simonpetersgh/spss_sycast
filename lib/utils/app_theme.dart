// APP LEVEL THEME SETTINGS
import 'package:flutter/material.dart';

// class AppTheme {
//   static const primaryColor = Color.fromARGB(255, 10, 140, 150); // Pink/Studio vibe
//   static const darkBg = Color(0xFF121212);
//   static const surface = Color(0xFF1E1E1E);

//   static ThemeData darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     primaryColor: primaryColor,
//     scaffoldBackgroundColor: darkBg,
//     cardColor: surface,
//     colorScheme: const ColorScheme.dark(
//       primary: primaryColor,
//       surface: surface,
//     ),
//     useMaterial3: true,
//   );
// }

class AppTheme {
  // Hex color constants
  static const Color darkBg = Color(0xFF181C27); // Your Primary (Background)
  static const Color mintSecondary = Color(
    0xFF1EDDAA,
  ); // Your Secondary (Buttons)
  static const Color purpleAccent = Color(
    0xFF9549FE,
  ); // Your Accent (Hover/Highlights)

  static const Color primaryColor =
      mintSecondary; // For consistency with previous code

  // Surface color - slightly lighter than background for cards/modals
  static const Color surface = Color(0xFF232937);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Background colors
    scaffoldBackgroundColor: darkBg,
    canvasColor: darkBg,

    colorScheme: const ColorScheme.dark(
      primary: mintSecondary, // Main action color
      onPrimary: Colors.white, // Text color on top of mint
      secondary: purpleAccent, // Accent color
      onSecondary: Colors.white,
      surface: surface,
      onSurface: Colors.white, // Main text color
      outline: purpleAccent, // Borders/Hover states
    ),

    // Card and Dialog styling
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mintSecondary,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Text selection and cursor
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: mintSecondary,
      selectionColor: purpleAccent,
      selectionHandleColor: purpleAccent,
    ),

    // Custom Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(
        color: Colors.white70,
      ), // Appropriate shade of white
    ),

    // Hover effect for Web/Desktop
    hoverColor: purpleAccent.withOpacity(0.1),
  );
}
