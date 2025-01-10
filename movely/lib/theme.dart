import 'package:flutter/material.dart';

final movelyTheme = ThemeData.dark().copyWith(
  primaryColor: Colors.deepPurple.shade400,
  scaffoldBackgroundColor: const Color(0xFF0A0A0A),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0A0A0A),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple.shade400,
      padding: const EdgeInsets.symmetric(vertical: 16),
      minimumSize: const Size(double.infinity, 50),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    labelStyle: TextStyle(color: Colors.grey[400]),
  ),
  textTheme: TextTheme(
    headlineLarge: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(color: Colors.grey[200]),
    bodyMedium: TextStyle(color: Colors.grey[400]),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white.withOpacity(0.05),
    selectedColor: Colors.deepPurple.shade400,
    labelStyle: TextStyle(color: Colors.grey[400]),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
  ),
);
