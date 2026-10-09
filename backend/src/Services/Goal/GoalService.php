<?php

namespace App\Services\Goal;

class GoalService
{
    /**
     * Validate goal data
     */
    public function validateGoalData(array $data, bool $isUpdate = false): array
    {
        $errors = [];

        // Title validation (required for create, optional for update)
        if (!$isUpdate && empty($data['title'])) {
            $errors[] = 'Title is required';
        } elseif (!empty($data['title']) && strlen($data['title']) > 200) {
            $errors[] = 'Title must not exceed 200 characters';
        }

        // Description validation (optional, but check length if provided)
        if (!empty($data['description']) && strlen($data['description']) > 5000) {
            $errors[] = 'Description must not exceed 5000 characters';
        }

        // Category validation
        $validCategories = ['fitness', 'career', 'education', 'health', 'personal', 'other'];
        if (!empty($data['category']) && !in_array($data['category'], $validCategories)) {
            $errors[] = 'Invalid category. Must be one of: ' . implode(', ', $validCategories);
        }

        // Visibility validation
        $validVisibility = ['public', 'private', 'friends_only'];
        if (!empty($data['visibility']) && !in_array($data['visibility'], $validVisibility)) {
            $errors[] = 'Invalid visibility. Must be one of: ' . implode(', ', $validVisibility);
        }

        // Status validation
        $validStatuses = ['active', 'completed', 'abandoned'];
        if (!empty($data['status']) && !in_array($data['status'], $validStatuses)) {
            $errors[] = 'Invalid status. Must be one of: ' . implode(', ', $validStatuses);
        }

        // Target date validation
        if (!empty($data['target_date'])) {
            $date = \DateTime::createFromFormat('Y-m-d', $data['target_date']);
            if (!$date || $date->format('Y-m-d') !== $data['target_date']) {
                $errors[] = 'Invalid target_date format. Must be YYYY-MM-DD';
            }
        }

        return $errors;
    }

    /**
     * Prepare goal data for database insertion
     */
    public function prepareGoalData(array $data, string $userId): array
    {
        $goalData = [
            'user_id' => $userId,
            'title' => isset($data['title']) ? $this->sanitize($data['title']) : null,
            'description' => isset($data['description']) ? $this->sanitize($data['description']) : null,
            'category' => $data['category'] ?? null,
            'target_date' => $data['target_date'] ?? null,
            'visibility' => $data['visibility'] ?? 'public',
            'status' => $data['status'] ?? 'active'
        ];

        // Remove null values for cleaner database entries
        return array_filter($goalData, fn($value) => $value !== null);
    }

    /**
     * Sanitize user input to prevent XSS
     */
    private function sanitize(string $input): string
    {
        return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
    }

    /**
     * Check if user owns the goal
     */
    public function userOwnsGoal(array $goal, string $userId): bool
    {
        return $goal['user_id'] === $userId;
    }

    /**
     * Format goal for API response
     */
    public function formatGoalResponse(array $goal): array
    {
        return [
            'id' => $goal['id'],
            'userId' => $goal['user_id'],
            'title' => $goal['title'],
            'description' => $goal['description'] ?? null,
            'category' => $goal['category'] ?? null,
            'targetDate' => $goal['target_date'] ?? null,
            'visibility' => $goal['visibility'],
            'status' => $goal['status'],
            'createdAt' => $goal['created_at'],
            'updatedAt' => $goal['updated_at']
        ];
    }
}
