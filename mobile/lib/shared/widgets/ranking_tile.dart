import 'package:flutter/material.dart';
import 'user_avatar.dart';
import '../../core/theme/app_text_styles.dart';

/// Leaderboard ranking tile
class RankingTile extends StatelessWidget {
  final int rank;
  final String userName;
  final String? userAvatar;
  final int points;
  final VoidCallback? onTap;
  
  const RankingTile({
    Key? key,
    required this.rank,
    required this.userName,
    this.userAvatar,
    required this.points,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRankBadge(context),
          const SizedBox(width: 12),
          UserAvatar(
            imageUrl: userAvatar,
            name: userName,
            size: 48,
          ),
        ],
      ),
      title: Text(
        userName,
        style: AppTextStyles.headingSmall,
      ),
      subtitle: Text(
        _getRankLabel(rank),
        style: AppTextStyles.bodySmall.copyWith(
          color: _getRankColor(context, rank),
        ),
      ),
      trailing: Text(
        points.toString(),
        style: AppTextStyles.headingMedium.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
  
  Widget _buildRankBadge(BuildContext context) {
    final color = _getRankColor(context, rank);
    final isTopThree = rank <= 3;
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isTopThree ? color.withOpacity(0.15) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isTopThree ? color : Theme.of(context).dividerColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: AppTextStyles.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
  
  String _getRankLabel(int rank) {
    switch (rank) {
      case 1:
        return '1st place';
      case 2:
        return '2nd place';
      case 3:
        return '3rd place';
      default:
        return '${rank}th place';
    }
  }
  
  Color _getRankColor(BuildContext context, int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}
