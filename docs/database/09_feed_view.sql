-- Phase 4B: Activity Feed View
-- Aggregates check-ins with user info, goal info, likes, and comments count

CREATE OR REPLACE VIEW feed_items AS
SELECT 
    c.id as checkin_id,
    c.user_id,
    u.username,
    u.display_name,
    u.avatar_url,
    c.goal_id,
    g.title as goal_title,
    g.category as goal_category,
    g.visibility as goal_visibility,
    c.note,
    c.photo_url,
    c.created_at,
    (SELECT COUNT(*) FROM likes l WHERE l.checkin_id = c.id) as likes_count,
    (SELECT COUNT(*) FROM comments cm WHERE cm.checkin_id = c.id AND cm.deleted_at IS NULL) as comments_count
FROM checkins c
JOIN users u ON c.user_id = u.id
JOIN goals g ON c.goal_id = g.id
WHERE c.deleted_at IS NULL
  AND g.deleted_at IS NULL
ORDER BY c.created_at DESC;
