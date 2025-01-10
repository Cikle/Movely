import 'package:flutter/material.dart';

final movelyTheme = ThemeData.dark().copyWith(
  primaryColor: Colors.blue.shade400,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0A0A0A),
    elevation: 0,
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    ),
    buttonColor: Colors.blue.shade400,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);
