import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/leaderboard_provider.dart';
import '../../../../shared/widgets/ranking_tile.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

/// Redesigned Leaderboard screen matching design references
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _selectedScope = 'global';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(leaderboardProvider.notifier).loadLeaderboard());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                  label: '30 Days Code Challenge',
                  icon: Icons.code,
                  isSelected: _selectedScope == 'global',
                  onTap: () {
                    setState(() => _selectedScope = 'global');
                    ref.read(leaderboardProvider.notifier).switchScope('global');
                  },
                ),
                _buildFilterChip(
                  label: '7 Days Meditation',
                  icon: Icons.self_improvement,
                  isSelected: _selectedScope == 'friends',
                  onTap: () {
                    setState(() => _selectedScope = 'friends');
                    ref.read(leaderboardProvider.notifier).switchScope('friends');
                  },
                ),
              ],
            ),
          ),
          
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top Active Users',
                style: AppTextStyles.headingLarge,
              ),
            ),
          ),
          
          // Leaderboard List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.error!,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                ref.read(leaderboardProvider.notifier).loadLeaderboard(scope: _selectedScope);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : state.entries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No leaderboard entries yet',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(leaderboardProvider.notifier).loadLeaderboard(scope: _selectedScope),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              itemCount: state.entries.length,
                              itemBuilder: (context, index) {
                                final entry = state.entries[index];
                                return RankingTile(
                                  rank: entry['rank'] ?? index + 1,
                                  userName: entry['displayName'] ?? 'Unknown',
                                  userAvatar: entry['photoUrl'],
                                  points: entry['totalPoints'] ?? 0,
                                  onTap: () {
                                    // TODO: Navigate to user profile
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}
