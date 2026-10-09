-- Phase 5C: Achievements System
-- Unlockable badges for reaching milestones

-- Achievements definition table
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50), -- emoji or icon name
    points_reward INTEGER DEFAULT 0,
    category VARCHAR(50) DEFAULT 'general', -- 'streak', 'checkin', 'social'
    threshold INTEGER, -- numeric threshold to unlock (e.g., 7 for 7-day streak)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User achievements tracking table
CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE NOT NULL,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement ON user_achievements(achievement_id);

-- Seed initial achievements
INSERT INTO achievements (code, name, description, icon, points_reward, category, threshold) VALUES
    ('first_checkin', 'First Steps', 'Complete your first check-in', '🌟', 25, 'checkin', 1),
    ('checkins_10', 'Consistent', 'Complete 10 check-ins', '✅', 50, 'checkin', 10),
    ('checkins_50', 'Dedicated', 'Complete 50 check-ins', '💪', 100, 'checkin', 50),
    ('checkins_100', 'Century', 'Complete 100 check-ins', '💯', 200, 'checkin', 100),
    ('streak_7', 'On Fire', 'Achieve a 7-day streak', '🔥', 50, 'streak', 7),
    ('streak_30', 'Champion', 'Achieve a 30-day streak', '🏆', 200, 'streak', 30),
    ('streak_100', 'Legend', 'Achieve a 100-day streak', '👑', 500, 'streak', 100),
    ('first_friend', 'Social Butterfly', 'Add your first friend', '🦋', 25, 'social', 1),
    ('friends_10', 'Popular', 'Have 10 friends', '🌐', 50, 'social', 10)
ON CONFLICT (code) DO NOTHING;

COMMENT ON TABLE achievements IS 'Available achievements/badges that users can unlock';
COMMENT ON TABLE user_achievements IS 'Tracks which achievements each user has unlocked';
