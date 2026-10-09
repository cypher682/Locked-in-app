<?php

namespace App\Controllers\Points;

use App\Services\Points\PointsService;
use App\Middleware\Auth\AuthMiddleware;

class PointsController
{
    private PointsService $pointsService;
    private AuthMiddleware $auth;

    public function __construct()
    {
        $this->pointsService = new PointsService();
        $this->auth = new AuthMiddleware();
    }

    /**
     * Get current user's points summary
     */
    public function getMyPoints(): void
    {
        $this->auth->protect(function($user) {
            try {
                $totalPoints = $this->pointsService->getUserPoints($user['id']);
                $history = $this->pointsService->getPointHistory($user['id'], 10);

                $formattedHistory = array_map(
                    fn($t) => $this->pointsService->formatTransaction($t),
                    $history
                );

                http_response_code(200);
                echo json_encode([
                    'totalPoints' => $totalPoints,
                    'recentHistory' => $formattedHistory,
                ]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    /**
     * Get full point history with pagination
     */
    public function getPointHistory(): void
    {
        $this->auth->protect(function($user) {
            try {
                $limit = isset($_GET['limit']) ? (int) $_GET['limit'] : 20;
                $history = $this->pointsService->getPointHistory($user['id'], $limit);

                $formattedHistory = array_map(
                    fn($t) => $this->pointsService->formatTransaction($t),
                    $history
                );

                http_response_code(200);
                echo json_encode(['history' => $formattedHistory]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }
}
