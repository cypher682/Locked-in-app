<?php

namespace App\Services\Achievement;

use App\Services\Database\SupabaseService;

class AchievementService
{
    private SupabaseService $db;

    // Achievement codes
    public const FIRST_CHECKIN = 'first_checkin';
    public const CHECKINS_10 = 'checkins_10';
    public const CHECKINS_50 = 'checkins_50';
    public const CHECKINS_100 = 'checkins_100';
    public const STREAK_7 = 'streak_7';
    public const STREAK_30 = 'streak_30';
    public const STREAK_100 = 'streak_100';
    public const FIRST_FRIEND = 'first_friend';
    public const FRIENDS_10 = 'friends_10';

    public function __construct()
    {
        $this->db = new SupabaseService();
    }

    /**
     * Check and unlock achievements for a user after a check-in
     */
    public function checkCheckinAchievements(string $userId): array
    {
        $unlocked = [];

        // Get user's check-in count
        $checkinCount = $this->db->getUserCheckinCount($userId);

        // Check milestones
        if ($checkinCount >= 1) {
            $unlocked = array_merge($unlocked, $this->tryUnlock($userId, self::FIRST_CHECKIN));
        }
        if ($checkinCount >= 10) {
            $unlocked = array_merge($unlocked, $this->tryUnlock($userId, self::CHECKINS_10));
        }
        if ($checkinCount >= 50) {
            $unlocked = array_merge($unlocked, $this->tryUnlock($userId, self::CHECKINS_50));
        }
        if ($checkinCount >= 100) {
            $unlocked = array_merge($unlocked, $this->tryUnlock($userId, self::CHECKINS_100));
        }

        return $unlocked;
    }

    /**
     * Check and unlock streak achievements
     */
    public function checkStreakAchievements(string $userId, int $streakDays): array
    {
        $unlocked = [];

        if ($streakDays >= 7) {
            $unlocked = array_merge($unlocked, $this->tryUnlock($userId, self::STREAK_7));
        }
        if ($streakDays >= 30) {
            $unlocked = array_merge($unlocked, $this->tryUnlock($userId, self::STREAK_30));
        }
        if ($streakDays >= 100) {
            $unlocked = array_merge($unlocked, $this->tryUnlock($userId, self::STREAK_100));
        }

        return $unlocked;
    }

    /**
     * Check and unlock social achievements
     */
    public function checkSocialAchievements(string $userId): array
    {
        $unlocked = [];

        $friendCount = $this->db->getUserFriendCount($userId);

        if ($friendCount >= 1) {
            $unlocked = array_merge($unlocked, $this->tryUnlock($userId, self::FIRST_FRIEND));
        }
        if ($friendCount >= 10) {
            $unlocked = array_merge($unlocked, $this->tryUnlock($userId, self::FRIENDS_10));
        }

        return $unlocked;
    }

    /**
     * Try to unlock an achievement
     * Returns the achievement if newly unlocked, empty array otherwise
     */
    private function tryUnlock(string $userId, string $achievementCode): array
    {
        // Check if already unlocked
        if ($this->db->hasAchievement($userId, $achievementCode)) {
            return [];
        }

        // Get achievement details
        $achievement = $this->db->findAchievementByCode($achievementCode);
        if (!$achievement) {
            return [];
        }

        // Unlock achievement
        $userAchievement = $this->db->unlockAchievement($userId, $achievement['id']);
        if (!$userAchievement) {
            return [];
        }

        // Award achievement points
        if ($achievement['points_reward'] > 0) {
            $this->db->createPointTransaction([
                'user_id' => $userId,
                'points' => $achievement['points_reward'],
                'reason' => 'achievement',
                'reference_id' => $achievement['id'],
            ]);
            
            // Update user total points
            $user = $this->db->findUserById($userId);
            $newTotal = ($user['total_points'] ?? 0) + $achievement['points_reward'];
            $this->db->updateUser($userId, ['total_points' => $newTotal]);
        }

        return [$this->formatAchievement($achievement)];
    }

    /**
     * Get user's achievements
     */
    public function getUserAchievements(string $userId): array
    {
        return $this->db->getUserAchievements($userId);
    }

    /**
     * Get all available achievements
     */
    public function getAllAchievements(): array
    {
        return $this->db->getAllAchievements();
    }

    /**
     * Format achievement for API response
     */
    public function formatAchievement(array $achievement): array
    {
        return [
            'id' => $achievement['id'],
            'code' => $achievement['code'],
            'name' => $achievement['name'],
            'description' => $achievement['description'] ?? null,
            'icon' => $achievement['icon'] ?? '🏅',
            'pointsReward' => $achievement['points_reward'] ?? 0,
            'category' => $achievement['category'] ?? 'general',
        ];
    }

    /**
     * Format user achievement for API response
     */
    public function formatUserAchievement(array $userAchievement): array
    {
        $achievement = $userAchievement['achievement'] ?? $userAchievement;
        return [
            'id' => $achievement['id'] ?? $userAchievement['achievement_id'],
            'code' => $achievement['code'] ?? null,
            'name' => $achievement['name'] ?? 'Achievement',
            'description' => $achievement['description'] ?? null,
            'icon' => $achievement['icon'] ?? '🏅',
            'unlockedAt' => $userAchievement['unlocked_at'] ?? null,
        ];
    }
}
