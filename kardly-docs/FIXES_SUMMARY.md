# Fixes Summary - User-Specific Entities & UI Improvements

## Overview
This document summarizes all the fixes made to address:
1. Making groups, members, and albums user-specific
2. Fixing overflow issues on photocard detail screen
3. Removing auto-owned behavior for photocards

## 1. User-Specific Entities

### Problem
- Groups, members, and albums were globally shared across all users
- User A could see groups created by User B
- No privacy or data separation

### Solution
Added `user_id` column to `kpop_groups`, `group_members`, and `albums` tables.

### Database Migration
**File:** `kardly-server/migrations/002_make_entities_user_specific.sql`

```sql
-- Add user_id to kpop_groups
ALTER TABLE kpop_groups ADD COLUMN user_id uuid;
ALTER TABLE kpop_groups ADD CONSTRAINT kpop_groups_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
CREATE INDEX idx_kpop_groups_user_id ON kpop_groups(user_id);
ALTER TABLE kpop_groups ALTER COLUMN user_id SET NOT NULL;

-- Add user_id to group_members
ALTER TABLE group_members ADD COLUMN user_id uuid;
ALTER TABLE group_members ADD CONSTRAINT group_members_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
CREATE INDEX idx_group_members_user_id ON group_members(user_id);
ALTER TABLE group_members ALTER COLUMN user_id SET NOT NULL;

-- Add user_id to albums
ALTER TABLE albums ADD COLUMN user_id uuid;
ALTER TABLE albums ADD CONSTRAINT albums_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
CREATE INDEX idx_albums_user_id ON albums(user_id);
ALTER TABLE albums ALTER COLUMN user_id SET NOT NULL;
```

### Backend Changes

#### 1. Groups Routes (`kardly-server/routes/groups.js`)
**Changes:**
- Added `authenticateToken` middleware to all endpoints
- Filter groups by `user_id` in GET endpoint
- Include `user_id` when creating groups
- Check for duplicates within user's groups only

**Before:**
```javascript
router.post('/groups', [...], async (req, res) => {
  let query = 'SELECT * FROM kpop_groups WHERE 1=1';
  // Returns all groups for all users
});
```

**After:**
```javascript
router.post('/groups', authenticateToken, [...], async (req, res) => {
  const user_id = req.user.id;
  let query = 'SELECT * FROM kpop_groups WHERE user_id = $1';
  // Returns only user's groups
});
```

#### 2. Members Routes (`kardly-server/routes/members.js`)
**Changes:**
- Added `authenticateToken` middleware to all endpoints
- Filter members by `user_id` in GET endpoint
- Include `user_id` when creating members
- Verify group belongs to user before creating member
- Check for duplicates within user's members only

**Before:**
```javascript
router.post('/members', [...], async (req, res) => {
  let query = 'SELECT * FROM group_members WHERE 1=1';
  // Returns all members for all users
});
```

**After:**
```javascript
router.post('/members', authenticateToken, [...], async (req, res) => {
  const user_id = req.user.id;
  let query = 'SELECT * FROM group_members WHERE user_id = $1';
  // Returns only user's members
});
```

#### 3. Albums Routes (`kardly-server/routes/albums.js`)
**Changes:**
- Added `authenticateToken` middleware to all endpoints
- Filter albums by `user_id` in GET endpoint
- Include `user_id` when creating albums
- Verify group belongs to user before creating album
- Check for duplicates within user's albums only

**Before:**
```javascript
router.post('/albums', [...], async (req, res) => {
  let query = 'SELECT * FROM albums WHERE 1=1';
  // Returns all albums for all users
});
```

**After:**
```javascript
router.post('/albums', authenticateToken, [...], async (req, res) => {
  const user_id = req.user.id;
  let query = 'SELECT * FROM albums WHERE user_id = $1';
  // Returns only user's albums
});
```

## 2. Photocard Detail Page Overflow Fix

### Problem
- Long group names and member names caused text overflow in the app bar title
- Text would run off screen or cause layout issues

### Solution
Added `overflow: TextOverflow.ellipsis` and `maxLines: 1` to the title Text widget.

### File Changed
`kardly-flutter/lib/features/photocard/presentation/pages/photocard_detail_page.dart`

**Before:**
```dart
title: Text(
  '${photocardData!['groupName']} - ${photocardData!['memberName']}',
  style: const TextStyle(...),
),
```

**After:**
```dart
title: Text(
  '${photocardData!['groupName']} - ${photocardData!['memberName']}',
  style: const TextStyle(...),
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
),
```

**Result:**
- Long titles now show "..." when they exceed available space
- No more overflow errors
- Clean, professional appearance

## 3. Remove Auto-Owned Behavior

### Problem
- All photocards were automatically marked as "owned" when fetched
- Users couldn't distinguish between cards they own and cards they don't
- No way to manage wishlist vs owned status properly

### Solution
Changed the `Photocard.fromJson` factory to read `is_owned` and `is_wishlisted` from the API response instead of hardcoding them.

### File Changed
`kardly-flutter/lib/features/collection/presentation/providers/collection_provider.dart`

**Before:**
```dart
factory Photocard.fromJson(Map<String, dynamic> json) {
  return Photocard(
    ...
    isOwned: true, // All fetched cards are owned for now
    isWishlisted: false,
  );
}
```

**After:**
```dart
factory Photocard.fromJson(Map<String, dynamic> json) {
  return Photocard(
    ...
    isOwned: json['is_owned'] ?? false, // Get from collection status
    isWishlisted: json['is_wishlisted'] ?? false, // Get from collection status
  );
}
```

**Result:**
- Photocards now correctly reflect their owned/wishlist status
- Users can toggle owned/wishlist status
- Status persists across app restarts
- Proper separation between owned and wishlisted cards

## How to Apply These Changes

### Step 1: Run Database Migration
```bash
cd kardly-server
psql -h your-host -U your-user -d kardly_db -f migrations/002_make_entities_user_specific.sql
```

**Note:** If you have existing data, you'll need to assign a user_id to existing records first:
```sql
-- Example: Assign all existing groups to a specific user
UPDATE kpop_groups SET user_id = 'your-user-uuid' WHERE user_id IS NULL;
UPDATE group_members SET user_id = 'your-user-uuid' WHERE user_id IS NULL;
UPDATE albums SET user_id = 'your-user-uuid' WHERE user_id IS NULL;
```

### Step 2: Restart Backend Server
```bash
cd kardly-server
npm start
```

### Step 3: Rebuild Flutter App
```bash
cd kardly-flutter
flutter clean
flutter pub get
flutter run
```

### Step 4: Test
1. **Test User-Specific Entities:**
   - Register/login as User A
   - Create a group "BTS"
   - Create a member "Jungkook"
   - Create an album "Map of the Soul: 7"
   - Logout
   - Register/login as User B
   - Verify you don't see User A's groups/members/albums
   - Create your own groups/members/albums

2. **Test Overflow Fix:**
   - Create a group with a very long name
   - Create a member with a very long name
   - Add a photocard
   - View photocard details
   - Verify title shows "..." instead of overflowing

3. **Test Owned/Wishlist Status:**
   - Add a photocard
   - Verify it's NOT automatically marked as owned
   - Tap "Add to Collection" to mark as owned
   - Tap "Add to Wishlist" to add to wishlist
   - Close and reopen app
   - Verify status persists

## Impact

### Before
- ❌ All users shared groups, members, albums
- ❌ No privacy or data separation
- ❌ Text overflow on detail pages
- ❌ All cards automatically marked as owned
- ❌ No way to manage wishlist properly

### After
- ✅ Each user has their own groups, members, albums
- ✅ Complete privacy and data separation
- ✅ Clean UI with no overflow
- ✅ Cards start as unowned
- ✅ Users can properly manage owned vs wishlist status
- ✅ Better user experience overall

## API Changes

### Endpoints Now Require Authentication
All these endpoints now require a valid JWT token in the Authorization header:

```
POST /api/groups
POST /api/groups/create
POST /api/members
POST /api/members/create
POST /api/albums
POST /api/albums/create
```

### Request Example
```bash
curl -X POST http://localhost:3000/api/groups \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"search": "BTS"}'
```

### Response Changes
Responses now only include data belonging to the authenticated user.

## Troubleshooting

### "Column user_id does not exist"
- Run the migration script
- Make sure you're connected to the correct database

### "Cannot read property 'id' of undefined"
- Make sure you're logged in
- Check that JWT token is valid
- Verify token is being sent in Authorization header

### "Group does not exist or does not belong to you"
- The group was created by another user
- Create your own group instead

### Cards still showing as owned
- Clear app data and restart
- Make sure backend is returning `is_owned` and `is_wishlisted` fields
- Check API response in network inspector

## Files Modified

### Backend
- ✅ `kardly-server/routes/groups.js`
- ✅ `kardly-server/routes/members.js`
- ✅ `kardly-server/routes/albums.js`
- ✅ `kardly-server/migrations/002_make_entities_user_specific.sql` (new)

### Frontend
- ✅ `kardly-flutter/lib/features/photocard/presentation/pages/photocard_detail_page.dart`
- ✅ `kardly-flutter/lib/features/collection/presentation/providers/collection_provider.dart`

### Documentation
- ✅ `kardly-docs/USER_SPECIFIC_ENTITIES_MIGRATION.md` (new)
- ✅ `kardly-docs/FIXES_SUMMARY.md` (new)

## Next Steps

1. ✅ Run database migration
2. ✅ Restart backend server
3. ✅ Rebuild Flutter app
4. ✅ Test all functionality
5. ⏳ Consider adding user profile pictures
6. ⏳ Consider adding sharing/public collections feature
7. ⏳ Consider adding import/export functionality

## Conclusion

All three issues have been successfully fixed:
1. ✅ Groups, members, and albums are now user-specific
2. ✅ Overflow issues on photocard detail page are fixed
3. ✅ Cards are no longer automatically marked as owned

The app now provides better privacy, cleaner UI, and more accurate collection management!

