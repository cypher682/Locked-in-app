<?php

namespace App\Services\Feed;

class FeedService
{
    /**
     * Format feed item for API response
     */
    public function formatFeedItem(array $item): array
    {
        return [
            'id' => $item['checkin_id'],
            'user' => [
                'id' => $item['user_id'],
                'username' => $item['username'] ?? null,
                'displayName' => $item['display_name'],
                'avatarUrl' => $item['avatar_url'] ?? null,
            ],
            'goal' => [
                'id' => $item['goal_id'],
                'title' => $item['goal_title'],
                'category' => $item['goal_category'] ?? null,
                'visibility' => $item['goal_visibility'],
            ],
            'note' => $item['note'] ?? null,
            'photoUrl' => $item['photo_url'] ?? null,
            'likesCount' => (int) ($item['likes_count'] ?? 0),
            'commentsCount' => (int) ($item['comments_count'] ?? 0),
            'createdAt' => $item['created_at'],
        ];
    }

    /**
     * Check if user can view feed item based on visibility
     */
    public function canViewFeedItem(array $item, string $userId, array $friendIds): bool
    {
        // Own check-ins are always visible
        if ($item['user_id'] === $userId) {
            return true;
        }

        $visibility = $item['goal_visibility'] ?? 'private';

        // Public items are visible to all
        if ($visibility === 'public') {
            return true;
        }

        // Friends-only items visible to friends
        if ($visibility === 'friends_only' && in_array($item['user_id'], $friendIds)) {
            return true;
        }

        return false;
    }
}
