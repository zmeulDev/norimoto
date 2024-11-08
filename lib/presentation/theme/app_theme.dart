import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF246BFD); // Main Blue
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color grey = Color(0xFF94A3B8);

  // Additional Shades
  static const Color lightGrey = Color(0xFFF7F7F7);
  static const Color mediumGrey = Color(0xFFE5E7EB);
  static const Color darkGrey = Color(0xFF6B7280);
  static const Color lightBlue = Color(0xFFEEF4FF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: white,
        secondary: black,
        onSecondary: white,
        surface: white,
        onSurface: black,
      ),
      scaffoldBackgroundColor: lightGrey,
      cardTheme: CardTheme(
        elevation: 0,
        color: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightBlue,
        labelStyle: const TextStyle(
          color: primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: mediumGrey,
        thickness: 1,
        space: 24,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          color: black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: black),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: darkGrey,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: grey,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: grey,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primary,
        unselectedItemColor: grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
    );
  }
}
