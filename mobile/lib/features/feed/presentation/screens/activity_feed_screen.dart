import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';
import '../../../social/presentation/providers/social_provider.dart';
import '../../../../shared/widgets/post_card.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Redesigned Activity Feed screen
class ActivityFeedScreen extends ConsumerStatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  ConsumerState<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends ConsumerState<ActivityFeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(feedProvider.notifier).loadFeed());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Removed pagination for now - can be added back when loadMoreFeed is implemented
  }

  void _handleLike(String checkinId, bool isLiked) {
    ref.read(socialProvider.notifier).toggleLike(checkinId);
  }

  void _handleComment(String checkinId) {
    // TODO: Show comments bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comments feature coming soon!')),
    );
  }

  void _handleShare(String checkinId) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: feedState.isLoading && feedState.feedItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : feedState.error != null && feedState.feedItems.isEmpty
              ? _buildErrorState(feedState.error!)
              : feedState.feedItems.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => ref.read(feedProvider.notifier).loadFeed(),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: feedState.feedItems.length,
                        itemBuilder: (context, index) {
                          final item = feedState.feedItems[index];
                          return PostCard(
                            userName: item['userName'] ?? 'Unknown',
                            userAvatar: item['userPhotoUrl'],
                            challengeTitle: item['goalTitle'] ?? 'Challenge',
                            description: item['notes'] ?? '',
                            imageUrl: item['photoUrl'],
                            timeAgo: _formatTimeAgo(item['createdAt']),
                            likes: item['likesCount'] ?? 0,
                            comments: item['commentsCount'] ?? 0,
                            shares: 0,
                            isLiked: item['isLiked'] ?? false,
                            onLike: () => _handleLike(item['id'], item['isLiked'] ?? false),
                            onComment: () => _handleComment(item['id']),
                            onShare: () => _handleShare(item['id']),
                            onUserTap: () {
                              // TODO: Navigate to user profile
                            },
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feed_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No activity yet',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start following friends to see their activity',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
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
            'Error loading feed',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              ref.read(feedProvider.notifier).loadFeed();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return 'Recently';
    
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
