import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/checkin_provider.dart';

class CheckinsListScreen extends ConsumerStatefulWidget {
  const CheckinsListScreen({super.key});

  @override
  ConsumerState<CheckinsListScreen> createState() => _CheckinsListScreenState();
}

class _CheckinsListScreenState extends ConsumerState<CheckinsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(checkinProvider.notifier).loadCheckins();
      ref.read(checkinProvider.notifier).loadStreak();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkinState = ref.watch(checkinProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Check-ins'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(checkinProvider.notifier).loadCheckins();
          await ref.read(checkinProvider.notifier).loadStreak();
        },
        child: checkinState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : checkinState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          checkinState.error!,
                          style: TextStyle(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(checkinProvider.notifier).loadCheckins();
                            ref.read(checkinProvider.notifier).loadStreak();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Streak Card
                      if (checkinState.streak != null)
                        _StreakCard(streak: checkinState.streak!),

                      // Check-ins List
                      Expanded(
                        child: checkinState.checkins.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No check-ins yet',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap the + button to create your first check-in',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: checkinState.checkins.length,
                                itemBuilder: (context, index) {
                                  final checkin = checkinState.checkins[index];
                                  return _CheckinCard(checkin: checkin);
                                },
                              ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/checkins/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final Map<String, dynamic> streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.deepOrange[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StreakStat(
            icon: Icons.local_fire_department,
            label: 'Current Streak',
            value: '${streak['currentStreak'] ?? 0}',
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          _StreakStat(
            icon: Icons.emoji_events,
            label: 'Longest Streak',
            value: '${streak['longestStreak'] ?? 0}',
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          _StreakStat(
            icon: Icons.check_circle,
            label: 'Total',
            value: '${streak['totalCheckins'] ?? 0}',
          ),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StreakStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _CheckinCard extends StatelessWidget {
  final Map<String, dynamic> checkin;

  const _CheckinCard({required this.checkin});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(checkin['createdAt'] ?? '');
    final formattedDate = createdAt != null
        ? DateFormat('MMM dd, yyyy • h:mm a').format(createdAt)
        : 'Unknown date';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/checkins/detail', arguments: checkin['id']);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo if exists
            if (checkin['photoUrl'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: checkin['photoUrl'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Goal title
                  if (checkin['goal'] != null)
                    Row(
                      children: [
                        Icon(Icons.flag, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            checkin['goal']['title'] ?? 'Unknown Goal',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Note
                  if (checkin['note'] != null)
                    Text(
                      checkin['note'],
                      style: const TextStyle(fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Date
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
