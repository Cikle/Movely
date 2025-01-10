import 'package:flutter/material.dart';
import 'package:movely/services/activity_service.dart';
import 'package:movely/models/activity.dart';

class HomeScreen extends StatefulWidget {
  final ActivityService activityService;

  const HomeScreen({super.key, required this.activityService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTracking = false;
  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final activities = await widget.activityService.getActivities();
    setState(() {
      _activities = activities;
    });
  }

  void _toggleTracking() async {
    setState(() {
      _isTracking = !_isTracking;
    });
    if (_isTracking) {
      await widget.activityService.startActivity('walking');
    } else {
      await widget.activityService.stopActivity();
      await _loadActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movely'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ListTile(
                  title: Text('${activity.activityType} - ${activity.duration} seconds'),
                  subtitle: Text('${activity.startTime.toString()} - ${activity.endTime.toString()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
