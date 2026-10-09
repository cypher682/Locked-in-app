import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/friendship_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.length < 2) return;

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final results = await ref.read(userProfileProvider.notifier).searchUsers(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search users';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by username',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          if (_isSearching)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))))
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
             const Expanded(child: Center(child: Text('No users found')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['avatarUrl'] != null
                          ? NetworkImage(user['avatarUrl'])
                          : null,
                      child: user['avatarUrl'] == null
                          ? Text((user['displayName'] ?? 'U')[0].toUpperCase())
                          : null,
                    ),
                    title: Text(user['displayName'] ?? 'Unknown'),
                    subtitle: Text('@${user['username'] ?? 'unknown'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () async {
                        final success = await ref
                            .read(friendshipProvider.notifier)
                            .sendFriendRequest(user['id']);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Friend request sent!'
                                  : 'Failed to send request'),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/user-profile',
                        arguments: user['id'],
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
