import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/checkin_provider.dart';

class CheckinDetailScreen extends ConsumerWidget {
  final String checkinId;

  const CheckinDetailScreen({super.key, required this.checkinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkinState = ref.watch(checkinProvider);
    final checkin = checkinState.checkins.firstWhere(
      (c) => c['id'] == checkinId,
      orElse: () => {},
    );

    if (checkin.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Check-in Details')),
        body: const Center(child: Text('Check-in not found')),
      );
    }

    final createdAt = DateTime.tryParse(checkin['createdAt'] ?? '');
    final formattedDate = createdAt != null
        ? DateFormat('MMMM dd, yyyy • h:mm a').format(createdAt)
        : 'Unknown date';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref, checkinId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo if exists
            if (checkin['photoUrl'] != null)
              CachedNetworkImage(
                imageUrl: checkin['photoUrl'],
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 64),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Goal Info
                  if (checkin['goal'] != null) ...[
                    _DetailSection(
                      icon: Icons.flag,
                      title: 'Goal',
                      child: Text(
                        checkin['goal']['title'] ?? 'Unknown Goal',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Note
                  if (checkin['note'] != null) ...[
                    _DetailSection(
                      icon: Icons.note,
                      title: 'Note',
                      child: Text(
                        checkin['note'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Date
                  _DetailSection(
                    icon: Icons.access_time,
                    title: 'Date',
                    child: Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String checkinId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Check-in'),
        content: const Text(
          'Are you sure you want to delete this check-in? This action cannot be undone.',
        ),
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
      final success = await ref.read(checkinProvider.notifier).deleteCheckin(checkinId);

      if (success && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in deleted successfully')),
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
