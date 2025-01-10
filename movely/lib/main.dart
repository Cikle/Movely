import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movely/theme.dart';
import 'package:movely/screens/home_screen.dart';
import 'package:movely/services/activity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gtmosdnfiimqfxtiknsn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0bW9zZG5maWltcWZ4dGlrbnNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY1MTQzODEsImV4cCI6MjA1MjA5MDM4MX0.5OuvCnXb8gt8tt1vJyqaVN3YY35rxYljdFoTnUl3Vhg',
  );

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
      home: HomeScreen(activityService: activityService),
    );
  }
}
