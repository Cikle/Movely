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
  int get steps => _isInitialized ? _steps - _initialSteps : 0;
  int get displaySteps => _displaySteps;

  bool _isNewDay() {
    final now = DateTime.now();
    final lastCheckDate = DateTime(_lastMidnightCheck.year, _lastMidnightCheck.month, _lastMidnightCheck.day);
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

    // Load saved steps from Supabase
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select('daily_steps, total_steps')
            .eq('id', userId)
            .single();
        _displaySteps = userData['daily_steps'] as int? ?? 0;
        _steps = _displaySteps;
        _initialSteps = 0; // Reset initial steps to maintain today's count
    } catch (e) {
      print('Error loading saved steps: $e');
    }

    // Start smooth update timer
    _smoothUpdateTimer?.cancel();
    _smoothUpdateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_displaySteps < steps) {
        _displaySteps = _displaySteps + 1;
        _stepsController.add(_displaySteps);
      }
    });
    _stepCountStream = Pedometer.stepCountStream;
    
    _stepCountSubscription?.cancel();
    _stepCountSubscription = _stepCountStream?.listen(
      (StepCount event) {
        if (!_isInitialized) {
          _initialSteps = event.steps;
          _isInitialized = true;
        }
        _steps = event.steps;
        _stepsController.add(steps);
        _saveSteps();
      },
      onError: (error) {
        print('Pedometer error: $error');
      },
    );
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
            .select('step_history, total_steps, daily_steps')
            .eq('id', userId)
            .single();
        
        var stepHistory = (userData['step_history'] as Map<String, dynamic>)['days'] as List;
        final currentDailySteps = steps;
        
        // Update or add today's entry
        bool foundToday = false;
        for (var i = 0; i < stepHistory.length; i++) {
          if (stepHistory[i]['date'] == today) {
            stepHistory[i]['steps'] = currentDailySteps;
            foundToday = true;
            break;
          }
        }
        
        if (!foundToday) {
          stepHistory.add({'date': today, 'steps': currentDailySteps});
        }
        
        // Keep only last 7 days
        if (stepHistory.length > 7) {
          stepHistory = stepHistory.sublist(stepHistory.length - 7);
        }
        
        // Calculate 7-day average including today's steps
        final weekTotal = stepHistory.fold<int>(
          0, (sum, day) => sum + (day['steps'] as int));
        final weekAverage = weekTotal / stepHistory.length;
        
        // Update total steps with the current daily steps increase
        final previousDailySteps = userData['daily_steps'] as int? ?? 0;
        final totalSteps = userData['total_steps'] as int? ?? 0;
        final stepIncrease = currentDailySteps - previousDailySteps;
        
        await Supabase.instance.client.from('users').update({
          'daily_steps': currentDailySteps,
          'total_steps': totalSteps + stepIncrease,
          'step_history': {'days': stepHistory},
          'week_average': weekAverage,
          'updated_at': now.toIso8601String(),
        }).eq('id', userId);
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
