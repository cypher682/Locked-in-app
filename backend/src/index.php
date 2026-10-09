<?php
// Main entry point for the application

// Load Composer autoloader
require_once __DIR__ . '/../vendor/autoload.php';

// Load environment variables (if .env exists, otherwise use system env vars)
if (file_exists(__DIR__ . '/../.env')) {
    $dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/..');
    $dotenv->load();
}

// Delegates all requests to the router
require_once __DIR__ . '/Routes/api.php';
