import 'dart:async';
import 'package:movely/models/activity.dart';
import 'dart:async';
import 'package:movely/models/activity.dart';

class ActivityService {
  Activity? _currentActivity;
  final List<Activity> _activities = [];

  Future<void> startActivity(String activityType) async {
    if (_currentActivity != null) {
      throw Exception('An activity is already in progress');
    }

    _currentActivity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'local-user',
      activityType: activityType,
      startTime: DateTime.now(),
      endTime: DateTime.now(), // Will be updated when stopping
      distance: 0,
      duration: 0,
      gpsData: {},
    );
  }

  Future<void> stopActivity() async {
    if (_currentActivity == null) {
      throw Exception('No activity in progress');
    }

    final endTime = DateTime.now();
    _currentActivity = _currentActivity!.copyWith(
      endTime: endTime,
      duration: endTime.difference(_currentActivity!.startTime).inSeconds,
    );

    await saveActivity(_currentActivity!);
    _currentActivity = null;
  }

  Future<List<Activity>> getActivities() async {
    return _activities;
  }

  Future<void> saveActivity(Activity activity) async {
    _activities.add(activity);
  }
}
