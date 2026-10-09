-- User streaks materialized view for performance
-- This calculates current streak, longest streak, and total check-ins per user

CREATE OR REPLACE VIEW user_streaks AS
WITH daily_checkins AS (
    -- Get distinct dates when user had check-ins
    SELECT 
        user_id,
        DATE(created_at) as checkin_date
    FROM checkins
    WHERE deleted_at IS NULL
    GROUP BY user_id, DATE(created_at)
),
date_sequences AS (
    -- Calculate gaps between consecutive check-in dates
    SELECT 
        user_id,
        checkin_date,
        LAG(checkin_date) OVER (PARTITION BY user_id ORDER BY checkin_date) as prev_date,
        CASE 
            WHEN LAG(checkin_date) OVER (PARTITION BY user_id ORDER BY checkin_date) IS NULL THEN 1
            WHEN DATE(checkin_date) - LAG(checkin_date) OVER (PARTITION BY user_id ORDER BY checkin_date) = 1 THEN 0
            ELSE 1
        END as is_new_streak
    FROM daily_checkins
),
streak_groups AS (
    -- Group consecutive dates into streaks
    SELECT 
        user_id,
        checkin_date,
        SUM(is_new_streak) OVER (PARTITION BY user_id ORDER BY checkin_date) as streak_group
    FROM date_sequences
),
streak_lengths AS (
    -- Calculate length of each streak
    SELECT 
        user_id,
        streak_group,
        MIN(checkin_date) as streak_start,
        MAX(checkin_date) as streak_end,
        COUNT(*) as streak_length
    FROM streak_groups
    GROUP BY user_id, streak_group
),
current_streaks AS (
    -- Identify current active streaks (last check-in was today or yesterday)
    SELECT 
        user_id,
        streak_length as current_streak
    FROM streak_lengths
    WHERE streak_end >= CURRENT_DATE - INTERVAL '1 day'
    ORDER BY user_id, streak_end DESC
),
user_stats AS (
    -- Calculate total check-ins and longest streak per user
    SELECT 
        c.user_id,
        COUNT(*) as total_checkins,
        MAX(sl.streak_length) as longest_streak,
        MAX(c.created_at) as last_checkin_at
    FROM checkins c
    LEFT JOIN streak_lengths sl ON c.user_id = sl.user_id
    WHERE c.deleted_at IS NULL
    GROUP BY c.user_id
)
SELECT 
    us.user_id,
    COALESCE(cs.current_streak, 0) as current_streak,
    COALESCE(us.longest_streak, 0) as longest_streak,
    us.total_checkins,
    us.last_checkin_at
FROM user_stats us
LEFT JOIN current_streaks cs ON us.user_id = cs.user_id;

-- Create index on the view for faster queries
CREATE INDEX idx_user_streaks_user_id ON user_streaks(user_id);
