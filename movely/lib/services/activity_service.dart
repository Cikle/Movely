import 'dart:async';
import 'package:movely/models/activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ActivityService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Activity? _currentActivity;

  Future<int> addDailyLoginExp() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No user is currently logged in.');
    }

    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    final userData = await _supabase
        .from('users')
        .select('exp, last_login_date, current_streak, longest_streak')
        .eq('id', userId)
        .single();

    int currentExp = userData['exp'] ?? 0;
    String? lastLoginDate = userData['last_login_date'];
    int currentStreak = userData['current_streak'] ?? 0;
    int longestStreak = userData['longest_streak'] ?? 0;

    if (lastLoginDate != today) {
      const int dailyLoginExp = 50;
      currentExp += dailyLoginExp;

      // Update streak
      if (lastLoginDate == DateTime(now.year, now.month, now.day - 1).toIso8601String()) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      await _supabase.from('users').update({
        'exp': currentExp,
        'last_login_date': today,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
      }).eq('id', userId);

      return dailyLoginExp;
    }

    return 0;
  }

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
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in.');
    }

    final response = await _supabase
        .from('activities')
        .select()
        .eq('user_id', currentUser.id)
        .order('start_time', ascending: false);

    return (response as List).map((json) => Activity.fromJson(json)).toList();
  }

  Future<void> saveActivity(Activity activity) async {
    await _supabase.from('activities').insert(activity.toJson());
  }
}
