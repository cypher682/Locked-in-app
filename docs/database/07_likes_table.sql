-- Phase 4C: Likes Table
-- Track user likes on check-ins

CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    checkin_id UUID NOT NULL REFERENCES checkins(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure one like per user per check-in
    CONSTRAINT unique_like UNIQUE (user_id, checkin_id)
);

-- Indexes
CREATE INDEX idx_likes_checkin ON likes(checkin_id);
CREATE INDEX idx_likes_user ON likes(user_id);
