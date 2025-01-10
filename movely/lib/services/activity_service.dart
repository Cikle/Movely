import 'dart:async';
import 'package:movely/models/activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ActivityService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Activity? _currentActivity;

  Future<void> startActivity(String activityType) async {
    if (_currentActivity != null) {
      throw Exception('An activity is already in progress');
    }

    _currentActivity = Activity(
      id: const Uuid().v4(),
      userId: _supabase.auth.currentUser!.id,
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
    final response = await _supabase
        .from('activities')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id)
        .order('start_time', ascending: false);

    return (response as List).map((json) => Activity.fromJson(json)).toList();
  }

  Future<void> saveActivity(Activity activity) async {
    await _supabase.from('activities').insert(activity.toJson());
  }
}
