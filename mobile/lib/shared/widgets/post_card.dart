import 'package:flutter/material.dart';
import 'user_avatar.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Post card for feed items
class PostCard extends StatelessWidget {
  final String userName;
  final String? userAvatar;
  final String challengeTitle;
  final String description;
  final String? imageUrl;
  final String timeAgo;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onUserTap;
  
  const PostCard({
    Key? key,
    required this.userName,
    this.userAvatar,
    required this.challengeTitle,
    required this.description,
    this.imageUrl,
    required this.timeAgo,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onUserTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            leading: UserAvatar(
              imageUrl: userAvatar,
              name: userName,
              size: 40,
              onTap: onUserTap,
            ),
            title: Text(
              userName,
              style: AppTextStyles.headingSmall,
            ),
            subtitle: Text(
              timeAgo,
              style: AppTextStyles.bodySmall,
            ),
          ),
          
          // Challenge title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              challengeTitle,
              style: AppTextStyles.headingMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              description,
              style: AppTextStyles.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Image
          if (imageUrl != null && imageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Icon(Icons.error),
              ),
            ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildActionButton(
                  context,
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: likes.toString(),
                  isActive: isLiked,
                  onTap: onLike,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  icon: Icons.comment_outlined,
                  label: comments.toString(),
                  onTap: onComment,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  icon: Icons.share_outlined,
                  label: shares.toString(),
                  onTap: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
