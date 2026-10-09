-- Goals table
CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50), -- 'fitness', 'career', 'education', 'health', 'personal', 'other'
    target_date DATE,
    visibility VARCHAR(20) DEFAULT 'public', -- 'public', 'private', 'friends_only'
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'completed', 'abandoned'
    deleted_at TIMESTAMP, -- For soft delete
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_status ON goals(status);
CREATE INDEX idx_goals_visibility ON goals(visibility);
CREATE INDEX idx_goals_target_date ON goals(target_date);
CREATE INDEX idx_goals_deleted_at ON goals(deleted_at); -- For filtering out soft-deleted records

-- Composite index for common query patterns
CREATE INDEX idx_goals_user_status ON goals(user_id, status) WHERE deleted_at IS NULL;

-- Update timestamp trigger
CREATE TRIGGER update_goals_updated_at BEFORE UPDATE
ON goals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Constraint to ensure valid visibility values
ALTER TABLE goals ADD CONSTRAINT check_visibility 
    CHECK (visibility IN ('public', 'private', 'friends_only'));

-- Constraint to ensure valid status values
ALTER TABLE goals ADD CONSTRAINT check_status 
    CHECK (status IN ('active', 'completed', 'abandoned'));

-- Constraint to ensure valid category values
ALTER TABLE goals ADD CONSTRAINT check_category 
    CHECK (category IS NULL OR category IN ('fitness', 'career', 'education', 'health', 'personal', 'other'));
