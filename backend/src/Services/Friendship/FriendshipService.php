<?php

namespace App\Services\Friendship;

class FriendshipService
{
    /**
     * Validate friendship request data
     */
    public function validateFriendRequest(array $data): array
    {
        $errors = [];

        if (empty($data['addressee_id'])) {
            $errors[] = 'User ID is required';
        }

        return $errors;
    }

    /**
     * Prepare friendship data
     */
    public function prepareFriendshipData(string $requesterId, string $addresseeId): array
    {
        return [
            'requester_id' => $requesterId,
            'addressee_id' => $addresseeId,
            'status' => 'pending',
        ];
    }

    /**
     * Check if user can modify friendship
     */
    public function canModifyFriendship(array $friendship, string $userId): bool
    {
        return $friendship['requester_id'] === $userId || $friendship['addressee_id'] === $userId;
    }

    /**
     * Check if user can accept friendship
     */
    public function canAcceptFriendship(array $friendship, string $userId): bool
    {
        return $friendship['addressee_id'] === $userId && $friendship['status'] === 'pending';
    }

    /**
     * Format friendship for API response
     */
    public function formatFriendship(array $friendship, string $currentUserId): array
    {
        // Determine who is the friend (not the current user)
        $friend = null;
        if ($friendship['requester_id'] === $currentUserId && isset($friendship['addressee'])) {
            $friend = $friendship['addressee'];
        } elseif ($friendship['addressee_id'] === $currentUserId && isset($friendship['requester'])) {
            $friend = $friendship['requester'];
        }

        return [
            'id' => $friendship['id'],
            'status' => $friendship['status'],
            'friend' => $friend ? [
                'id' => $friend['id'],
                'username' => $friend['username'] ?? null,
                'displayName' => $friend['display_name'],
                'avatarUrl' => $friend['avatar_url'] ?? null,
            ] : null,
            'createdAt' => $friendship['created_at'],
        ];
    }

    /**
     * Format friend request for API response
     */
    public function formatFriendRequest(array $friendship): array
    {
        return [
            'id' => $friendship['id'],
            'requester' => [
                'id' => $friendship['requester']['id'],
                'username' => $friendship['requester']['username'] ?? null,
                'displayName' => $friendship['requester']['display_name'],
                'avatarUrl' => $friendship['requester']['avatar_url'] ?? null,
            ],
            'createdAt' => $friendship['created_at'],
        ];
    }
}
