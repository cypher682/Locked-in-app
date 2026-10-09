<?php

namespace App\Services\Auth;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Auth as FirebaseAuth;

class FirebaseService
{
    private FirebaseAuth $auth;

    public function __construct()
    {
        // Option 1: Credentials as JSON string in env variable (for Railway/production)
        if (!empty($_ENV['FIREBASE_CREDENTIALS_JSON'])) {
            $credentials = json_decode($_ENV['FIREBASE_CREDENTIALS_JSON'], true);
            $factory = (new Factory)->withServiceAccount($credentials);
        }
        // Option 2: Credentials file path (for local development)
        elseif (!empty($_ENV['FIREBASE_CREDENTIALS_PATH'])) {
            $credentialsPath = __DIR__ . '/../../../' . $_ENV['FIREBASE_CREDENTIALS_PATH'];
            $factory = (new Factory)->withServiceAccount($credentialsPath);
        }
        else {
            throw new \Exception('Firebase credentials not configured');
        }
        
        $this->auth = $factory->createAuth();
    }

    public function verifyIdToken(string $idToken): array
    {
        try {
            $verifiedIdToken = $this->auth->verifyIdToken($idToken);
            
            return [
                'success' => true,
                'uid' => $verifiedIdToken->claims()->get('sub'),
                'email' => $verifiedIdToken->claims()->get('email'),
                'email_verified' => $verifiedIdToken->claims()->get('email_verified'),
                'name' => $verifiedIdToken->claims()->get('name'),
                'picture' => $verifiedIdToken->claims()->get('picture')
            ];
        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
}
