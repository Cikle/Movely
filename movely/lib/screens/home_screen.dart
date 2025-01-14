import 'package:flutter/material.dart';
import 'package:movely/screens/auth_screen.dart';
import 'package:movely/services/activity_service.dart';
import 'package:movely/services/step_service.dart';
import 'package:movely/models/activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  final ActivityService activityService;

  const HomeScreen({super.key, required this.activityService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTracking = false;
  List<Activity> _activities = [];
  final StepService _stepService = StepService();
  int _steps = 0;
  int _totalSteps = 0;
  double _averageSteps = 0;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _initializeStepTracking();
  }

  Future<void> _initializeStepTracking() async {
    await _stepService.initializePedometer();
    _stepService.stepStream.listen((steps) {
      setState(() {
        _steps = steps;
      });
    });
    await _loadStepStats();
  }

  Future<void> _loadStepStats() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select('step_history, total_steps')
            .eq('id', userId)
            .single();
        
        final stepHistory = (userData['step_history'] as Map<String, dynamic>)['days'] as List;
        final today = DateTime.now().toUtc();
        final todayString = DateTime(today.year, today.month, today.day).toIso8601String();
        
        // Calculate average including today's steps
        var totalHistorySteps = 0;
        var daysCount = stepHistory.length;
        bool todayIncluded = false;
        
        for (var day in stepHistory) {
          if (day['date'] == todayString) {
            todayIncluded = true;
            totalHistorySteps += _steps; // Use current steps for today
          } else {
            totalHistorySteps += day['steps'] as int;
          }
        }
        
        // If today isn't in history, add it
        if (!todayIncluded && _steps > 0) {
          totalHistorySteps += _steps;
          daysCount++;
        }
        
        if (daysCount > 0) {
          _averageSteps = totalHistorySteps / daysCount;
        }
        
        setState(() {
          // Add today's steps to total if they're higher than what's stored
          final storedTotal = userData['total_steps'] as int? ?? 0;
          _totalSteps = storedTotal + _steps;
        });
      }
    } catch (e) {
      print('Error loading step stats: $e');
    }
  }

  @override
  void dispose() {
    _stepService.dispose();
    super.dispose();
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
      body: RefreshIndicator(
        onRefresh: _loadActivities,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _steps.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7-Day Avg',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _averageSteps.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Steps',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _totalSteps.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.directions_walk,
                    color: Colors.deepPurple.shade400,
                    size: 32,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => AuthScreen(
                        activityService: widget.activityService,
                      ),
                    ),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Sign Out (Debug)'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _isTracking
                        ? 'Tracking activity...'
                        : 'Start tracking your activity!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _toggleTracking,
                    child:
                        Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
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
                    title: Text(
                        '${activity.activityType} - ${activity.duration} seconds'),
                    subtitle: Text(
                        '${activity.startTime.toString()} - ${activity.endTime.toString()}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
