import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../../../gamification/presentation/providers/points_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile and points on init
    Future.microtask(() {
      ref.read(userProfileProvider.notifier).loadMyProfile();
      ref.read(pointsProvider.notifier).loadPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final pointsState = ref.watch(pointsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed('/edit-profile');
            },
          ),
        ],
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(profileState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(userProfileProvider.notifier).loadMyProfile();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : profileState.profile == null
                  ? const Center(child: Text('No profile data'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(userProfileProvider.notifier).loadMyProfile();
                        await ref.read(pointsProvider.notifier).loadPoints();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.blue[100],
                              backgroundImage: profileState.profile!['avatarUrl'] != null
                                  ? NetworkImage(profileState.profile!['avatarUrl'])
                                  : null,
                              child: profileState.profile!['avatarUrl'] == null
                                  ? Text(
                                      (profileState.profile!['displayName'] ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // Display Name
                            Text(
                              profileState.profile!['displayName'] ?? 'No name',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),

                            // Username
                            if (profileState.profile!['username'] != null)
                              Text(
                                '@${profileState.profile!['username']}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            const SizedBox(height: 24),

                            // Points Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.purple[600]!, Colors.blue[600]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stars, color: Colors.white, size: 40),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Points', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                      Text(
                                        '${pointsState.totalPoints}',
                                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Bio

                            // Privacy Status
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    profileState.profile!['isSearchable'] == true
                                        ? Icons.public
                                        : Icons.lock,
                                    color: profileState.profile!['isSearchable'] == true
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Profile Visibility',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          profileState.profile!['isSearchable'] == true
                                              ? 'Searchable by others'
                                              : 'Hidden from search',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Member Since
                            Text(
                              'Member since ${_formatDate(profileState.profile!['createdAt'])}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
