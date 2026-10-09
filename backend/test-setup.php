<?php
/**
 * Backend Setup Verification Script
 * Run this to check if your backend is configured correctly
 * 
 * Usage: php test-setup.php
 */

echo "🔍 CommitStack Backend Setup Verification\n";
echo "==========================================\n\n";

$errors = [];
$warnings = [];

// Check PHP version
echo "✓ Checking PHP version...\n";
$phpVersion = phpversion();
if (version_compare($phpVersion, '8.1.0', '<')) {
    $errors[] = "PHP version must be 8.1 or higher. Current: $phpVersion";
} else {
    echo "  ✅ PHP $phpVersion\n\n";
}

// Check if vendor directory exists
echo "✓ Checking Composer dependencies...\n";
if (!file_exists(__DIR__ . '/vendor/autoload.php')) {
    $errors[] = "Composer dependencies not installed. Run: composer install";
} else {
    echo "  ✅ Vendor directory exists\n\n";
}

// Check if .env file exists
echo "✓ Checking .env file...\n";
if (!file_exists(__DIR__ . '/.env')) {
    $errors[] = ".env file not found. Copy .env.example to .env and configure it";
} else {
    echo "  ✅ .env file exists\n\n";
    
    // Load .env
    require_once __DIR__ . '/vendor/autoload.php';
    $dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
    $dotenv->load();
    
    // Check required environment variables
    echo "✓ Checking environment variables...\n";
    $requiredVars = [
        'SUPABASE_URL',
        'SUPABASE_SERVICE_KEY',
        'FIREBASE_PROJECT_ID',
        'FIREBASE_CREDENTIALS_PATH',
        'JWT_SECRET'
    ];
    
    foreach ($requiredVars as $var) {
        if (empty($_ENV[$var])) {
            $errors[] = "Environment variable $var is not set";
        } else {
            echo "  ✅ $var is set\n";
        }
    }
    echo "\n";
    
    // Check JWT secret strength
    if (!empty($_ENV['JWT_SECRET']) && strlen($_ENV['JWT_SECRET']) < 32) {
        $warnings[] = "JWT_SECRET should be at least 32 characters for security";
    }
    
    // Check Firebase credentials file
    echo "✓ Checking Firebase credentials...\n";
    $credPath = __DIR__ . '/' . $_ENV['FIREBASE_CREDENTIALS_PATH'];
    if (!file_exists($credPath)) {
        $errors[] = "Firebase credentials file not found at: $credPath";
    } else {
        echo "  ✅ Firebase credentials file exists\n\n";
    }
}

// Check required PHP extensions
echo "✓ Checking PHP extensions...\n";
$requiredExtensions = ['curl', 'json', 'mbstring'];
foreach ($requiredExtensions as $ext) {
    if (!extension_loaded($ext)) {
        $errors[] = "PHP extension '$ext' is not loaded";
    } else {
        echo "  ✅ $ext extension loaded\n";
    }
}
echo "\n";

// Check if public directory exists
echo "✓ Checking public directory...\n";
if (!file_exists(__DIR__ . '/public/index.php')) {
    $errors[] = "public/index.php not found";
} else {
    echo "  ✅ public/index.php exists\n\n";
}

// Check if uploads directory is writable
echo "✓ Checking uploads directory...\n";
$uploadsDir = __DIR__ . '/public/uploads';
if (!is_dir($uploadsDir)) {
    mkdir($uploadsDir, 0755, true);
    echo "  ✅ Created uploads directory\n\n";
} elseif (!is_writable($uploadsDir)) {
    $warnings[] = "uploads directory is not writable";
} else {
    echo "  ✅ uploads directory is writable\n\n";
}

// Summary
echo "==========================================\n";
echo "SUMMARY\n";
echo "==========================================\n\n";

if (empty($errors) && empty($warnings)) {
    echo "✅ All checks passed! Your backend is ready.\n\n";
    echo "To start the server, run:\n";
    echo "  php -S localhost:8000 -t public\n\n";
    echo "Then test with:\n";
    echo "  curl http://localhost:8000/api/v1/health\n\n";
} else {
    if (!empty($errors)) {
        echo "❌ ERRORS (" . count($errors) . "):\n";
        foreach ($errors as $i => $error) {
            echo "  " . ($i + 1) . ". $error\n";
        }
        echo "\n";
    }
    
    if (!empty($warnings)) {
        echo "⚠️  WARNINGS (" . count($warnings) . "):\n";
        foreach ($warnings as $i => $warning) {
            echo "  " . ($i + 1) . ". $warning\n";
        }
        echo "\n";
    }
    
    if (!empty($errors)) {
        echo "Please fix the errors above before starting the server.\n\n";
        exit(1);
    }
}
