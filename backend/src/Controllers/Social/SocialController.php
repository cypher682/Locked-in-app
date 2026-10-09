<?php

namespace App\Controllers\Social;

use App\Services\Social\SocialService;
use App\Services\Database\SupabaseService;
use App\Middleware\Auth\AuthMiddleware;

class SocialController
{
    private SocialService $socialService;
    private SupabaseService $db;
    private AuthMiddleware $auth;

    public function __construct()
    {
        $this->socialService = new SocialService();
        $this->db = new SupabaseService();
        $this->auth = new AuthMiddleware();
    }

    // ==================== Like Endpoints ====================

    public function likeCheckin(string $checkinId): void
    {
        $this->auth->protect(function($user) use ($checkinId) {
            try {
                // Check if already liked
                $existing = $this->db->findLike($user['id'], $checkinId);
                if ($existing) {
                    http_response_code(200);
                    echo json_encode(['message' => 'Already liked']);
                    return;
                }

                // Create like
                $like = $this->db->createLike([
                    'user_id' => $user['id'],
                    'checkin_id' => $checkinId,
                ]);

                if (!$like) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to like']);
                    return;
                }

                http_response_code(201);
                echo json_encode(['message' => 'Liked', 'like' => $this->socialService->formatLike($like)]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function unlikeCheckin(string $checkinId): void
    {
        $this->auth->protect(function($user) use ($checkinId) {
            try {
                $success = $this->db->deleteLike($user['id'], $checkinId);

                http_response_code(200);
                echo json_encode(['message' => 'Unliked']);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getCheckinLikes(string $checkinId): void
    {
        $this->auth->protect(function($user) use ($checkinId) {
            try {
                $likes = $this->db->getCheckinLikes($checkinId);

                $formattedLikes = array_map(
                    fn($l) => $this->socialService->formatLike($l),
                    $likes
                );

                http_response_code(200);
                echo json_encode([
                    'likes' => $formattedLikes,
                    'count' => count($formattedLikes),
                    'userLiked' => !empty(array_filter($likes, fn($l) => $l['user_id'] === $user['id'])),
                ]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    // ==================== Comment Endpoints ====================

    public function addComment(string $checkinId): void
    {
        $this->auth->protect(function($user) use ($checkinId) {
            try {
                $input = json_decode(file_get_contents('php://input'), true);

                // Validate
                $errors = $this->socialService->validateComment($input);
                if (!empty($errors)) {
                    http_response_code(400);
                    echo json_encode(['error' => implode(', ', $errors)]);
                    return;
                }

                // Create comment
                $comment = $this->db->createComment([
                    'user_id' => $user['id'],
                    'checkin_id' => $checkinId,
                    'content' => $this->socialService->sanitizeContent($input['content']),
                ]);

                if (!$comment) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to add comment']);
                    return;
                }

                // Fetch with user info
                $fullComment = $this->db->findCommentById($comment['id']);

                http_response_code(201);
                echo json_encode(['comment' => $this->socialService->formatComment($fullComment ?? $comment)]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getCheckinComments(string $checkinId): void
    {
        $this->auth->protect(function($user) use ($checkinId) {
            try {
                $comments = $this->db->getCheckinComments($checkinId);

                $formattedComments = array_map(
                    fn($c) => $this->socialService->formatComment($c),
                    $comments
                );

                http_response_code(200);
                echo json_encode([
                    'comments' => $formattedComments,
                    'count' => count($formattedComments),
                ]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function deleteComment(string $commentId): void
    {
        $this->auth->protect(function($user) use ($commentId) {
            try {
                // Check ownership
                $comment = $this->db->findCommentById($commentId);
                if (!$comment) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Comment not found']);
                    return;
                }

                if ($comment['user_id'] !== $user['id']) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Not authorized']);
                    return;
                }

                $success = $this->db->deleteComment($commentId);

                http_response_code(200);
                echo json_encode(['message' => 'Comment deleted']);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }
}
