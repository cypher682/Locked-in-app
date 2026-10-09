-- Phase 4: User Profile Enhancement
-- Add username and privacy settings to users table

-- Add username column (unique, searchable)
ALTER TABLE users 
ADD COLUMN username VARCHAR(50) UNIQUE,
ADD COLUMN is_searchable BOOLEAN DEFAULT true,
ADD COLUMN bio TEXT;

-- Create index for username search
CREATE INDEX idx_users_username ON users(username) WHERE username IS NOT NULL;

-- Create index for searchable users
CREATE INDEX idx_users_searchable ON users(is_searchable) WHERE is_searchable = true;

-- Add constraint for username format (alphanumeric, underscore, hyphen only)
ALTER TABLE users 
ADD CONSTRAINT check_username_format 
CHECK (username ~* '^[a-z0-9_-]{3,50}$');

-- Update trigger to handle updated_at
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: Trigger should already exist from Phase 1, but recreating to be safe
DROP TRIGGER IF EXISTS update_users_updated_at_trigger ON users;
CREATE TRIGGER update_users_updated_at_trigger
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_users_updated_at();
