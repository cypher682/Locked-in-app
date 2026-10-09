<?php

namespace App\Services\Checkin;

class CheckinService
{
    /**
     * Validate check-in data
     */
    public function validateCheckinData(array $data, bool $isUpdate = false): array
    {
        $errors = [];

        // Goal ID validation (required for create)
        if (!$isUpdate && empty($data['goal_id'])) {
            $errors[] = 'Goal ID is required';
        }

        // Content validation (note or photo required)
        if (!$isUpdate && empty($data['note']) && empty($data['photo_url'])) {
            $errors[] = 'Either note or photo is required';
        }

        // Note validation (optional, but check length if provided)
        if (!empty($data['note']) && strlen($data['note']) > 5000) {
            $errors[] = 'Note must not exceed 5000 characters';
        }

        // Photo URL validation (optional, but check format if provided)
        if (!empty($data['photo_url'])) {
            if (!filter_var($data['photo_url'], FILTER_VALIDATE_URL)) {
                $errors[] = 'Invalid photo URL format';
            }
        }

        return $errors;
    }

    /**
     * Prepare check-in data for database insertion
     */
    public function prepareCheckinData(array $data, string $userId): array
    {
        $checkinData = [
            'user_id' => $userId,
            'goal_id' => $data['goal_id'] ?? null,
            'note' => isset($data['note']) ? $this->sanitize($data['note']) : null,
            'photo_url' => $data['photo_url'] ?? null,
        ];

        // Remove null values for cleaner database entries
        return array_filter($checkinData, fn($value) => $value !== null);
    }

    /**
     * Sanitize user input to prevent XSS
     */
    private function sanitize(string $input): string
    {
        return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
    }

    /**
     * Check if user owns the check-in
     */
    public function userOwnsCheckin(array $checkin, string $userId): bool
    {
        return $checkin['user_id'] === $userId;
    }

    /**
     * Check if user owns the goal
     */
    public function userOwnsGoal(array $goal, string $userId): bool
    {
        return $goal['user_id'] === $userId;
    }

    /**
     * Format check-in for API response
     */
    public function formatCheckinResponse(array $checkin): array
    {
        return [
            'id' => $checkin['id'],
            'userId' => $checkin['user_id'],
            'goalId' => $checkin['goal_id'],
            'note' => $checkin['note'] ?? null,
            'photoUrl' => $checkin['photo_url'] ?? null,
            'createdAt' => $checkin['created_at'],
            'updatedAt' => $checkin['updated_at'],
            'goal' => $checkin['goals'] ?? null, // Include goal data if joined
        ];
    }

    /**
     * Format streak data for API response
     */
    public function formatStreakResponse(array $streak): array
    {
        return [
            'currentStreak' => (int)$streak['current_streak'],
            'longestStreak' => (int)$streak['longest_streak'],
            'totalCheckins' => (int)$streak['total_checkins'],
            'lastCheckinAt' => $streak['last_checkin_at'],
        ];
    }
}
