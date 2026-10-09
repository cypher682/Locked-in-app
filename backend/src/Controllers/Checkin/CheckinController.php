<?php

namespace App\Controllers\Checkin;

use App\Services\Checkin\CheckinService;
use App\Services\Database\SupabaseService;
use App\Services\Storage\StorageService;
use App\Services\Points\PointsService;
use App\Middleware\Auth\AuthMiddleware;

class CheckinController
{
    private CheckinService $checkinService;
    private SupabaseService $db;
    private StorageService $storage;
    private PointsService $pointsService;
    private AuthMiddleware $auth;

    public function __construct()
    {
        $this->checkinService = new CheckinService();
        $this->db = new SupabaseService();
        $this->storage = new StorageService();
        $this->pointsService = new PointsService();
        $this->auth = new AuthMiddleware();
    }

    public function createCheckin(): void
    {
        $this->auth->protect(function($user) {
            try {
                $input = json_decode(file_get_contents('php://input'), true);
                
                // Handle photo upload if base64 data provided
                if (!empty($input['photo_base64'])) {
                    $photoUrl = $this->storage->uploadPhoto($input['photo_base64'], $user['id']);
                    if ($photoUrl) {
                        $input['photo_url'] = $photoUrl;
                    }
                    unset($input['photo_base64']);
                }

                // Validate input
                $errors = $this->checkinService->validateCheckinData($input);
                if (!empty($errors)) {
                    http_response_code(400);
                    echo json_encode(['error' => implode(', ', $errors)]);
                    return;
                }

                // Verify user owns the goal
                $goal = $this->db->findGoalById($input['goal_id']);
                if (!$goal) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Goal not found']);
                    return;
                }

                if (!$this->checkinService->userOwnsGoal($goal, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Access denied']);
                    return;
                }

                // Prepare and create check-in
                $checkinData = $this->checkinService->prepareCheckinData($input, $user['id']);
                $checkin = $this->db->createCheckin($checkinData);

                if (!$checkin) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to create check-in']);
                    return;
                }

                // Award points for check-in
                $pointsEarned = $this->pointsService->awardCheckinPoints($user['id'], $checkin['id']);
                
                // Check for streak bonuses
                $streak = $this->db->getUserStreak($user['id']);
                $streakBonus = 0;
                if ($streak && isset($streak['current_streak'])) {
                    $streakBonus = $this->pointsService->awardStreakBonus($user['id'], $streak['current_streak']);
                }

                $response = $this->checkinService->formatCheckinResponse($checkin);
                $response['pointsEarned'] = $pointsEarned + $streakBonus;

                http_response_code(201);
                echo json_encode($response);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getGoalCheckins(string $goalId): void
    {
        $this->auth->protect(function($user) use ($goalId) {
            try {
                // Verify goal exists and user owns it
                $goal = $this->db->findGoalById($goalId);
                if (!$goal) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Goal not found']);
                    return;
                }

                if (!$this->checkinService->userOwnsGoal($goal, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Access denied']);
                    return;
                }

                $checkins = $this->db->findCheckinsByGoalId($goalId);
                
                $formattedCheckins = array_map(
                    fn($checkin) => $this->checkinService->formatCheckinResponse($checkin),
                    $checkins
                );

                http_response_code(200);
                echo json_encode(['checkins' => $formattedCheckins]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getUserCheckins(): void
    {
        $this->auth->protect(function($user) {
            try {
                $checkins = $this->db->findCheckinsByUserId($user['id']);
                
                $formattedCheckins = array_map(
                    fn($checkin) => $this->checkinService->formatCheckinResponse($checkin),
                    $checkins
                );

                http_response_code(200);
                echo json_encode(['checkins' => $formattedCheckins]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getCheckinById(string $checkinId): void
    {
        $this->auth->protect(function($user) use ($checkinId) {
            try {
                $checkin = $this->db->findCheckinById($checkinId);

                if (!$checkin) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Check-in not found']);
                    return;
                }

                // Check ownership
                if (!$this->checkinService->userOwnsCheckin($checkin, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Access denied']);
                    return;
                }

                http_response_code(200);
                echo json_encode($this->checkinService->formatCheckinResponse($checkin));

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function updateCheckin(string $checkinId): void
    {
        $this->auth->protect(function($user) use ($checkinId) {
            try {
                $input = json_decode(file_get_contents('php://input'), true);
                
                // Find existing check-in
                $checkin = $this->db->findCheckinById($checkinId);

                if (!$checkin) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Check-in not found']);
                    return;
                }

                // Check ownership
                if (!$this->checkinService->userOwnsCheckin($checkin, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Access denied']);
                    return;
                }

                // Validate update data
                $errors = $this->checkinService->validateCheckinData($input, true);
                if (!empty($errors)) {
                    http_response_code(400);
                    echo json_encode(['error' => implode(', ', $errors)]);
                    return;
                }

                // Update check-in
                $updatedCheckin = $this->db->updateCheckin($checkinId, $input);

                if (!$updatedCheckin) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to update check-in']);
                    return;
                }

                http_response_code(200);
                echo json_encode($this->checkinService->formatCheckinResponse($updatedCheckin));

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function deleteCheckin(string $checkinId): void
    {
        $this->auth->protect(function($user) use ($checkinId) {
            try {
                // Find existing check-in
                $checkin = $this->db->findCheckinById($checkinId);

                if (!$checkin) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Check-in not found']);
                    return;
                }

                // Check ownership
                if (!$this->checkinService->userOwnsCheckin($checkin, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Access denied']);
                    return;
                }

                // Delete photo if exists
                if (!empty($checkin['photo_url'])) {
                    $this->storage->deletePhoto($checkin['photo_url']);
                }

                // Soft delete check-in
                $success = $this->db->deleteCheckin($checkinId);

                if (!$success) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to delete check-in']);
                    return;
                }

                http_response_code(200);
                echo json_encode(['message' => 'Check-in deleted successfully']);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getUserStreak(): void
    {
        $this->auth->protect(function($user) {
            try {
                $streak = $this->db->getUserStreak($user['id']);

                http_response_code(200);
                echo json_encode($this->checkinService->formatStreakResponse($streak));

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }
}
