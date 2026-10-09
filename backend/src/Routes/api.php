<?php

use App\Controllers\Auth\AuthController;
use App\Controllers\Goal\GoalController;
use App\Controllers\Checkin\CheckinController;
use App\Controllers\User\UserProfileController;
use App\Controllers\Friendship\FriendshipController;
use App\Controllers\Feed\FeedController;
use App\Controllers\Social\SocialController;
use App\Controllers\Points\PointsController;
use App\Controllers\Leaderboard\LeaderboardController;
use App\Controllers\Achievement\AchievementController;

// CORS headers for development/testing
header('Access-Control-Allow-Origin: *'); // For production, replace * with specific domain
header('Access-Control-Allow-Methods: GET, POST, PATCH, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json'); // CRITICAL: Tell clients response is JSON

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get request method and URI
$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Remove /api/v1 prefix if present
$uri = preg_replace('#^/api/v1#', '', $uri);

// Route handling
try {
    // Auth routes
    if ($method === 'POST' && $uri === '/auth/login') {
        $controller = new AuthController();
        $controller->login();
    } elseif ($method === 'GET' && $uri === '/auth/verify') {
        $controller = new AuthController();
        $controller->verify();
    } 
    
    // Goal routes
    elseif ($method === 'POST' && $uri === '/goals') {
        $controller = new GoalController();
        $controller->createGoal();
    } elseif ($method === 'GET' && $uri === '/goals') {
        $controller = new GoalController();
        $controller->getUserGoals();
    } elseif ($method === 'GET' && preg_match('#^/goals/([a-f0-9\-]+)$#', $uri, $matches)) {
        $controller = new GoalController();
        $controller->getGoalById($matches[1]);
    } elseif ($method === 'PATCH' && preg_match('#^/goals/([a-f0-9\-]+)$#', $uri, $matches)) {
        $controller = new GoalController();
        $controller->updateGoal($matches[1]);
    } elseif ($method === 'DELETE' && preg_match('#^/goals/([a-f0-9\-]+)$#', $uri, $matches)) {
        $controller = new GoalController();
        $controller->deleteGoal($matches[1]);
    } 
    
    // Check-in routes
    elseif ($method === 'POST' && $uri === '/checkins') {
        $controller = new CheckinController();
        $controller->createCheckin();
    } elseif ($method === 'GET' && $uri === '/checkins') {
        $controller = new CheckinController();
        $controller->getUserCheckins();
    } elseif ($method === 'GET' && $uri === '/checkins/streak') {
        $controller = new CheckinController();
        $controller->getUserStreak();
    } elseif ($method === 'GET' && preg_match('#^/goals/([a-f0-9\-]+)/checkins$#', $uri, $matches)) {
        $controller = new CheckinController();
        $controller->getGoalCheckins($matches[1]);
    } elseif ($method === 'GET' && preg_match('#^/checkins/([a-f0-9\-]+)$#', $uri, $matches)) {
        $controller = new CheckinController();
        $controller->getCheckinById($matches[1]);
    } elseif ($method === 'PATCH' && preg_match('#^/checkins/([a-f0-9\-]+)$#', $uri, $matches)) {
        $controller = new CheckinController();
        $controller->updateCheckin($matches[1]);
    } elseif ($method === 'DELETE' && preg_match('#^/checkins/([a-f0-9\-]+)$#', $uri, $matches)) {
        $controller = new CheckinController();
        $controller->deleteCheckin($matches[1]);
    } 
    
    // User Profile routes
    elseif ($method === 'GET' && $uri === '/profile') {
        $controller = new UserProfileController();
        $controller->getMyProfile();
    } elseif ($method === 'PATCH' && $uri === '/profile') {
        $controller = new UserProfileController();
        $controller->updateMyProfile();
    } elseif ($method === 'GET' && preg_match('#^/users/([a-f0-9\-]+)$#', $uri, $matches)) {
        $controller = new UserProfileController();
        $controller->getUserProfile($matches[1]);
    } elseif ($method === 'GET' && $uri === '/users/search') {
        $controller = new UserProfileController();
        $controller->searchUsers();
    } 
    
    // Friendship routes
    elseif ($method === 'POST' && $uri === '/friends/request') {
        $controller = new FriendshipController();
        $controller->sendFriendRequest();
    } elseif ($method === 'GET' && $uri === '/friends') {
        $controller = new FriendshipController();
        $controller->getFriends();
    } elseif ($method === 'GET' && $uri === '/friends/requests') {
        $controller = new FriendshipController();
        $controller->getPendingRequests();
    } elseif ($method === 'POST' && preg_match('#^/friends/([a-f0-9\-]+)/accept$#', $uri, $matches)) {
        $controller = new FriendshipController();
        $controller->acceptFriendRequest($matches[1]);
    } elseif ($method === 'POST' && preg_match('#^/friends/([a-f0-9\-]+)/decline$#', $uri, $matches)) {
        $controller = new FriendshipController();
        $controller->declineFriendRequest($matches[1]);
    } elseif ($method === 'DELETE' && preg_match('#^/friends/([a-f0-9\-]+)$#', $uri, $matches)) {
        $controller = new FriendshipController();
        $controller->removeFriend($matches[1]);
    } 
    
    // Feed routes
    elseif ($method === 'GET' && $uri === '/feed') {
        $controller = new FeedController();
        $controller->getFeed();
    } 
    
    // Like routes
    elseif ($method === 'POST' && preg_match('#^/checkins/([a-f0-9\-]+)/like$#', $uri, $matches)) {
        $controller = new SocialController();
        $controller->likeCheckin($matches[1]);
    } elseif ($method === 'DELETE' && preg_match('#^/checkins/([a-f0-9\-]+)/like$#', $uri, $matches)) {
        $controller = new SocialController();
        $controller->unlikeCheckin($matches[1]);
    } elseif ($method === 'GET' && preg_match('#^/checkins/([a-f0-9\-]+)/likes$#', $uri, $matches)) {
        $controller = new SocialController();
        $controller->getCheckinLikes($matches[1]);
    } 
    
    // Comment routes
    elseif ($method === 'POST' && preg_match('#^/checkins/([a-f0-9\-]+)/comments$#', $uri, $matches)) {
        $controller = new SocialController();
        $controller->addComment($matches[1]);
    } elseif ($method === 'GET' && preg_match('#^/checkins/([a-f0-9\-]+)/comments$#', $uri, $matches)) {
        $controller = new SocialController();
        $controller->getCheckinComments($matches[1]);
    } elseif ($method === 'DELETE' && preg_match('#^/comments/([a-f0-9\-]+)$#', $uri, $matches)) {
        $controller = new SocialController();
        $controller->deleteComment($matches[1]);
    } 
    
    // Points routes
    elseif ($method === 'GET' && $uri === '/points') {
        $controller = new PointsController();
        $controller->getMyPoints();
    } elseif ($method === 'GET' && $uri === '/points/history') {
        $controller = new PointsController();
        $controller->getPointHistory();
    } 
    
    // Leaderboard routes
    elseif ($method === 'GET' && $uri === '/leaderboard') {
        $controller = new LeaderboardController();
        $controller->getLeaderboard();
    } 
    
    // Achievement routes
    elseif ($method === 'GET' && $uri === '/achievements') {
        $controller = new AchievementController();
        $controller->getAllAchievements();
    } elseif ($method === 'GET' && $uri === '/achievements/mine') {
        $controller = new AchievementController();
        $controller->getMyAchievements();
    } 
    
    // Health check
    elseif ($method === 'GET' && $uri === '/health') {
        http_response_code(200);
        echo json_encode(['status' => 'ok', 'timestamp' => time()]);
    } 
    
    // 404 handler
    else {
        http_response_code(404);
        echo json_encode(['error' => 'Route not found']);
    }
} catch (\Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
