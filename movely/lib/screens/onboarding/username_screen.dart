import 'package:flutter/material.dart';
import 'package:movely/screens/onboarding/activities_screen.dart';
import 'package:movely/services/activity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsernameScreen extends StatefulWidget {
  final ActivityService activityService;

  const UsernameScreen({Key? key, required this.activityService}) : super(key: key);

  @override
  _UsernameScreenState createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = Supabase.instance.client.auth.currentUser?.email?.split('@')[0] ?? '';
    
    // Add listeners to update state when text changes
    _usernameController.addListener(() {
      setState(() {});
    });
    _displayNameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final username = _usernameController.text.trim();
    if (username.isEmpty || _displayNameController.text.trim().isEmpty) {
      return false;
    }
    
    // Username validation rules:
    // 1. Only letters, dots, and underscores
    // 2. Dots cannot be at start or end
    // 3. At least one character
    final RegExp usernameRegex = RegExp(r'^[a-zA-Z_][a-zA-Z._]*[a-zA-Z_]$');
    return usernameRegex.hasMatch(username);
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
                'Create your profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how others will see you',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
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
                onPressed: _isValid
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ActivitiesScreen(
                              activityService: widget.activityService,
                              username: _usernameController.text,
                              displayName: _displayNameController.text,
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
