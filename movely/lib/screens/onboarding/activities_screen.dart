import 'package:flutter/material.dart';
import 'package:movely/screens/onboarding/discovery_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movely/services/activity_service.dart';

class ActivitiesScreen extends StatefulWidget {
  final ActivityService activityService;
  final String username;
  final String displayName;

  const ActivitiesScreen({
    Key? key,
    required this.activityService,
    required this.username,
    required this.displayName,
  }) : super(key: key);

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final List<String> _selectedActivities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What activities interest you?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select all that apply',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Running',
                  'Walking',
                  'Cycling',
                  'Swimming',
                  'Yoga',
                  'Hiking',
                  'Dancing',
                  'Gym',
                ].map((activity) {
                  return FilterChip(
                    label: Text(activity),
                    selected: _selectedActivities.contains(activity),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedActivities.add(activity);
                        } else {
                          _selectedActivities.remove(activity);
                        }
                      });
                    },
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: Colors.deepPurple.shade400,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedActivities.contains(activity)
                          ? Colors.white
                          : Colors.grey[400],
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text('Sign Out (Debug)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedActivities.isNotEmpty
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DiscoveryScreen(
                              activityService: widget.activityService,
                              username: widget.username,
                              displayName: widget.displayName,
                              selectedActivities: _selectedActivities,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
