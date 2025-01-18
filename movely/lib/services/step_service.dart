import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StepService {
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;
  Timer? _smoothUpdateTimer;
  Timer? _midnightCheckTimer;
  int _steps = 0;
  int _initialSteps = 0;
  int _displaySteps = 0;
  bool _isInitialized = false;
  DateTime _lastMidnightCheck = DateTime.now();
  final _stepsController = StreamController<int>.broadcast();

  Stream<int> get stepStream => _stepsController.stream;
  int get steps => _displaySteps;
  int get displaySteps => _displaySteps;

  bool _isNewDay() {
    final now = DateTime.now();
    final lastCheckDate = DateTime(_lastMidnightCheck.year,
        _lastMidnightCheck.month, _lastMidnightCheck.day);
    final todayDate = DateTime(now.year, now.month, now.day);
    return lastCheckDate.isBefore(todayDate);
  }

  Future<void> _checkAndResetSteps() async {
    if (_isNewDay()) {
      _steps = 0;
      _initialSteps = 0;
      _displaySteps = 0;
      _lastMidnightCheck = DateTime.now();
      await _saveSteps();
    }
  }

  Future<void> initializePedometer() async {
    _isInitialized = false;

    // Set up midnight check timer
    _midnightCheckTimer?.cancel();
    _midnightCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndResetSteps();
    });

    // Load saved steps from Supabase first
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select('daily_steps')
            .eq('id', userId)
            .single();
        
        if (userData['daily_steps'] != null) {
          _displaySteps = userData['daily_steps'];
          _steps = _displaySteps;
          _stepsController.add(_displaySteps);
        }
      }

      // Start step counting after loading initial value
      _stepCountStream = Pedometer.stepCountStream;

      _stepCountSubscription?.cancel();
      _stepCountSubscription = _stepCountStream?.listen(
        (StepCount event) {
          if (!_isInitialized) {
            _initialSteps = event.steps;
            _isInitialized = true;
          }
          final newSteps = event.steps - _initialSteps + _displaySteps;
          _steps = newSteps;
          _displaySteps = newSteps;
          _stepsController.add(_displaySteps);
          _saveSteps();
        },
        onError: (error) {
          print('Pedometer error: $error');
        },
      );
    } catch (e) {
      print('Error loading saved steps: $e');
    }

    // Start smooth update timer
    _smoothUpdateTimer?.cancel();
    _smoothUpdateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_displaySteps < steps) {
        _displaySteps = steps;
        _stepsController.add(_displaySteps);
      }
    });
  }

  Future<void> _saveSteps() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final now = DateTime.now().toUtc();
        final today = DateTime(now.year, now.month, now.day).toIso8601String();

        // Get current user data
        final userData = await Supabase.instance.client
            .from('users')
            .select('step_history, daily_steps, current_streak, longest_streak, last_streak_date')
            .eq('id', userId)
            .single();

        var stepHistory = (userData['step_history'] as Map<String, dynamic>)['days'] as List;
        final currentDailySteps = steps;
        
        // Update or add today's entry
        bool foundToday = false;
        bool metDailyGoal = false;
        const int DAILY_STEP_GOAL = 5000; // Configurable daily step goal
        
        for (var i = 0; i < stepHistory.length; i++) {
          if (stepHistory[i]['date'] == today) {
            // Only update if new step count is higher
            if (currentDailySteps > stepHistory[i]['steps']) {
              stepHistory[i]['steps'] = currentDailySteps;
              metDailyGoal = currentDailySteps >= DAILY_STEP_GOAL;
            }
            foundToday = true;
            break;
          }
        }

        if (!foundToday) {
          stepHistory.add({'date': today, 'steps': currentDailySteps});
          metDailyGoal = currentDailySteps >= DAILY_STEP_GOAL;
        }

        // Keep only last 7 days
        if (stepHistory.length > 7) {
          stepHistory = stepHistory.sublist(stepHistory.length - 7);
        }

        // Calculate 7-day average
        final weekTotal = stepHistory.fold<int>(0, (sum, day) => sum + (day['steps'] as int));
        final weekAverage = (weekTotal / stepHistory.length).toDouble();

        // Calculate total steps as sum of all historical steps
        final totalSteps = stepHistory.fold<int>(0, (sum, day) => sum + (day['steps'] as int));

        // Handle streak calculation
        var currentStreak = userData['current_streak'] ?? 0;
        var longestStreak = userData['longest_streak'] ?? 0;
        final lastStreakDate = DateTime.parse(userData['last_streak_date'] ?? today);
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        if (metDailyGoal) {
          if (lastStreakDate.year == yesterday.year && 
              lastStreakDate.month == yesterday.month && 
              lastStreakDate.day == yesterday.day) {
            // Yesterday's streak continues
            currentStreak++;
          } else if (lastStreakDate.year == now.year && 
                     lastStreakDate.month == now.month && 
                     lastStreakDate.day == now.day) {
            // Already counted today
          } else {
            // New streak starts
            currentStreak = 1;
          }
          
          // Update longest streak if current is higher
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        } else if (lastStreakDate.year != now.year || 
                   lastStreakDate.month != now.month || 
                   lastStreakDate.day != now.day - 1) {
          // Streak broken
          currentStreak = 0;
        }

        // Only update if we have more steps than previously saved
        if (currentDailySteps > (userData['daily_steps'] ?? 0)) {
          await Supabase.instance.client.from('users').update({
            'daily_steps': currentDailySteps,
            'total_steps': totalSteps,
            'step_history': {'days': stepHistory},
            'week_average': weekAverage,
            'current_streak': currentStreak,
            'longest_streak': longestStreak,
            'last_streak_date': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          }).eq('id', userId);
        }
      }
    } catch (e) {
      print('Error saving steps: $e');
    }
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _smoothUpdateTimer?.cancel();
    _midnightCheckTimer?.cancel();
    _stepsController.close();
  }
}
