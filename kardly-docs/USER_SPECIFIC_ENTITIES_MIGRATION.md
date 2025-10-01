# User-Specific Entities Migration Guide

## Overview
This migration makes groups, members, and albums user-specific instead of globally shared. Each user will have their own groups, members, and albums.

## Database Changes

### Migration File
`kardly-server/migrations/002_make_entities_user_specific.sql`

### Changes Made
1. **kpop_groups table** - Added `user_id` column
2. **group_members table** - Added `user_id` column  
3. **albums table** - Added `user_id` column

All with foreign keys to `users(id)` and indexes for performance.

## Backend Changes

### Files Modified
1. `kardly-server/routes/groups.js`
   - Added authentication to all endpoints
   - Filter groups by `user_id`
   - Include `user_id` when creating groups

2. `kardly-server/routes/members.js`
   - Added authentication to all endpoints
   - Filter members by `user_id`
   - Include `user_id` when creating members
   - Verify group belongs to user

3. `kardly-server/routes/albums.js` (TODO)
   - Add authentication to all endpoints
   - Filter albums by `user_id`
   - Include `user_id` when creating albums
   - Verify group belongs to user

## How to Apply

### Step 1: Run Migration
```bash
cd kardly-server
psql -h your-host -U your-user -d kardly_db -f migrations/002_make_entities_user_specific.sql
```

### Step 2: Restart Server
```bash
npm start
```

### Step 3: Test
- Register/login as a user
- Create a group
- Create a member
- Create an album
- Add a photocard
- Verify you only see your own data

## Impact

### Before
- All users shared the same groups, members, and albums
- User A could see groups created by User B
- Potential for conflicts and confusion

### After
- Each user has their own groups, members, and albums
- User A cannot see groups created by User B
- Clean separation of data
- Better privacy and organization

## Next Steps
1. ✅ Update groups routes
2. ✅ Update members routes
3. ⏳ Update albums routes
4. ⏳ Fix photocard detail page overflow
5. ⏳ Remove auto-owned behavior

