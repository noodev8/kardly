-- Migration: Make groups, members, and albums user-specific
-- Description: Add user_id to kpop_groups, group_members, and albums tables
-- Date: 2025-10-01

-- IMPORTANT: This migration will DELETE all existing groups, members, and albums
-- because we cannot assign them to a user retroactively.
-- If you have important data, back it up first!

-- Delete existing data (since we can't assign user_id retroactively)
DELETE FROM photocards; -- Must delete first due to foreign keys
DELETE FROM albums;
DELETE FROM group_members;
DELETE FROM kpop_groups;

-- Add user_id column to kpop_groups table
ALTER TABLE kpop_groups
ADD COLUMN user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE;

-- Create index for better query performance
CREATE INDEX idx_kpop_groups_user_id ON kpop_groups(user_id);

COMMENT ON COLUMN kpop_groups.user_id IS 'The user who created this group';


-- Add user_id column to group_members table
ALTER TABLE group_members
ADD COLUMN user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE;

-- Create index for better query performance
CREATE INDEX idx_group_members_user_id ON group_members(user_id);

COMMENT ON COLUMN group_members.user_id IS 'The user who created this member';


-- Add user_id column to albums table
ALTER TABLE albums
ADD COLUMN user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE;

-- Create index for better query performance
CREATE INDEX idx_albums_user_id ON albums(user_id);

COMMENT ON COLUMN albums.user_id IS 'The user who created this album';

