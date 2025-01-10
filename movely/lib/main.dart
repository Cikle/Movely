import 'package:flutter/material.dart';
import 'package:movely/theme.dart';
import 'package:movely/screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movely',
      theme: movelyTheme,
      home: const HomeScreen(),
    );
  }
}
