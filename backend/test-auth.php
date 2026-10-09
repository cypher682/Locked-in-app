<?php

require_once __DIR__ . '/vendor/autoload.php';

use Dotenv\Dotenv;

// Load environment variables
$dotenv = Dotenv::createImmutable(__DIR__);
$dotenv->load();

echo "=== Backend Authentication Test ===\n\n";

// Test 1: Check environment variables
echo "1. Environment Variables:\n";
echo "   FIREBASE_PROJECT_ID: " . ($_ENV['FIREBASE_PROJECT_ID'] ?? 'NOT SET') . "\n";
echo "   FIREBASE_CREDENTIALS_PATH: " . ($_ENV['FIREBASE_CREDENTIALS_PATH'] ?? 'NOT SET') . "\n";
echo "   JWT_SECRET: " . (isset($_ENV['JWT_SECRET']) ? 'SET (' . strlen($_ENV['JWT_SECRET']) . ' chars)' : 'NOT SET') . "\n";
echo "   SUPABASE_URL: " . ($_ENV['SUPABASE_URL'] ?? 'NOT SET') . "\n\n";

// Test 2: Check Firebase credentials file
$credentialsPath = __DIR__ . '/' . $_ENV['FIREBASE_CREDENTIALS_PATH'];
echo "2. Firebase Credentials File:\n";
echo "   Path: $credentialsPath\n";
echo "   Exists: " . (file_exists($credentialsPath) ? 'YES' : 'NO') . "\n";
if (file_exists($credentialsPath)) {
    echo "   Readable: " . (is_readable($credentialsPath) ? 'YES' : 'NO') . "\n";
    echo "   Size: " . filesize($credentialsPath) . " bytes\n";
    
    // Try to parse JSON
    $content = file_get_contents($credentialsPath);
    $json = json_decode($content, true);
    if ($json) {
        echo "   Valid JSON: YES\n";
        echo "   Project ID: " . ($json['project_id'] ?? 'NOT FOUND') . "\n";
        echo "   Client Email: " . ($json['client_email'] ?? 'NOT FOUND') . "\n";
    } else {
        echo "   Valid JSON: NO - " . json_last_error_msg() . "\n";
    }
}
echo "\n";

// Test 3: Try to initialize Firebase
echo "3. Firebase Initialization:\n";
try {
    $factory = (new \Kreait\Firebase\Factory)
        ->withServiceAccount($credentialsPath);
    
    $auth = $factory->createAuth();
    echo "   Status: SUCCESS\n";
    echo "   Firebase Auth initialized successfully\n";
} catch (\Exception $e) {
    echo "   Status: FAILED\n";
    echo "   Error: " . $e->getMessage() . "\n";
}
echo "\n";

// Test 4: Check Supabase connection
echo "4. Supabase Connection:\n";
try {
    $supabaseUrl = $_ENV['SUPABASE_URL'];
    $supabaseKey = $_ENV['SUPABASE_SERVICE_KEY'];
    
    $ch = curl_init($supabaseUrl . '/rest/v1/');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'apikey: ' . $supabaseKey,
        'Authorization: Bearer ' . $supabaseKey
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode === 200 || $httpCode === 404) {
        echo "   Status: SUCCESS (HTTP $httpCode)\n";
        echo "   Supabase is reachable\n";
    } else {
        echo "   Status: FAILED (HTTP $httpCode)\n";
    }
} catch (\Exception $e) {
    echo "   Status: FAILED\n";
    echo "   Error: " . $e->getMessage() . "\n";
}
echo "\n";

echo "=== Test Complete ===\n";
