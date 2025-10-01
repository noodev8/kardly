-- Migration: Add user_id to photocards table
-- Description: Makes photocards user-specific instead of globally shared
-- Date: 2025-10-01

-- Add user_id column to photocards table
ALTER TABLE photocards 
ADD COLUMN user_id uuid;

-- Add foreign key constraint to users table
ALTER TABLE photocards
ADD CONSTRAINT photocards_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Create index for better query performance
CREATE INDEX idx_photocards_user_id ON photocards(user_id);

-- Make user_id NOT NULL (after ensuring all existing records have a user_id)
-- Note: If you have existing photocards, you'll need to assign them to users first
-- ALTER TABLE photocards ALTER COLUMN user_id SET NOT NULL;

-- Optional: Add a unique constraint if users can't have duplicate photocards
-- CREATE UNIQUE INDEX idx_photocards_user_unique ON photocards(user_id, group_id, member_id, album_id, image_url);

COMMENT ON COLUMN photocards.user_id IS 'The user who owns this photocard';

