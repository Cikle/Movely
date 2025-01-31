import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movely/screens/profile_screen.dart';
import 'package:movely/services/activity_service.dart';

class ExploreScreen extends StatefulWidget {
  final ActivityService activityService;

  const ExploreScreen({super.key, required this.activityService});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  final _currentUserId = Supabase.instance.client.auth.currentUser?.id;
  List<String> _following = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user's following list
      final userData = await Supabase.instance.client
          .from('users')
          .select('following')
          .eq('id', _currentUserId)
          .single();
      
      final following = (userData['following'] as List?) ?? [];

      // Get all users
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .order('exp', ascending: false)
          .limit(50);

      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _following = following.map((id) => id.toString()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
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
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade400,
                      child: Text(
                        user['display_name'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(user['display_name']),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade400.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${user['exp']} EXP',
                            style: TextStyle(
                              color: Colors.deepPurple.shade200,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('@${user['username']}'),
                            if (_following.contains(user['id']))
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade400.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Following',
                                  style: TextStyle(
                                    color: Colors.deepPurple.shade200,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.orange.shade400,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text('${user['current_streak'] ?? 0} day streak'),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.directions_walk,
                              color: Colors.blue.shade400,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text('${user['total_steps'] ?? 0} steps'),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            userId: user['id'],
                            activityService: widget.activityService,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
