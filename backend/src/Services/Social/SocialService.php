<?php

namespace App\Services\Social;

class SocialService
{
    /**
     * Format like for API response
     */
    public function formatLike(array $like): array
    {
        return [
            'id' => $like['id'],
            'userId' => $like['user_id'],
            'checkinId' => $like['checkin_id'],
            'user' => isset($like['user']) ? [
                'id' => $like['user']['id'],
                'username' => $like['user']['username'] ?? null,
                'displayName' => $like['user']['display_name'],
                'avatarUrl' => $like['user']['avatar_url'] ?? null,
            ] : null,
            'createdAt' => $like['created_at'],
        ];
    }

    /**
     * Format comment for API response
     */
    public function formatComment(array $comment): array
    {
        return [
            'id' => $comment['id'],
            'userId' => $comment['user_id'],
            'checkinId' => $comment['checkin_id'],
            'content' => $comment['content'],
            'user' => isset($comment['user']) ? [
                'id' => $comment['user']['id'],
                'username' => $comment['user']['username'] ?? null,
                'displayName' => $comment['user']['display_name'],
                'avatarUrl' => $comment['user']['avatar_url'] ?? null,
            ] : null,
            'createdAt' => $comment['created_at'],
        ];
    }

    /**
     * Validate comment content
     */
    public function validateComment(array $data): array
    {
        $errors = [];

        if (empty($data['content'])) {
            $errors[] = 'Comment content is required';
        }

        if (!empty($data['content']) && strlen($data['content']) > 500) {
            $errors[] = 'Comment must not exceed 500 characters';
        }

        return $errors;
    }

    /**
     * Sanitize comment content
     */
    public function sanitizeContent(string $content): string
    {
        return htmlspecialchars(trim($content), ENT_QUOTES, 'UTF-8');
    }
}
