import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movely/theme.dart';
import 'package:movely/screens/auth_screen.dart';
import 'package:movely/screens/home_screen.dart';
import 'package:movely/screens/onboarding_screen.dart';
import 'package:movely/services/activity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gtmosdnfiimqfxtiknsn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0bW9zZG5maWltcWZ4dGlrbnNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY1MTQzODEsImV4cCI6MjA1MjA5MDM4MX0.5OuvCnXb8gt8tt1vJyqaVN3YY35rxYljdFoTnUl3Vhg',
  );

  final activityService = ActivityService();
  await Permission.activityRecognition.request(); // Add permission request
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
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final session = snapshot.data!.session;
            if (session != null) {
              return FutureBuilder<bool>(
                future: _checkOnboardingStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData && snapshot.data == true) {
                    return HomeScreen(activityService: activityService);
                  }
                  return OnboardingScreen(activityService: activityService);
                },
              );
            }
          }
          return AuthScreen(activityService: activityService);
        },
      ),
    );
  }

  Future<bool> _checkOnboardingStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('users')
          .select('onboarding_completed')
          .eq('id', user.id)
          .single();
      return response['onboarding_completed'] ?? false;
    }
    return false;
  }
}
