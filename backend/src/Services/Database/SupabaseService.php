<?php

namespace App\Services\Database;

class SupabaseService
{
    private string $supabaseUrl;
    private string $supabaseKey;

    public function __construct()
    {
        $this->supabaseUrl = $_ENV['SUPABASE_URL'];
        $this->supabaseKey = $_ENV['SUPABASE_SERVICE_KEY'];
    }

    private function request(string $method, string $endpoint, ?array $data = null): array
    {
        $url = $this->supabaseUrl . '/rest/v1/' . $endpoint;
        
        $headers = [
            'apikey: ' . $this->supabaseKey,
            'Authorization: Bearer ' . $this->supabaseKey,
            'Content-Type: application/json',
            'Prefer: return=representation'
        ];

        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        
        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        } elseif ($method === 'PATCH') {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH');
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        return [
            'status' => $httpCode,
            'data' => json_decode($response, true)
        ];
    }

    public function findUserByFirebaseUid(string $firebaseUid): ?array
    {
        $response = $this->request('GET', "users?firebase_uid=eq.$firebaseUid&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function createUser(array $userData): ?array
    {
        $response = $this->request('POST', 'users', $userData);
        
        if ($response['status'] === 201 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function updateUser(string $userId, array $userData): ?array
    {
        $response = $this->request('PATCH', "users?id=eq.$userId", $userData);
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    // ==================== Goal Methods ====================

    public function createGoal(array $goalData): ?array
    {
        $response = $this->request('POST', 'goals', $goalData);
        
        if ($response['status'] === 201 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function findGoalsByUserId(string $userId, int $limit = 50, int $offset = 0): array
    {
        $response = $this->request('GET', "goals?user_id=eq.$userId&deleted_at=is.null&select=*&order=created_at.desc&limit=$limit&offset=$offset");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    public function findGoalById(string $goalId): ?array
    {
        $response = $this->request('GET', "goals?id=eq.$goalId&deleted_at=is.null&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function updateGoal(string $goalId, array $goalData): ?array
    {
        $response = $this->request('PATCH', "goals?id=eq.$goalId", $goalData);
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function deleteGoal(string $goalId): bool
    {
        // Soft delete by setting deleted_at timestamp
        $response = $this->request('PATCH', "goals?id=eq.$goalId", [
            'deleted_at' => date('Y-m-d H:i:s')
        ]);
        
        return $response['status'] === 200;
    }

    // ==================== Check-in Methods ====================

    public function createCheckin(array $checkinData): ?array
    {
        $response = $this->request('POST', 'checkins', $checkinData);
        
        if ($response['status'] === 201 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function findCheckinsByGoalId(string $goalId, int $limit = 50, int $offset = 0): array
    {
        $response = $this->request('GET', "checkins?goal_id=eq.$goalId&deleted_at=is.null&select=*&order=created_at.desc&limit=$limit&offset=$offset");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    public function findCheckinsByUserId(string $userId, int $limit = 50, int $offset = 0): array
    {
        $response = $this->request('GET', "checkins?user_id=eq.$userId&deleted_at=is.null&select=*,goals(title,status)&order=created_at.desc&limit=$limit&offset=$offset");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    public function findCheckinById(string $checkinId): ?array
    {
        $response = $this->request('GET', "checkins?id=eq.$checkinId&deleted_at=is.null&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function updateCheckin(string $checkinId, array $checkinData): ?array
    {
        $response = $this->request('PATCH', "checkins?id=eq.$checkinId", $checkinData);
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function deleteCheckin(string $checkinId): bool
    {
        // Soft delete by setting deleted_at timestamp
        $response = $this->request('PATCH', "checkins?id=eq.$checkinId", [
            'deleted_at' => date('Y-m-d H:i:s')
        ]);
        
        return $response['status'] === 200;
    }

    public function getUserStreak(string $userId): array
    {
        $response = $this->request('GET', "user_streaks?user_id=eq.$userId&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return [
            'current_streak' => 0,
            'longest_streak' => 0,
            'total_checkins' => 0,
            'last_checkin_at' => null
        ];
    }

    // ==================== User Profile Methods ====================

    public function findUserById(string $userId): ?array
    {
        $response = $this->request('GET', "users?id=eq.$userId&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function findUserByUsername(string $username): ?array
    {
        $response = $this->request('GET', "users?username=eq.$username&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function searchUsers(string $query, int $limit = 20): array
    {
        // Search by username or display_name, only searchable users
        $response = $this->request('GET', "users?or=(username.ilike.*$query*,display_name.ilike.*$query*)&is_searchable=eq.true&select=id,username,display_name,avatar_url&limit=$limit");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    // ==================== Friendship Methods ====================

    public function createFriendship(array $friendshipData): ?array
    {
        $response = $this->request('POST', 'friendships', $friendshipData);
        
        if ($response['status'] === 201 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function findFriendshipById(string $friendshipId): ?array
    {
        $response = $this->request('GET', "friendships?id=eq.$friendshipId&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function findFriendshipBetween(string $userId1, string $userId2): ?array
    {
        // Check both directions
        $response = $this->request('GET', "friendships?or=(and(requester_id.eq.$userId1,addressee_id.eq.$userId2),and(requester_id.eq.$userId2,addressee_id.eq.$userId1))&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function findUserFriends(string $userId): array
    {
        // Get accepted friendships where user is either requester or addressee
        $response = $this->request('GET', "friendships?or=(requester_id.eq.$userId,addressee_id.eq.$userId)&status=eq.accepted&select=*,requester:users!requester_id(id,username,display_name,avatar_url),addressee:users!addressee_id(id,username,display_name,avatar_url)");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    public function findPendingRequests(string $userId): array
    {
        // Get pending requests where user is the addressee
        $response = $this->request('GET', "friendships?addressee_id=eq.$userId&status=eq.pending&select=*,requester:users!requester_id(id,username,display_name,avatar_url)");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    public function updateFriendship(string $friendshipId, array $data): ?array
    {
        $response = $this->request('PATCH', "friendships?id=eq.$friendshipId", $data);
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function deleteFriendship(string $friendshipId): bool
    {
        $response = $this->request('DELETE', "friendships?id=eq.$friendshipId", null);
        return $response['status'] === 204 || $response['status'] === 200;
    }

    // ==================== Like Methods ====================

    public function createLike(array $likeData): ?array
    {
        $response = $this->request('POST', 'likes', $likeData);
        
        if ($response['status'] === 201 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function findLike(string $userId, string $checkinId): ?array
    {
        $response = $this->request('GET', "likes?user_id=eq.$userId&checkin_id=eq.$checkinId&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function deleteLike(string $userId, string $checkinId): bool
    {
        $response = $this->request('DELETE', "likes?user_id=eq.$userId&checkin_id=eq.$checkinId", null);
        return $response['status'] === 204 || $response['status'] === 200;
    }

    public function getCheckinLikes(string $checkinId): array
    {
        $response = $this->request('GET', "likes?checkin_id=eq.$checkinId&select=*,user:users(id,username,display_name,avatar_url)");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    // ==================== Comment Methods ====================

    public function createComment(array $commentData): ?array
    {
        $response = $this->request('POST', 'comments', $commentData);
        
        if ($response['status'] === 201 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function findCommentById(string $commentId): ?array
    {
        $response = $this->request('GET', "comments?id=eq.$commentId&deleted_at=is.null&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function getCheckinComments(string $checkinId): array
    {
        $response = $this->request('GET', "comments?checkin_id=eq.$checkinId&deleted_at=is.null&select=*,user:users(id,username,display_name,avatar_url)&order=created_at.asc");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    public function deleteComment(string $commentId): bool
    {
        // Soft delete
        $response = $this->request('PATCH', "comments?id=eq.$commentId", [
            'deleted_at' => date('Y-m-d H:i:s')
        ]);
        
        return $response['status'] === 200;
    }

    // ==================== Feed Methods ====================

    public function getFeed(string $userId, int $limit = 20, int $offset = 0): array
    {
        // Get feed items from friends and public posts
        $response = $this->request('GET', "feed_items?select=*&order=created_at.desc&limit=$limit&offset=$offset");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    // ==================== Points Methods ====================

    public function createPointTransaction(array $data): ?array
    {
        $response = $this->request('POST', 'point_transactions', $data);
        
        if ($response['status'] === 201 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function getPointTransactions(string $userId, int $limit = 20): array
    {
        $response = $this->request('GET', "point_transactions?user_id=eq.$userId&select=*&order=created_at.desc&limit=$limit");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    // ==================== Leaderboard Methods ====================

    public function getLeaderboard(int $limit = 50): array
    {
        $response = $this->request('GET', "leaderboard?select=*&limit=$limit");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    public function getLeaderboardForUsers(array $userIds, int $limit = 50): array
    {
        $userIdsStr = implode(',', array_map(fn($id) => "\"$id\"", $userIds));
        $response = $this->request('GET', "leaderboard?user_id=in.($userIdsStr)&select=*&limit=$limit");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    // ==================== Achievement Methods ====================

    public function getAllAchievements(): array
    {
        $response = $this->request('GET', "achievements?select=*&order=category,threshold");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    public function findAchievementByCode(string $code): ?array
    {
        $response = $this->request('GET', "achievements?code=eq.$code&select=*");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function getUserAchievements(string $userId): array
    {
        $response = $this->request('GET', "user_achievements?user_id=eq.$userId&select=*,achievement:achievements(*)&order=unlocked_at.desc");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return $response['data'];
        }
        
        return [];
    }

    public function hasAchievement(string $userId, string $achievementCode): bool
    {
        $achievement = $this->findAchievementByCode($achievementCode);
        if (!$achievement) return false;
        
        $response = $this->request('GET', "user_achievements?user_id=eq.$userId&achievement_id=eq.{$achievement['id']}&select=id");
        
        return $response['status'] === 200 && !empty($response['data']);
    }

    public function unlockAchievement(string $userId, string $achievementId): ?array
    {
        $response = $this->request('POST', 'user_achievements', [
            'user_id' => $userId,
            'achievement_id' => $achievementId,
        ]);
        
        if ($response['status'] === 201 && !empty($response['data'])) {
            return $response['data'][0];
        }
        
        return null;
    }

    public function getUserCheckinCount(string $userId): int
    {
        $response = $this->request('GET', "checkins?user_id=eq.$userId&deleted_at=is.null&select=id");
        
        if ($response['status'] === 200 && !empty($response['data'])) {
            return count($response['data']);
        }
        
        return 0;
    }

    public function getUserFriendCount(string $userId): int
    {
        $friendships = $this->findUserFriends($userId);
        return count($friendships);
    }
}




