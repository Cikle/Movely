import 'dart:async';
import 'package:movely/models/activity.dart';

class ActivityService {
  final List<Activity> _activities = [];

  Future<void> startActivity(String activityType) async {
    // TODO: Implement activity start logic
  }

  Future<void> stopActivity() async {
    // TODO: Implement activity stop logic
  }

  Future<List<Activity>> getActivities() async {
    // TODO: Implement fetching activities from local storage or API
    return _activities;
  }

  Future<void> saveActivity(Activity activity) async {
    // TODO: Implement saving activity to local storage or API
    _activities.add(activity);
  }
}
