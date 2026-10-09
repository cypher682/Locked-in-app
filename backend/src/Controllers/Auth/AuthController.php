<?php

namespace App\Controllers\Auth;

use App\Services\Auth\FirebaseService;
use App\Services\Auth\JwtService;
use App\Services\Database\SupabaseService;
use Exception;

class AuthController
{
    // 1. Property Promotion (PHP 8.0+): Cleaner constructor dependency injection
    public function __construct(
        private FirebaseService $firebase = new FirebaseService(),
        private JwtService $jwt = new JwtService(),
        private SupabaseService $db = new SupabaseService()
    ) {}

    public function login(): void
    {
        try {
            // 2. Extract Token Logic: Moved to a helper method
            $idToken = $this->extractBearerToken();

            // Note: We intentionally removed the fallback to 'body' tokens.
            // Mobile app is now updated to send headers correctly.
            if (!$idToken) {
                $this->jsonResponse(['error' => 'ID token is required in Authorization header'], 400);
                return;
            }

            // 3. Verify Firebase Token
            $firebaseUser = $this->firebase->verifyIdToken($idToken);

            if (!$firebaseUser['success']) {
                $this->jsonResponse([
                    'error' => 'Firebase verification failed',
                    'details' => $firebaseUser['error'] ?? 'Unknown error'
                ], 401);
                return;
            }

            // 4. Handle User Logic (Find or Create)
            $user = $this->handleUserSync($firebaseUser);

            if (!$user) {
                $this->jsonResponse(['error' => 'Failed to sync user database'], 500);
                return;
            }

            // 5. Generate Session Token
            $token = $this->jwt->generateToken($user);

            $this->jsonResponse([
                'token' => $token,
                'user' => $this->formatUserResponse($user)
            ], 200);

        } catch (Exception $e) {
            $this->jsonResponse(['error' => $e->getMessage()], 500);
        }
    }

    public function verify(): void
    {
        try {
            $token = $this->extractBearerToken();

            if (!$token) {
                $this->jsonResponse(['error' => 'No token provided'], 401);
                return;
            }

            $decoded = $this->jwt->verifyToken($token);

            if (!$decoded) {
                $this->jsonResponse(['error' => 'Invalid or expired token'], 401);
                return;
            }

            $this->jsonResponse([
                'valid' => true,
                'user' => [
                    'id' => $decoded['sub'],
                    'email' => $decoded['email'],
                    'name' => $decoded['name'] ?? null
                ]
            ], 200);

        } catch (Exception $e) {
            $this->jsonResponse(['error' => $e->getMessage()], 401);
        }
    }

    // --- Private Helper Methods ---

    /**
     * Extracts the Bearer token from the Authorization header.
     */
    private function extractBearerToken(): ?string
    {
        $headers = getallheaders();
        // Handle case-insensitivity of headers (e.g. authorization vs Authorization)
        $headers = array_change_key_case($headers, CASE_LOWER);
        $authHeader = $headers['authorization'] ?? '';

        if (!empty($authHeader) && preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return trim($matches[1]);
        }

        return null;
    }

    /**
     * Logic to find existing user or create a new one.
     */
    private function handleUserSync(array $firebaseUser): ?array
    {
        $user = $this->db->findUserByFirebaseUid($firebaseUser['uid']);

        if ($user) {
            return $user;
        }

        $userData = [
            'firebase_uid' => $firebaseUser['uid'],
            'email' => $firebaseUser['email'],
            'display_name' => $firebaseUser['name'] ?? null,
            'avatar_url' => $firebaseUser['picture'] ?? null,
            // Logic for provider detection
            'provider' => (str_contains($firebaseUser['email'] ?? '', 'google')) ? 'google' : 'email',
            'is_verified' => $firebaseUser['email_verified'] ?? false
        ];

        return $this->db->createUser($userData);
    }

    /**
     * Standardizes user response format.
     */
    private function formatUserResponse(array $user): array
    {
        return [
            'id' => $user['id'],
            'email' => $user['email'],
            'displayName' => $user['display_name'],
            'avatarUrl' => $user['avatar_url'],
            'isVerified' => (bool) $user['is_verified']
        ];
    }

    /**
     * Helper to send consistent JSON responses.
     */
    private function jsonResponse(array $data, int $statusCode): void
    {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }
}
