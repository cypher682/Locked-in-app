import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CommitStack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (user?['avatarUrl'] != null)
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user!['avatarUrl']),
                      )
                    else
                      const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person, size: 30),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?['displayName'] ?? 'User',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            user?['email'] ?? '',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Features Section
            Text(
              'Features',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Goals Card
            _FeatureCard(
              icon: Icons.flag,
              title: 'My Goals',
              description: 'Create and track your goals',
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/goals'),
            ),
            const SizedBox(height: 12),

            // Check-ins Card (Coming Soon)
            _FeatureCard(
              icon: Icons.check_circle_outline,
              title: 'Check-ins',
              description: 'Track your progress',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/checkins'),
            ),
            const SizedBox(height: 12),

            // Feed Card
            _FeatureCard(
              icon: Icons.feed_outlined,
              title: 'Feed',
              description: 'See what others are achieving',
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/feed'),
            ),
            const SizedBox(height: 12),

            // Leaderboard Card (Coming Soon)
            // Friends Card
            _FeatureCard(
              icon: Icons.people,
              title: 'Friends',
              description: 'Connect with meaningful people',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/friends'),
            ),
            const SizedBox(height: 12),

            // Profile Card
            _FeatureCard(
              icon: Icons.person,
              title: 'My Profile',
              description: 'Manage your identity',
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!enabled) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'SOON',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
