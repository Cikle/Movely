import 'package:flutter/material.dart';
import 'package:movely/services/activity_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActivityService _activityService = ActivityService();
  bool _isTracking = false;

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
    });
    if (_isTracking) {
      _activityService.startActivity('walking');
    } else {
      _activityService.stopActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movely'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isTracking ? 'Tracking activity...' : 'Start tracking your activity!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleTracking,
              child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
