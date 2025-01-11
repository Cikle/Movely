import 'package:flutter/material.dart';
import 'package:movely/screens/onboarding/discovery_screen.dart';
import 'package:movely/services/activity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgeBracketScreen extends StatefulWidget {
  final ActivityService activityService;
  final String username;
  final String displayName;
  final List<String> selectedActivities;

  const AgeBracketScreen({
    Key? key,
    required this.activityService,
    required this.username,
    required this.displayName,
    required this.selectedActivities,
  }) : super(key: key);

  @override
  _AgeBracketScreenState createState() => _AgeBracketScreenState();
}

class _AgeBracketScreenState extends State<AgeBracketScreen> {
  String? _selectedAgeBracket;

  final List<String> _ageBrackets = [
    'Under 18',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65+'
  ];

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
                'What\'s your age range?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us personalize your experience',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ageBrackets.map((bracket) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAgeBracket = bracket;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedAgeBracket == bracket
                            ? Colors.deepPurple.shade400
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        bracket,
                        style: TextStyle(
                          color: _selectedAgeBracket == bracket
                              ? Colors.white
                              : Colors.grey[400],
                        ),
                      ),
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
                onPressed: _selectedAgeBracket != null
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DiscoveryScreen(
                              activityService: widget.activityService,
                              username: widget.username,
                              displayName: widget.displayName,
                              selectedActivities: widget.selectedActivities,
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
