<?php

namespace App\Services\Points;

use App\Services\Database\SupabaseService;

class PointsService
{
    private SupabaseService $db;

    // Point values
    public const POINTS_CHECKIN = 10;
    public const POINTS_STREAK_7 = 50;
    public const POINTS_STREAK_30 = 200;

    public function __construct()
    {
        $this->db = new SupabaseService();
    }

    /**
     * Award points for a check-in
     */
    public function awardCheckinPoints(string $userId, string $checkinId): int
    {
        $points = self::POINTS_CHECKIN;
        
        $this->createTransaction($userId, $points, 'checkin', $checkinId);
        $this->updateUserTotalPoints($userId, $points);

        return $points;
    }

    /**
     * Award streak bonus points
     */
    public function awardStreakBonus(string $userId, int $streakDays): int
    {
        $bonus = 0;

        // 7-day streak bonus (only award once per milestone)
        if ($streakDays === 7) {
            $bonus = self::POINTS_STREAK_7;
            $this->createTransaction($userId, $bonus, 'streak_7', null);
        }
        // 30-day streak bonus
        elseif ($streakDays === 30) {
            $bonus = self::POINTS_STREAK_30;
            $this->createTransaction($userId, $bonus, 'streak_30', null);
        }
        // Every 30 days after that
        elseif ($streakDays > 30 && $streakDays % 30 === 0) {
            $bonus = self::POINTS_STREAK_30;
            $this->createTransaction($userId, $bonus, 'streak_30', null);
        }

        if ($bonus > 0) {
            $this->updateUserTotalPoints($userId, $bonus);
        }

        return $bonus;
    }

    /**
     * Get user's total points
     */
    public function getUserPoints(string $userId): int
    {
        $user = $this->db->findUserById($userId);
        return $user['total_points'] ?? 0;
    }

    /**
     * Get user's point history
     */
    public function getPointHistory(string $userId, int $limit = 20): array
    {
        return $this->db->getPointTransactions($userId, $limit);
    }

    /**
     * Create a point transaction record
     */
    private function createTransaction(string $userId, int $points, string $reason, ?string $referenceId): void
    {
        $this->db->createPointTransaction([
            'user_id' => $userId,
            'points' => $points,
            'reason' => $reason,
            'reference_id' => $referenceId,
        ]);
    }

    /**
     * Update user's total points
     */
    private function updateUserTotalPoints(string $userId, int $pointsToAdd): void
    {
        $currentPoints = $this->getUserPoints($userId);
        $newTotal = $currentPoints + $pointsToAdd;
        
        $this->db->updateUser($userId, ['total_points' => $newTotal]);
    }

    /**
     * Format point transaction for API response
     */
    public function formatTransaction(array $transaction): array
    {
        return [
            'id' => $transaction['id'],
            'points' => $transaction['points'],
            'reason' => $transaction['reason'],
            'reasonLabel' => $this->getReasonLabel($transaction['reason']),
            'createdAt' => $transaction['created_at'],
        ];
    }

    /**
     * Get human-readable label for point reason
     */
    private function getReasonLabel(string $reason): string
    {
        return match($reason) {
            'checkin' => 'Check-in',
            'streak_7' => '7-Day Streak Bonus',
            'streak_30' => '30-Day Streak Bonus',
            'achievement' => 'Achievement Unlocked',
            default => ucfirst($reason),
        };
    }
}
