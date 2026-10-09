-- Check-ins table
CREATE TABLE checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    note TEXT,
    photo_url TEXT,
    deleted_at TIMESTAMP, -- For soft delete
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_checkins_user_id ON checkins(user_id);
CREATE INDEX idx_checkins_goal_id ON checkins(goal_id);
CREATE INDEX idx_checkins_created_at ON checkins(created_at);
CREATE INDEX idx_checkins_deleted_at ON checkins(deleted_at);

-- Composite index for common query patterns
CREATE INDEX idx_checkins_goal_created ON checkins(goal_id, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_checkins_user_created ON checkins(user_id, created_at DESC) WHERE deleted_at IS NULL;

-- Update timestamp trigger (reuses function from users table)
CREATE TRIGGER update_checkins_updated_at BEFORE UPDATE
ON checkins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Constraint to ensure note or photo exists (at least one required)
ALTER TABLE checkins ADD CONSTRAINT check_content 
    CHECK (note IS NOT NULL OR photo_url IS NOT NULL);
