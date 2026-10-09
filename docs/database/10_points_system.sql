-- Phase 5A: Points System
-- Adds points tracking for gamification

-- Add total_points column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0;

-- Points transaction history table
CREATE TABLE IF NOT EXISTS point_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    points INTEGER NOT NULL,
    reason VARCHAR(50) NOT NULL, -- 'checkin', 'streak_7', 'streak_30', 'achievement'
    reference_id UUID, -- checkin_id or achievement_id if applicable
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_point_transactions_user ON point_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_point_transactions_created ON point_transactions(created_at DESC);

-- Constraint to ensure positive points for normal rewards (negative for penalties if needed)
-- No constraint - allow negative for future penalty systems

COMMENT ON TABLE point_transactions IS 'Tracks all point awards and deductions for gamification';
COMMENT ON COLUMN point_transactions.reason IS 'Type: checkin, streak_7, streak_30, streak_bonus, achievement';
