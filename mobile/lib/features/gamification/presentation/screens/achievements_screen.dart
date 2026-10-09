import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(achievementProvider.notifier).loadAchievements());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(achievementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : RefreshIndicator(
                  onRefresh: () => ref.read(achievementProvider.notifier).loadAchievements(),
                  child: Column(
                    children: [
                      // Progress header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber[600]!, Colors.orange[600]!],
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.white, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              '${state.unlockedAchievements.length} / ${state.allAchievements.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const Text('Achievements Unlocked', style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),

                      // Achievement grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: state.allAchievements.length,
                          itemBuilder: (context, index) {
                            final achievement = state.allAchievements[index];
                            final isUnlocked = state.unlockedCodes.contains(achievement['code']);
                            return _AchievementTile(
                              achievement: achievement,
                              isUnlocked: isUnlocked,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final dynamic achievement;
  final bool isUnlocked;

  const _AchievementTile({required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.amber[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? Colors.amber : Colors.grey[300]!,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement['icon'] ?? '🏅',
              style: TextStyle(
                fontSize: 32,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement['name'] ?? 'Achievement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.black87 : Colors.grey,
              ),
            ),
            if (isUnlocked)
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(achievement['icon'] ?? '🏅', style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Text(achievement['name'] ?? 'Achievement')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement['description'] ?? 'No description'),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.stars, color: Colors.amber[600], size: 18),
                const SizedBox(width: 4),
                Text('+${achievement['pointsReward'] ?? 0} points'),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.green[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isUnlocked ? '✓ Unlocked!' : '🔒 Locked',
                style: TextStyle(
                  color: isUnlocked ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
