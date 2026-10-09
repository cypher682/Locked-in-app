<?php

namespace App\Controllers\Feed;

use App\Services\Feed\FeedService;
use App\Services\Database\SupabaseService;
use App\Middleware\Auth\AuthMiddleware;

class FeedController
{
    private FeedService $feedService;
    private SupabaseService $db;
    private AuthMiddleware $auth;

    public function __construct()
    {
        $this->feedService = new FeedService();
        $this->db = new SupabaseService();
        $this->auth = new AuthMiddleware();
    }

    /**
     * Get activity feed for the authenticated user
     * Shows friends' check-ins and public check-ins
     */
    public function getFeed(): void
    {
        $this->auth->protect(function($user) {
            try {
                $limit = isset($_GET['limit']) ? (int) $_GET['limit'] : 20;
                $offset = isset($_GET['offset']) ? (int) $_GET['offset'] : 0;

                // Get user's friend IDs
                $friendships = $this->db->findUserFriends($user['id']);
                $friendIds = [];
                foreach ($friendships as $friendship) {
                    if ($friendship['requester_id'] === $user['id']) {
                        $friendIds[] = $friendship['addressee_id'];
                    } else {
                        $friendIds[] = $friendship['requester_id'];
                    }
                }

                // Get feed items (all, then filter)
                $feedItems = $this->db->getFeed($user['id'], $limit * 2, $offset);

                // Filter by visibility
                $visibleItems = [];
                foreach ($feedItems as $item) {
                    if ($this->feedService->canViewFeedItem($item, $user['id'], $friendIds)) {
                        $visibleItems[] = $this->feedService->formatFeedItem($item);
                        if (count($visibleItems) >= $limit) {
                            break;
                        }
                    }
                }

                http_response_code(200);
                echo json_encode([
                    'feed' => $visibleItems,
                    'hasMore' => count($feedItems) > count($visibleItems),
                ]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }
}
