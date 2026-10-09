<?php

namespace App\Controllers\Friendship;

use App\Services\Friendship\FriendshipService;
use App\Services\Database\SupabaseService;
use App\Middleware\Auth\AuthMiddleware;

class FriendshipController
{
    private FriendshipService $friendshipService;
    private SupabaseService $db;
    private AuthMiddleware $auth;

    public function __construct()
    {
        $this->friendshipService = new FriendshipService();
        $this->db = new SupabaseService();
        $this->auth = new AuthMiddleware();
    }

    public function sendFriendRequest(): void
    {
        $this->auth->protect(function($user) {
            try {
                $input = json_decode(file_get_contents('php://input'), true);

                // Validate input
                $errors = $this->friendshipService->validateFriendRequest($input);
                if (!empty($errors)) {
                    http_response_code(400);
                    echo json_encode(['error' => implode(', ', $errors)]);
                    return;
                }

                $addresseeId = $input['addressee_id'];

                // Check if trying to friend self
                if ($addresseeId === $user['id']) {
                    http_response_code(400);
                    echo json_encode(['error' => 'Cannot send friend request to yourself']);
                    return;
                }

                // Check if friendship already exists
                $existing = $this->db->findFriendshipBetween($user['id'], $addresseeId);
                if ($existing) {
                    http_response_code(400);
                    echo json_encode(['error' => 'Friend request already exists']);
                    return;
                }

                // Create friendship
                $friendshipData = $this->friendshipService->prepareFriendshipData($user['id'], $addresseeId);
                $friendship = $this->db->createFriendship($friendshipData);

                if (!$friendship) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to send friend request']);
                    return;
                }

                http_response_code(201);
                echo json_encode(['message' => 'Friend request sent', 'friendship' => $friendship]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getFriends(): void
    {
        $this->auth->protect(function($user) {
            try {
                $friendships = $this->db->findUserFriends($user['id']);

                $formattedFriends = array_map(
                    fn($f) => $this->friendshipService->formatFriendship($f, $user['id']),
                    $friendships
                );

                http_response_code(200);
                echo json_encode(['friends' => $formattedFriends]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function getPendingRequests(): void
    {
        $this->auth->protect(function($user) {
            try {
                $requests = $this->db->findPendingRequests($user['id']);

                $formattedRequests = array_map(
                    fn($r) => $this->friendshipService->formatFriendRequest($r),
                    $requests
                );

                http_response_code(200);
                echo json_encode(['requests' => $formattedRequests]);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function acceptFriendRequest(string $friendshipId): void
    {
        $this->auth->protect(function($user) use ($friendshipId) {
            try {
                $friendship = $this->db->findFriendshipById($friendshipId);

                if (!$friendship) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Friend request not found']);
                    return;
                }

                // Check if user can accept
                if (!$this->friendshipService->canAcceptFriendship($friendship, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Cannot accept this friend request']);
                    return;
                }

                // Update status to accepted
                $updated = $this->db->updateFriendship($friendshipId, ['status' => 'accepted']);

                if (!$updated) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to accept friend request']);
                    return;
                }

                http_response_code(200);
                echo json_encode(['message' => 'Friend request accepted']);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function declineFriendRequest(string $friendshipId): void
    {
        $this->auth->protect(function($user) use ($friendshipId) {
            try {
                $friendship = $this->db->findFriendshipById($friendshipId);

                if (!$friendship) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Friend request not found']);
                    return;
                }

                // Check if user can decline
                if (!$this->friendshipService->canAcceptFriendship($friendship, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Cannot decline this friend request']);
                    return;
                }

                // Update status to declined
                $updated = $this->db->updateFriendship($friendshipId, ['status' => 'declined']);

                if (!$updated) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to decline friend request']);
                    return;
                }

                http_response_code(200);
                echo json_encode(['message' => 'Friend request declined']);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }

    public function removeFriend(string $friendshipId): void
    {
        $this->auth->protect(function($user) use ($friendshipId) {
            try {
                $friendship = $this->db->findFriendshipById($friendshipId);

                if (!$friendship) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Friendship not found']);
                    return;
                }

                // Check if user can remove
                if (!$this->friendshipService->canModifyFriendship($friendship, $user['id'])) {
                    http_response_code(403);
                    echo json_encode(['error' => 'Cannot remove this friend']);
                    return;
                }

                // Delete friendship
                $success = $this->db->deleteFriendship($friendshipId);

                if (!$success) {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to remove friend']);
                    return;
                }

                http_response_code(200);
                echo json_encode(['message' => 'Friend removed']);

            } catch (\Exception $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        });
    }
}
