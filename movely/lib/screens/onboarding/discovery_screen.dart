import 'package:flutter/material.dart';
import 'package:movely/screens/home_screen.dart';
import 'package:movely/services/activity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscoveryScreen extends StatefulWidget {
  final ActivityService activityService;
  final String username;
  final String displayName;
  final List<String> selectedActivities;

  const DiscoveryScreen({
    Key? key,
    required this.activityService,
    required this.username,
    required this.displayName,
    required this.selectedActivities,
    required this.ageBracket,
  }) : super(key: key);

  final String ageBracket;

  @override
  _DiscoveryScreenState createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  String? _discoverySource;
  bool _isLoading = false;

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First check if user exists
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final existingUser = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      // Use insert if user doesn't exist, update if they do
      if (existingUser == null) {
        await Supabase.instance.client.from('users').insert({
          'id': userId,
          'username': widget.username,
          'display_name': widget.displayName,
          'favorite_activities': widget.selectedActivities,
          'age_bracket': widget.ageBracket.toString(),
          'discovery_source': _discoverySource,
          'onboarding_completed': true,
        });
      } else {
        await Supabase.instance.client.from('users').update({
          'username': widget.username,
          'display_name': widget.displayName,
          'favorite_activities': widget.selectedActivities,
          'discovery_source': _discoverySource,
          'onboarding_completed': true,
        }).eq('id', userId);
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(activityService: widget.activityService),
          ),
          (route) => false,
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                'One last thing...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'How did you find us?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'App Store',
                  'Google Search',
                  'Friends/Family',
                  'Social Media',
                  'Other'
                ].map((source) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _discoverySource = source;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _discoverySource == source
                            ? Colors.deepPurple.shade400
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        source,
                        style: TextStyle(
                          color: _discoverySource == source
                              ? Colors.white
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _discoverySource != null && !_isLoading
                    ? _completeOnboarding
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
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Complete Setup',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text('Sign Out (Debug)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
