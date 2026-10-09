-- Phase 5B: Leaderboard View
-- Rankings based on total points

CREATE OR REPLACE VIEW leaderboard AS
SELECT 
    u.id as user_id,
    u.username,
    u.display_name,
    u.avatar_url,
    u.total_points,
    RANK() OVER (ORDER BY COALESCE(u.total_points, 0) DESC) as rank
FROM users u
WHERE u.is_searchable = true OR u.is_searchable IS NULL
ORDER BY COALESCE(u.total_points, 0) DESC;

COMMENT ON VIEW leaderboard IS 'Global leaderboard ranked by total points';
