import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_provider.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(goalProvider);
    final goal = goalState.goals.firstWhere(
      (g) => g['id'] == goalId,
      orElse: () => {},
    );

    if (goal.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goal Details')),
        body: const Center(child: Text('Goal not found')),
      );
    }

    final status = goal['status'] ?? 'active';
    final statusColor = status == 'completed'
        ? Colors.green
        : status == 'abandoned'
            ? Colors.red
            : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref, goalId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              goal['title'] ?? 'Untitled Goal',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            if (goal['description'] != null) ...[
              _DetailSection(
                icon: Icons.description,
                title: 'Description',
                child: Text(
                  goal['description'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Category
            if (goal['category'] != null) ...[
              _DetailSection(
                icon: Icons.category,
                title: 'Category',
                child: Text(
                  goal['category'][0].toUpperCase() + goal['category'].substring(1),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Target Date
            if (goal['targetDate'] != null) ...[
              _DetailSection(
                icon: Icons.calendar_today,
                title: 'Target Date',
                child: Text(
                  goal['targetDate'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Visibility
            _DetailSection(
              icon: Icons.visibility,
              title: 'Visibility',
              child: Text(
                _formatVisibility(goal['visibility'] ?? 'public'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Created Date
            _DetailSection(
              icon: Icons.access_time,
              title: 'Created',
              child: Text(
                goal['createdAt'] ?? 'Unknown',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            if (status == 'active') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(context, ref, goalId, 'completed'),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(context, ref, goalId, 'abandoned'),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Abandon'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatVisibility(String visibility) {
    switch (visibility) {
      case 'public':
        return 'Public - Everyone can see';
      case 'private':
        return 'Private - Only you can see';
      case 'friends_only':
        return 'Friends Only';
      default:
        return visibility;
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String goalId,
    String newStatus,
  ) async {
    final success = await ref.read(goalProvider.notifier).updateGoal(
      goalId,
      {'status': newStatus},
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Goal marked as $newStatus')),
      );
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String goalId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(goalProvider.notifier).deleteGoal(goalId);
      
      if (success && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal deleted successfully')),
        );
      }
    }
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
