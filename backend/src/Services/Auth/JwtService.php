<?php

namespace App\Services\Auth;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtService
{
    private string $secret;
    private int $expiry;

    public function __construct()
    {
        $this->secret = $_ENV['JWT_SECRET'];
        $this->expiry = (int)$_ENV['JWT_EXPIRY'];
    }

    public function generateToken(array $userData): string
    {
        $payload = [
            'iss' => $_ENV['APP_URL'],
            'aud' => $_ENV['APP_URL'],
            'iat' => time(),
            'exp' => time() + $this->expiry,
            'sub' => $userData['id'],
            'email' => $userData['email'],
            'name' => $userData['display_name']
        ];

        return JWT::encode($payload, $this->secret, 'HS256');
    }

    public function verifyToken(string $token): ?array
    {
        try {
            $decoded = JWT::decode($token, new Key($this->secret, 'HS256'));
            return (array)$decoded;
        } catch (\Exception $e) {
            return null;
        }
    }
}
