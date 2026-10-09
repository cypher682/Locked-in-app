import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/friendship_provider.dart';

class FriendsListScreen extends ConsumerStatefulWidget {
  const FriendsListScreen({super.key});

  @override
  ConsumerState<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends ConsumerState<FriendsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(friendshipProvider.notifier).loadFriends();
      ref.read(friendshipProvider.notifier).loadPendingRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendshipState = ref.watch(friendshipProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Friends'),
            Tab(text: 'Requests'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-friend');
            },
          ),
        ],
      ),
      body: friendshipState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(friendshipState.friends),
                _buildRequestsList(friendshipState.pendingRequests),
              ],
            ),
    );
  }

  Widget _buildFriendsList(List<dynamic> friends) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No friends yet'),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/add-friend');
              },
              child: const Text('Find Friends'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(friendshipProvider.notifier).loadFriends(),
      child: ListView.separated(
        itemCount: friends.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final friendship = friends[index];
          final friend = friendship['friend'];
          
          if (friend == null) return const SizedBox.shrink();

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: friend['avatarUrl'] != null
                  ? NetworkImage(friend['avatarUrl'])
                  : null,
              child: friend['avatarUrl'] == null
                  ? Text((friend['displayName'] ?? 'U')[0].toUpperCase())
                  : null,
            ),
            title: Text(friend['displayName'] ?? 'Unknown'),
            subtitle: Text('@${friend['username'] ?? 'unknown'}'),
            onTap: () {
               Navigator.of(context).pushNamed(
                '/user-profile',
                arguments: friend['id'],
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showFriendOptions(context, friendship['id'], friend['displayName']);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(List<dynamic> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text('No pending friend requests'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(friendshipProvider.notifier).loadPendingRequests(),
      child: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          final requester = request['requester'];

          if (requester == null) return const SizedBox.shrink();

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: requester['avatarUrl'] != null
                          ? NetworkImage(requester['avatarUrl'])
                          : null,
                      child: requester['avatarUrl'] == null
                          ? Text((requester['displayName'] ?? 'U')[0].toUpperCase())
                          : null,
                    ),
                    title: Text(requester['displayName'] ?? 'Unknown'),
                    subtitle: Text('@${requester['username'] ?? 'unknown'}'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          ref.read(friendshipProvider.notifier).declineFriendRequest(request['id']);
                        },
                        child: const Text('Decline', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(friendshipProvider.notifier).acceptFriendRequest(request['id']);
                        },
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFriendOptions(BuildContext context, String friendshipId, String? name) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: Text('Unfriend $name', style: const TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context); // Close sheet
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Unfriend'),
                    content: Text('Are you sure you want to remove $name from friends?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  ref.read(friendshipProvider.notifier).removeFriend(friendshipId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
