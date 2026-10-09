# Architecture Overview

Locked-in App follows a clean, decoupled architecture with a PHP Backend and Flutter Mobile App.

## 🏗️ System Components

### 1. Mobile App (Flutter)
- **State Management:** Riverpod
- **Architecture:** Feature-first modular structure
  - `features/` (auth, goals, checkins, feed, gamification)
  - `core/` (services, shared widgets, constants)
- **Networking:** Dio HTTP client

### 2. Backend API (PHP)
- **Framework:** Custom router (no framework overhead)
- **Service Layer:** `src/Services` handles logic
- **Controller Layer:** `src/Controllers` handles validation & response
- **Integration:** Supabase via REST API

### 3. Database (Supabase)
- **Core Tables:** `users`, `goals`, `checkins`
- **Social:** `friendships`, `feed_view`
- **Gamification:** `user_points`, `achievements`, `leaderboard` (View)

## 🔄 Data Flow

1. **User Action** (Mobile)
   → `Provider` calls `Service`
   → `Service` makes HTTP request

2. **API Request** (Backend)
   → `Router` matches URL
   → `Middleware` verifies Token
   → `Controller` validates Input
   → `Service` executes Logic
   → `SupabaseService` queries DB

3. **Response**
   → JSON data returned
   → Mobile UI updates (Optimistic or standard)
