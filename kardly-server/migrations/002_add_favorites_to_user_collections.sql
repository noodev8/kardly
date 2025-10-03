-- Migration: Add favorites feature to user_collections table
-- Description: Adds is_favorite column to allow users to mark photocards as favorites
-- Date: 2025-10-03

-- Add is_favorite column to user_collections table
ALTER TABLE user_collections 
ADD COLUMN is_favorite boolean DEFAULT false;

-- Create index for better query performance when filtering favorites
CREATE INDEX idx_user_collections_favorite ON user_collections(user_id, is_favorite) WHERE is_favorite = true;

-- Add comment for documentation
COMMENT ON COLUMN user_collections.is_favorite IS 'Whether this photocard is marked as a favorite by the user';
