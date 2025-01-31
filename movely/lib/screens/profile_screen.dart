import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movely/services/activity_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final ActivityService activityService;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.activityService,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isFollowing = false;
  Map<String, dynamic>? _userData;
  List<dynamic> _following = [];
  List<dynamic> _followers = [];
  final _currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', widget.userId)
          .single();

      setState(() {
        _userData = data;
        _following = data['following'] ?? [];
        _followers = data['followers'] ?? [];
        _isFollowing = _followers.contains(_currentUserId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFollowing) {
        await Supabase.instance.client.rpc(
          'unfollow_user',
          params: {
            'follower_id': _currentUserId,
            'following_id': widget.userId,
          },
        );
      } else {
        await Supabase.instance.client.rpc(
          'follow_user',
          params: {
            'follower_id': _currentUserId,
            'following_id': widget.userId,
          },
        );
      }

      await _loadUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userData == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_userData!['username']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurple.shade400,
                  child: Text(
                    _userData!['display_name'][0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData!['display_name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${_userData!['username']}',
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Following', _following.length.toString()),
                _buildStatColumn('Followers', _followers.length.toString()),
                _buildStatColumn('Streak', 
                  (_userData!['current_streak'] ?? 0).toString()),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.userId != _currentUserId)
              ElevatedButton(
                onPressed: _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing 
                    ? Colors.grey[800] 
                    : Colors.deepPurple.shade400,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_isFollowing ? 'Following' : 'Follow'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
