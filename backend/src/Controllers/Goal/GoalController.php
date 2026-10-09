<?php

namespace App\Controllers\Goal;

use App\Services\Goal\GoalService;
use App\Services\Database\SupabaseService;
use App\Middleware\Auth\AuthMiddleware;

class GoalController
{
    private GoalService $goalService;
    private SupabaseService $db;
    private AuthMiddleware $auth;

    public function __construct()
    {
        $this->goalService = new GoalService();
        $this->db = new SupabaseService();
        $this->auth = new AuthMiddleware();
    }

    public function createGoal(): void
    {
        $this->auth->protect(function($user) {
            try {
                $input = json_decode(file_get_contents('php://input'), true);
                
                // Validate input
                $errors = $this->goalService->validateGoalData($input);
                if (!empty($errors)) {
                    http_response_code(400);
                    echo json_encode(['error' => implode(', ', $errors)]);
                    return;
                }

                // Prepare and create goal
                $goalData = $this->goalService->prepareGoalData($input, $user['id']);
                $goal = $this->db->createGoal($goalData);

                if (!$goal) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to create goal']);
                    return;
                }

                http_response_code(201);
                echo json_encode($this->goalService->formatGoalResponse($goal));

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getUserGoals(): void
    {
        $this->auth->protect(function($user) {
            try {
                $goals = $this->db->findGoalsByUserId($user['id']);
                
                $formattedGoals = array_map(
                    fn($goal) => $this->goalService->formatGoalResponse($goal),
                    $goals
                );

                http_response_code(200);
                echo json_encode(['goals' => $formattedGoals]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getGoalById(string $goalId): void
    {
        $this->auth->protect(function($user) use ($goalId) {
            try {
                $goal = $this->db->findGoalById($goalId);

                if (!$goal) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Goal not found']);
                    return;
                }

                // Check ownership
                if (!$this->goalService->userOwnsGoal($goal, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Access denied']);
                    return;
                }

                http_response_code(200);
                echo json_encode($this->goalService->formatGoalResponse($goal));

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function updateGoal(string $goalId): void
    {
        $this->auth->protect(function($user) use ($goalId) {
            try {
                $input = json_decode(file_get_contents('php://input'), true);
                
                // Find existing goal
                $goal = $this->db->findGoalById($goalId);

                if (!$goal) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Goal not found']);
                    return;
                }

                // Check ownership
                if (!$this->goalService->userOwnsGoal($goal, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Access denied']);
                    return;
                }

                // Validate update data
                $errors = $this->goalService->validateGoalData($input, true);
                if (!empty($errors)) {
                    http_response_code(400);
                    echo json_encode(['error' => implode(', ', $errors)]);
                    return;
                }

                // Update goal
                $updatedGoal = $this->db->updateGoal($goalId, $input);

                if (!$updatedGoal) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to update goal']);
                    return;
                }

                http_response_code(200);
                echo json_encode($this->goalService->formatGoalResponse($updatedGoal));

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function deleteGoal(string $goalId): void
    {
        $this->auth->protect(function($user) use ($goalId) {
            try {
                // Find existing goal
                $goal = $this->db->findGoalById($goalId);

                if (!$goal) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Goal not found']);
                    return;
                }

                // Check ownership
                if (!$this->goalService->userOwnsGoal($goal, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Access denied']);
                    return;
                }

                // Soft delete
                $success = $this->db->deleteGoal($goalId);

                if (!$success) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to delete goal']);
                    return;
                }

                http_response_code(200);
                echo json_encode(['message' => 'Goal deleted successfully']);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }
}
