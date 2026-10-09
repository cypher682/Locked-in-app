# Database Update Guide - Phase 4

## 🔴 ISSUE IDENTIFIED

Your app is failing to update profiles because the database is missing Phase 4 columns:
- `username` column
- `bio` column  
- `is_searchable` column
- `friendships` table

## ✅ SOLUTION: Run Database Migration

### Step 1: Open Supabase Dashboard

1. Go to https://supabase.com
2. Open your project: `nqwteavjhngejklpfzbm`
3. Click on **SQL Editor** in the left sidebar

### Step 2: Run Migration Script

1. Click **New Query**
2. Copy the entire contents of `docs/database/PHASE_4_MIGRATION.sql`
3. Paste into the SQL editor
4. Click **Run** (or press Ctrl+Enter)

### Step 3: Verify Success

You should see:
```
Phase 4 migration completed successfully!
```

And the verification queries will show:
- `users` table now has `username`, `bio`, `is_searchable` columns
- `friendships` table exists
- All indexes are created

### Step 4: Test the App

1. Go back to your app
2. Try to update your profile (username/bio)
3. It should work now! ✅

---

## 📋 What Gets Added

### Users Table (Updated)
```sql
- username VARCHAR(50) UNIQUE
- bio TEXT
- is_searchable BOOLEAN DEFAULT true
```

### Friendships Table (New)
```sql
- id UUID PRIMARY KEY
- requester_id UUID (who sent the request)
- addressee_id UUID (who received the request)
- status VARCHAR(20) (pending, accepted, declined, blocked)
- created_at TIMESTAMPTZ
- updated_at TIMESTAMPTZ
```

### Indexes (Performance)
- Username search index
- Searchable users index
- Friendship lookup indexes

---

## 🔧 Alternative: Manual Steps

If you prefer to run each step separately:

### 1. Add columns to users table:
```sql
ALTER TABLE users 
ADD COLUMN username VARCHAR(50) UNIQUE,
ADD COLUMN is_searchable BOOLEAN DEFAULT true,
ADD COLUMN bio TEXT;
```

### 2. Create friendships table:
```sql
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    addressee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_friendship UNIQUE (requester_id, addressee_id),
    CONSTRAINT check_status CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
    CONSTRAINT no_self_friend CHECK (requester_id != addressee_id)
);
```

---

## ✅ After Migration

Once the migration is complete:

1. **Profile editing will work** - You can set username and bio
2. **Friend system will work** - You can search and add friends
3. **No more 500 errors** - Database has all required columns

---

## 🆘 If You Get Errors

### Error: "column already exists"
- This is OK! It means the column was already added
- The migration uses `IF NOT EXISTS` to handle this

### Error: "relation already exists"
- This is OK! It means the table was already created
- The migration uses `IF NOT EXISTS` to handle this

### Error: "permission denied"
- Make sure you're using the **SQL Editor** in Supabase
- Make sure you're logged in as the project owner

---

## 📊 Quick Check

After running the migration, run this query to verify:

```sql
-- Check if all Phase 4 columns exist
SELECT 
    EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'username') as has_username,
    EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'bio') as has_bio,
    EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'is_searchable') as has_searchable,
    EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'friendships') as has_friendships;
```

Expected result:
```
has_username | has_bio | has_searchable | has_friendships
-------------|---------|----------------|----------------
true         | true    | true           | true
```

---

**Ready to fix?** Open Supabase and run the migration! 🚀
