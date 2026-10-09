<?php

namespace App\Controllers\Leaderboard;

use App\Services\Database\SupabaseService;
use App\Middleware\Auth\AuthMiddleware;

class LeaderboardController
{
    private SupabaseService $db;
    private AuthMiddleware $auth;

    public function __construct()
    {
        $this->db = new SupabaseService();
        $this->auth = new AuthMiddleware();
    }

    /**
     * Get global leaderboard
     */
    public function getLeaderboard(): void
    {
        $this->auth->protect(function($user) {
            try {
                $limit = isset($_GET['limit']) ? (int) $_GET['limit'] : 50;
                $scope = $_GET['scope'] ?? 'global'; // 'global' or 'friends'

                if ($scope === 'friends') {
                    $leaderboard = $this->getFriendsLeaderboard($user['id'], $limit);
                } else {
                    $leaderboard = $this->db->getLeaderboard($limit);
                }

                // Find current user's rank
                $userRank = null;
                foreach ($leaderboard as $index => $entry) {
                    if ($entry['user_id'] === $user['id']) {
                        $userRank = $entry['rank'];
                        break;
                    }
                }

                // Format response
                $formattedLeaderboard = array_map(
                    fn($entry) => $this->formatLeaderboardEntry($entry, $user['id']),
                    $leaderboard
                );

                http_response_code(200);
                echo json_encode([
                    'leaderboard' => $formattedLeaderboard,
                    'userRank' => $userRank,
                    'scope' => $scope,
                ]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    /**
     * Get friends-only leaderboard
     */
    private function getFriendsLeaderboard(string $userId, int $limit): array
    {
        // Get friend IDs
        $friendships = $this->db->findUserFriends($userId);
        $friendIds = [$userId]; // Include self

        foreach ($friendships as $friendship) {
            if ($friendship['requester_id'] === $userId) {
                $friendIds[] = $friendship['addressee_id'];
            } else {
                $friendIds[] = $friendship['requester_id'];
            }
        }

        // Get leaderboard filtered by friends
        return $this->db->getLeaderboardForUsers($friendIds, $limit);
    }

    /**
     * Format leaderboard entry for API response
     */
    private function formatLeaderboardEntry(array $entry, string $currentUserId): array
    {
        return [
            'rank' => (int) $entry['rank'],
            'userId' => $entry['user_id'],
            'username' => $entry['username'] ?? null,
            'displayName' => $entry['display_name'],
            'avatarUrl' => $entry['avatar_url'] ?? null,
            'totalPoints' => (int) ($entry['total_points'] ?? 0),
            'isCurrentUser' => $entry['user_id'] === $currentUserId,
        ];
    }
}
