import 'package:flutter/material.dart';
import 'package:movely/screens/onboarding/welcome_screen.dart';
import 'package:movely/services/activity_service.dart';

class OnboardingScreen extends StatelessWidget {
  final ActivityService activityService;

  const OnboardingScreen({super.key, required this.activityService});

  @override
  Widget build(BuildContext context) {
    return WelcomeScreen(activityService: activityService);
  }
}
