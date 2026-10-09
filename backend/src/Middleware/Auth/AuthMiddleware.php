<?php

namespace App\Middleware\Auth;

use App\Services\Auth\JwtService;

class AuthMiddleware
{
    private JwtService $jwt;

    public function __construct()
    {
        $this->jwt = new JwtService();
    }

    /**
     * Verify JWT token and extract user info
     * Returns user data if valid, null if invalid
     */
    public function authenticate(): ?array
    {
        // Handle case-insensitivity of headers (matches AuthController approach)
        $headers = getallheaders();
        $headers = array_change_key_case($headers, CASE_LOWER);
        $authHeader = $headers['authorization'] ?? '';
        
        if (empty($authHeader) || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            http_response_code(401);
            header('Content-Type: application/json');
            echo json_encode(['error' => 'No token provided']);
            return null;
        }

        $token = trim($matches[1]);
        $decoded = $this->jwt->verifyToken($token);

        if (!$decoded) {
            http_response_code(401);
            header('Content-Type: application/json');
            echo json_encode(['error' => 'Invalid or expired token']);
            return null;
        }

        // Return user data from token
        return [
            'id' => $decoded['sub'],
            'email' => $decoded['email'],
            'name' => $decoded['name'] ?? null
        ];
    }

    /**
     * Middleware wrapper for protected routes
     * Executes callback with user data if authenticated
     */
    public function protect(callable $callback): void
    {
        $user = $this->authenticate();
        
        if ($user) {
            $callback($user);
        }
    }
}
