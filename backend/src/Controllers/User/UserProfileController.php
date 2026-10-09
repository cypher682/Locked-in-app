<?php

namespace App\Controllers\User;

use App\Services\User\UserProfileService;
use App\Services\Database\SupabaseService;
use App\Middleware\Auth\AuthMiddleware;

class UserProfileController
{
    private UserProfileService $profileService;
    private SupabaseService $db;
    private AuthMiddleware $auth;

    public function __construct()
    {
        $this->profileService = new UserProfileService();
        $this->db = new SupabaseService();
        $this->auth = new AuthMiddleware();
    }

    public function getMyProfile(): void
    {
        $this->auth->protect(function($user) {
            try {
                $profile = $this->db->findUserById($user['id']);

                if (!$profile) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Profile not found']);
                    return;
                }

                http_response_code(200);
                echo json_encode($this->profileService->formatUserProfile($profile));

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function updateMyProfile(): void
    {
        $this->auth->protect(function($user) {
            try {
                $input = json_decode(file_get_contents('php://input'), true);
                error_log("Update Profile Input: " . json_encode($input));
                error_log("User ID: " . $user['id']);

                // Validate input
                $errors = $this->profileService->validateProfileData($input, true);
                if (!empty($errors)) {
                    error_log("Validation errors: " . json_encode($errors));
                    http_response_code(400);
                    echo json_encode(['error' => implode(', ', $errors)]);
                    return;
                }

                // Check if username is taken (if changing username)
                if (!empty($input['username'])) {
                    $existing = $this->db->findUserByUsername($input['username']);
                    error_log("Username check - existing: " . json_encode($existing));
                    if ($existing && $existing['id'] !== $user['id']) {
                        error_log("Username already taken");
                        http_response_code(400);
                        echo json_encode(['error' => 'Username already taken']);
                        return;
                    }
                }

                // Prepare and update profile
                $profileData = $this->profileService->prepareProfileData($input);
                error_log("Prepared profile data: " . json_encode($profileData));
                
                $updatedProfile = $this->db->updateUser($user['id'], $profileData);
                error_log("Updated profile result: " . json_encode($updatedProfile));

                if (!$updatedProfile) {
                    error_log("Failed to update profile - updateUser returned null");
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to update profile']);
                    return;
                }

                http_response_code(200);
                echo json_encode($this->profileService->formatUserProfile($updatedProfile));

            } catch (\Exception $e) {
                error_log("Exception in updateMyProfile: " . $e->getMessage());
                error_log("Stack trace: " . $e->getTraceAsString());
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getUserProfile(string $userId): void
    {
        $this->auth->protect(function($user) use ($userId) {
            try {
                $profile = $this->db->findUserById($userId);

                if (!$profile) {
                    http_response_code(404);
                    echo json_encode(['error' => 'User not found']);
                    return;
                }

                http_response_code(200);
                echo json_encode($this->profileService->formatUserProfile($profile));

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function searchUsers(): void
    {
        $this->auth->protect(function($user) {
            try {
                $query = $_GET['q'] ?? '';

                if (strlen($query) < 2) {
                    http_response_code(400);
                    echo json_encode(['error' => 'Search query must be at least 2 characters']);
                    return;
                }

                $users = $this->db->searchUsers($query);

                $formattedUsers = array_map(
                    fn($u) => $this->profileService->formatSearchResult($u),
                    $users
                );

                http_response_code(200);
                echo json_encode(['users' => $formattedUsers]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }
}
