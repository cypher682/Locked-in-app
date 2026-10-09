-- ============================================
-- PHASE 4 DATABASE MIGRATION
-- Run this in Supabase SQL Editor
-- ============================================

-- Step 1: Add new columns to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS username VARCHAR(50) UNIQUE,
ADD COLUMN IF NOT EXISTS is_searchable BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS bio TEXT;

-- Step 2: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username) WHERE username IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_searchable ON users(is_searchable) WHERE is_searchable = true;

-- Step 3: Add username format constraint
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'check_username_format'
    ) THEN
        ALTER TABLE users 
        ADD CONSTRAINT check_username_format 
        CHECK (username ~* '^[a-z0-9_-]{3,50}$');
    END IF;
END $$;

-- Step 4: Create friendships table
CREATE TABLE IF NOT EXISTS friendships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    addressee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_friendship UNIQUE (requester_id, addressee_id),
    CONSTRAINT check_status CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
    CONSTRAINT no_self_friend CHECK (requester_id != addressee_id)
);

-- Step 5: Create indexes for friendships
CREATE INDEX IF NOT EXISTS idx_friendships_requester ON friendships(requester_id) WHERE status != 'declined';
CREATE INDEX IF NOT EXISTS idx_friendships_addressee ON friendships(addressee_id) WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_friendships_status ON friendships(status);
CREATE INDEX IF NOT EXISTS idx_friendships_accepted ON friendships(requester_id, addressee_id) WHERE status = 'accepted';

-- Step 6: Create/Update trigger function for friendships
CREATE OR REPLACE FUNCTION update_friendships_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Create trigger for friendships
DROP TRIGGER IF EXISTS update_friendships_updated_at_trigger ON friendships;
CREATE TRIGGER update_friendships_updated_at_trigger
    BEFORE UPDATE ON friendships
    FOR EACH ROW
    EXECUTE FUNCTION update_friendships_updated_at();

-- ============================================
-- VERIFICATION QUERIES
-- Run these to verify the migration worked
-- ============================================

-- Check users table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- Check friendships table exists
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_name = 'friendships'
) as friendships_table_exists;

-- Check indexes
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename IN ('users', 'friendships')
ORDER BY tablename, indexname;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT 'Phase 4 migration completed successfully!' as status;
