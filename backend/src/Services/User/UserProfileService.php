<?php

namespace App\Services\User;

class UserProfileService
{
    /**
     * Validate user profile data
     */
    public function validateProfileData(array $data, bool $isUpdate = false): array
    {
        $errors = [];

        // Username validation
        if (!empty($data['username'])) {
            if (strlen($data['username']) < 3 || strlen($data['username']) > 50) {
                $errors[] = 'Username must be between 3 and 50 characters';
            }
            if (!preg_match('/^[a-z0-9_-]+$/i', $data['username'])) {
                $errors[] = 'Username can only contain letters, numbers, underscores, and hyphens';
            }
        }

        // Display name validation
        if (!empty($data['display_name']) && strlen($data['display_name']) > 100) {
            $errors[] = 'Display name must not exceed 100 characters';
        }

        // Bio validation
        if (!empty($data['bio']) && strlen($data['bio']) > 500) {
            $errors[] = 'Bio must not exceed 500 characters';
        }

        return $errors;
    }

    /**
     * Prepare profile data for update
     */
    public function prepareProfileData(array $data): array
    {
        $profileData = [];

        if (isset($data['username'])) {
            $profileData['username'] = strtolower(trim($data['username']));
        }

        if (isset($data['display_name'])) {
            $profileData['display_name'] = $this->sanitize($data['display_name']);
        }

        if (isset($data['bio'])) {
            $profileData['bio'] = $this->sanitize($data['bio']);
        }

        if (isset($data['avatar_url'])) {
            $profileData['avatar_url'] = $data['avatar_url'];
        }

        if (isset($data['is_searchable'])) {
            $profileData['is_searchable'] = (bool) $data['is_searchable'];
        }

        return $profileData;
    }

    /**
     * Format user profile for API response
     */
    public function formatUserProfile(array $user): array
    {
        return [
            'id' => $user['id'],
            'username' => $user['username'] ?? null,
            'displayName' => $user['display_name'],
            'avatarUrl' => $user['avatar_url'] ?? null,
            'bio' => $user['bio'] ?? null,
            'isSearchable' => $user['is_searchable'] ?? true,
            'createdAt' => $user['created_at'],
        ];
    }

    /**
     * Format user for search results (minimal info)
     */
    public function formatSearchResult(array $user): array
    {
        return [
            'id' => $user['id'],
            'username' => $user['username'] ?? null,
            'displayName' => $user['display_name'],
            'avatarUrl' => $user['avatar_url'] ?? null,
        ];
    }

    /**
     * Sanitize user input
     */
    private function sanitize(string $input): string
    {
        return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
    }
}
