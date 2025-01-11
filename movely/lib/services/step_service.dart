import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StepService {
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;
  int _steps = 0;
  final _stepsController = StreamController<int>.broadcast();

  Stream<int> get stepStream => _stepsController.stream;
  int get steps => _steps;

  Future<void> initializePedometer() async {
    _stepCountStream = Pedometer.stepCountStream;
    
    _stepCountSubscription?.cancel();
    _stepCountSubscription = _stepCountStream?.listen(
      (StepCount event) {
        _steps = event.steps;
        _stepsController.add(_steps);
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
        await Supabase.instance.client.from('users').update({
          'daily_steps': _steps,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      }
    } catch (e) {
      print('Error saving steps: $e');
    }
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _stepsController.close();
  }
}
