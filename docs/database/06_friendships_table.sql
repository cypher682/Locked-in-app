-- Phase 4A: Friendships Table
-- Manages friend relationships and requests

CREATE TABLE friendships (
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

-- Indexes for performance
CREATE INDEX idx_friendships_requester ON friendships(requester_id) WHERE status != 'declined';
CREATE INDEX idx_friendships_addressee ON friendships(addressee_id) WHERE status = 'pending';
CREATE INDEX idx_friendships_status ON friendships(status);
CREATE INDEX idx_friendships_accepted ON friendships(requester_id, addressee_id) WHERE status = 'accepted';

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_friendships_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_friendships_updated_at_trigger
    BEFORE UPDATE ON friendships
    FOR EACH ROW
    EXECUTE FUNCTION update_friendships_updated_at();
