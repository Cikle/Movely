import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movely/screens/home_screen.dart';
import 'package:movely/services/activity_service.dart';

class OnboardingScreen extends StatefulWidget {
  final ActivityService activityService;

  const OnboardingScreen({Key? key, required this.activityService}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final List<String> _selectedActivities = [];
  String? _discoverySource;
  String? _ageBracket;
  String? _motivation;

  @override
  void initState() {
    super.initState();
    _usernameController.text = Supabase.instance.client.auth.currentUser?.email?.split('@')[0] ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_usernameController.text.isEmpty || _displayNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('users').upsert({
        'id': Supabase.instance.client.auth.currentUser!.id,
        'username': _usernameController.text,
        'display_name': _displayNameController.text,
        'onboarding_completed': true,
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(activityService: widget.activityService),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome to Movely!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  'Favorite Activities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                Wrap(
                  spacing: 8,
                  children: ['Running', 'Walking', 'Cycling', 'Swimming', 'Yoga'].map((activity) {
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _discoverySource,
                  onChanged: (value) {
                    setState(() {
                      _discoverySource = value;
                    });
                  },
                  items: ['App Store', 'Google Search', 'Friends/Family', 'Social Media']
                      .map((source) => DropdownMenuItem(value: source, child: Text(source)))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'How did you find us?',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.purple.shade900,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Complete Setup'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
