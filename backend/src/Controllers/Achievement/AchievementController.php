<?php

namespace App\Controllers\Achievement;

use App\Services\Achievement\AchievementService;
use App\Middleware\Auth\AuthMiddleware;

class AchievementController
{
    private AchievementService $achievementService;
    private AuthMiddleware $auth;

    public function __construct()
    {
        $this->achievementService = new AchievementService();
        $this->auth = new AuthMiddleware();
    }

    /**
     * Get all available achievements
     */
    public function getAllAchievements(): void
    {
        $this->auth->protect(function($user) {
            try {
                $achievements = $this->achievementService->getAllAchievements();

                $formatted = array_map(
                    fn($a) => $this->achievementService->formatAchievement($a),
                    $achievements
                );

                http_response_code(200);
                echo json_encode(['achievements' => $formatted]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    /**
     * Get current user's unlocked achievements
     */
    public function getMyAchievements(): void
    {
        $this->auth->protect(function($user) {
            try {
                $userAchievements = $this->achievementService->getUserAchievements($user['id']);

                $formatted = array_map(
                    fn($ua) => $this->achievementService->formatUserAchievement($ua),
                    $userAchievements
                );

                http_response_code(200);
                echo json_encode([
                    'achievements' => $formatted,
                    'count' => count($formatted),
                ]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }
}
