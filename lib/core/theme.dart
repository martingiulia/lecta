import 'package:flutter/material.dart';

class AppTheme {
  // Colori dell'app
  static const Color primary = Color(0xFF10B981);

  // Colori di background
  static const Color lightBackground = Color(0xFFEBE5E5);
  static const Color darkBackground = Color(0xFF121212);
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Tema chiaro dell'applicazione
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: lightBackground,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roobert',
        ),
        iconTheme: IconThemeData(color: Colors.grey),
        actionsIconTheme: IconThemeData(color: Colors.grey),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 20,
            letterSpacing: -0.5,
            height: 1.15,
            color: Colors.black,
            fontFamily: 'Roobert',
            fontWeight: FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          minimumSize: const Size.fromHeight(50), // Altezza del bottone
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 60,
          height: 1.13,
          color: Colors.black,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w400, // Regular
        ),
        headlineMedium: TextStyle(
          fontSize: 25,
          height: 1.12,
          color: Colors.black,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w400, // Regular
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w500, // Medium
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          color: Colors.black,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w600, // SemiBold
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w500, // Medium
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w400, // Regular
        ),
        bodyLarge: TextStyle(
          fontSize: 20,
          letterSpacing: -0.5,
          height: 1.15,
          color: Colors.black,
          fontFamily: 'Roobert',
          fontWeight: FontWeight.w400, // Regular
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          letterSpacing: -0.5,
          height: 1.15,
          color: Colors.black,
          fontFamily: 'Roobert',
          fontWeight: FontWeight.w400, // Regular
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontFamily: 'Roobert',
          fontWeight: FontWeight.w400, // Regular
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w600, // SemiBold
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w500, // Medium
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          color: Colors.black54,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w400, // Regular
        ),
      ),
    );
  }

  /// Tema scuro dell'applicazione
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackground,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roobert',
        ),
        iconTheme: IconThemeData(color: Colors.grey),
        actionsIconTheme: IconThemeData(color: Colors.grey),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 20,
            letterSpacing: -0.5,
            height: 1.15,
            color: Colors.white,
            fontFamily: 'Roobert',
            fontWeight: FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          minimumSize: const Size.fromHeight(60), // Altezza del bottone
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 60,
          height: 1.13,
          color: Colors.white,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w400, // Regular
        ),
        headlineMedium: TextStyle(
          fontSize: 25,
          height: 1.12,
          color: Colors.white,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w400, // Regular
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w500, // Medium
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w600, // SemiBold
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w500, // Medium
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w400, // Regular
        ),
        bodyLarge: TextStyle(
          fontSize: 20,
          letterSpacing: -0.5,
          height: 1.15,
          color: Colors.white,
          fontFamily: 'Roobert',
          fontWeight: FontWeight.w400, // Regular
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          letterSpacing: -0.5,
          height: 1.15,
          color: Colors.white,
          fontFamily: 'Roobert',
          fontWeight: FontWeight.w400, // Regular
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Colors.white54,
          fontFamily: 'Roobert',
          fontWeight: FontWeight.w400, // Regular
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w600, // SemiBold
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w500, // Medium
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          color: Colors.white54,
          fontFamily: 'LibreCaslonCondensed',
          fontWeight: FontWeight.w400, // Regular
        ),
      ),
    );
  }
}
