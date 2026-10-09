# Backend Setup Guide

## Requirements
- PHP 8.1+
- Composer
- Supabase Account

## Installation

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install Dependencies**
   ```bash
   composer install
   ```

3. **Environment Configuration**
   - Copy `.env.example` to `.env`
   - Fill in Supabase credentials:
     ```
     SUPABASE_URL=https://your-project.supabase.co
     SUPABASE_SERVICE_KEY=your-service-role-key
     ```
   - **Important:** Use the Service Role Key (not Anon Key) for backend operations.

## Running Locally

Start the PHP built-in server:
```bash
php -S localhost:8000 -t src/
```

- API Base URL: `http://localhost:8000/api/v1`
- Test Endpoint: `http://localhost:8000/api/v1/health`

## Database Setup

Run the SQL scripts in Supabase SQL Editor in this order:

1. `users.sql` (Core)
2. `goals.sql`
3. `checkins.sql`
4. `friendships.sql` (Phase 4)
5. `feed_view.sql` (Phase 4)
6. `points_system.sql` (Phase 5)
7. `leaderboard_view.sql` (Phase 5)
8. `achievements.sql` (Phase 5)

## Troubleshooting

- **CORS Issues:** Ensure `Access-Control-Allow-Origin` headers are set in `api.php`.
- **Database Connection:** Verify Supabase URL and Key are correct in `.env`.
