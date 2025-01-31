import 'package:flutter/material.dart';
import 'package:movely/screens/auth_screen.dart';
import 'package:movely/screens/search_screen.dart';
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
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _exp = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await _initializeStepTracking();
      await Future.wait([
        _loadActivities(),
        _loadStepStats(),
      ]);
      // Add daily login EXP and reload stats
      await widget.activityService.addDailyLoginExp();
      await _loadStepStats();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  Future<void> _initializeStepTracking() async {
    await _stepService.initializePedometer();
    _stepService.stepStream.listen((steps) {
      setState(() {
        _steps = steps;
      });
      _loadStepStats(); // Reload stats when steps update
    });
    await _loadStepStats();
  }

  Future<void> _loadStepStats() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select('step_history, total_steps, week_average, daily_steps, current_streak, longest_streak, exp')
            .eq('id', userId)
            .single();

        if (mounted) {
          setState(() {
            _totalSteps = userData['total_steps'] ?? 0;
            _averageSteps = (userData['week_average'] as num?)?.toDouble() ?? 0.0;
            _currentStreak = userData['current_streak'] ?? 0;
            _longestStreak = userData['longest_streak'] ?? 0;
            _exp = userData['exp'] ?? 0;
            // Update _steps only if it's less than the value from the database
            if (_steps < (userData['daily_steps'] ?? 0)) {
              _steps = userData['daily_steps'] ?? 0;
            }
          });
        }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    activityService: widget.activityService,
                  ),
                ),
              );
            },
          ),
        ],
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
                          'Current Login Streak',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '$_currentStreak',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.orange.shade400,
                              size: 24,
                            ),
                          ],
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
                          'Longest Login Streak',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '$_longestStreak',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.emoji_events,
                              color: Colors.amber.shade400,
                              size: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                          'EXP',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _exp.toString(),
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
