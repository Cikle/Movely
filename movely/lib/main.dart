import 'package:flutter/material.dart';
import 'package:movely/theme.dart';
import 'package:movely/screens/home_screen.dart';
import 'package:movely/services/activity_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final activityService = ActivityService();
  runApp(MainApp(activityService: activityService));
}

class MainApp extends StatelessWidget {
  final ActivityService activityService;

  const MainApp({super.key, required this.activityService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movely',
      theme: movelyTheme,
      home: const HomeScreen(),
    );
  }
}
