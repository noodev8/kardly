# Setup Guide After Recent Fixes

## Overview
This guide will help you apply all the recent fixes and get your Kardly app running with:
- ✅ User-specific groups, members, and albums
- ✅ Fixed overflow issues
- ✅ Proper owned/wishlist status
- ✅ Working authentication tokens

## Prerequisites
- PostgreSQL database running
- Node.js and npm installed
- Flutter SDK installed
- Backend server code updated
- Frontend Flutter code updated

## Step-by-Step Setup

### Step 1: Apply Database Migration

**⚠️ WARNING:** This migration will DELETE all existing groups, members, albums, and photocards because we cannot assign them to a user retroactively. If you have important data, back it up first!

```bash
# Navigate to server directory
cd kardly-server

# Connect to your database and run the migration
psql -h your-host -U your-user -d kardly_db -f migrations/002_make_entities_user_specific.sql
```

**Replace:**
- `your-host` with your database host (e.g., `localhost` or your Supabase host)
- `your-user` with your database username
- `kardly_db` with your database name

**Example for local PostgreSQL:**
```bash
psql -h localhost -U postgres -d kardly_db -f migrations/002_make_entities_user_specific.sql
```

**Example for Supabase:**
```bash
psql "postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres" -f migrations/002_make_entities_user_specific.sql
```

**Expected Output:**
```
DELETE 0
DELETE 0
DELETE 0
DELETE 0
ALTER TABLE
CREATE INDEX
COMMENT
ALTER TABLE
CREATE INDEX
COMMENT
ALTER TABLE
CREATE INDEX
COMMENT
```

### Step 2: Verify Migration

Check that the columns were added:

```sql
-- Check kpop_groups table
\d kpop_groups

-- Check group_members table
\d group_members

-- Check albums table
\d albums
```

You should see `user_id` column in all three tables.

### Step 3: Restart Backend Server

```bash
# Make sure you're in kardly-server directory
cd kardly-server

# Stop any running server (Ctrl+C or kill the process)

# Start the server
npm start
```

**Expected Output:**
```
> kardly-server@1.0.0 start
> node server.js

Server running on port 3000
Database connected successfully
```

**If you see errors:**
- Check that PostgreSQL is running
- Verify database credentials in `.env` file
- Make sure migration was applied successfully

### Step 4: Rebuild Flutter App

```bash
# Navigate to Flutter directory
cd kardly-flutter

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Run the app
flutter run
```

**Or if using hot reload:**
- Press `R` in the terminal to hot reload
- Or press `Shift+R` to hot restart

### Step 5: Test the App

#### 5.1 Test Authentication
1. Open the app
2. You should see the login screen
3. If you have an account, login
4. If not, tap "Sign Up" and create an account
5. Verify you're redirected to the home screen

#### 5.2 Test Adding a Photocard
1. Tap the "+" button or navigate to "Add Photocard"
2. **You should NOT see "Authentication token is required" error**
3. The page should load successfully
4. Groups dropdown should be empty (since we deleted all data)

#### 5.3 Test Creating a Group
1. On the "Add Photocard" page
2. Tap the "+" button next to "K-pop Group"
3. Enter a group name (e.g., "BTS")
4. Tap "Create Group"
5. You should see "Group created successfully"
6. The group should appear in the dropdown

#### 5.4 Test Creating a Member
1. Select the group you just created
2. Tap the "+" button next to "Member"
3. Enter member name (e.g., "Jungkook")
4. Optionally enter stage name
5. Tap "Create Member"
6. You should see "Member created successfully"
7. The member should appear in the dropdown

#### 5.5 Test Creating an Album
1. Make sure a group is selected
2. Tap the "+" button next to "Album"
3. Enter album title (e.g., "Map of the Soul: 7")
4. Tap "Create Album"
5. You should see "Album created successfully"
6. The album should appear in the dropdown

#### 5.6 Test Adding a Photocard
1. Select an image
2. Select group, member, and album
3. Tap "Upload Photocard"
4. You should see "Photocard added successfully"
5. Navigate to "Collection" tab
6. You should see your photocard
7. **The photocard should NOT be automatically marked as owned**

#### 5.7 Test Owned/Wishlist Status
1. Tap on a photocard to view details
2. Tap "Add to Collection" button
3. The button should change to "Remove from Collection"
4. Go back and return to the photocard
5. It should still be marked as owned (status persists)
6. Tap "Add to Wishlist" button
7. The button should change to "Remove from Wishlist"

#### 5.8 Test User Separation
1. Log out
2. Create a new account with different email
3. Login with the new account
4. Navigate to "Add Photocard"
5. **You should NOT see the groups/members/albums from the first account**
6. Create your own groups/members/albums
7. Add photocards
8. Log out and log back in as the first user
9. **You should only see your own data**

### Step 6: Verify Overflow Fix
1. Create a group with a very long name:
   - "Super Long Group Name That Would Normally Overflow The Screen"
2. Create a member with a very long name:
   - "Super Long Member Name That Would Normally Overflow"
3. Add a photocard with this group and member
4. Tap on the photocard to view details
5. **The title in the app bar should show "..." instead of overflowing**

## Common Issues and Solutions

### Issue: "Authentication token is required"
**Solution:**
- Make sure you're logged in
- Try logging out and logging back in
- Check that backend server is running
- Verify the authentication fix was applied to `api_service.dart`

### Issue: "Column user_id does not exist"
**Solution:**
- Run the database migration
- Make sure you're connected to the correct database
- Check migration output for errors

### Issue: "Group does not exist or does not belong to you"
**Solution:**
- The group was created by another user
- Create your own group instead
- Make sure you're logged in as the correct user

### Issue: Backend won't start
**Solution:**
- Check `.env` file has all required variables
- Verify database connection details
- Make sure PostgreSQL is running
- Check for port conflicts (port 3000)

### Issue: Flutter build errors
**Solution:**
- Run `flutter clean`
- Run `flutter pub get`
- Restart your IDE
- Check for syntax errors in modified files

### Issue: Cards still showing as owned automatically
**Solution:**
- Make sure you pulled the latest code
- Check `collection_provider.dart` has the fix
- Try deleting and re-adding photocards
- Clear app data and restart

## Files Modified Summary

### Backend (4 files)
- ✅ `kardly-server/routes/groups.js` - Added auth, filter by user
- ✅ `kardly-server/routes/members.js` - Added auth, filter by user
- ✅ `kardly-server/routes/albums.js` - Added auth, filter by user
- ✅ `kardly-server/migrations/002_make_entities_user_specific.sql` - Database migration

### Frontend (2 files)
- ✅ `kardly-flutter/lib/core/services/api_service.dart` - Fixed auth token headers
- ✅ `kardly-flutter/lib/features/photocard/presentation/pages/photocard_detail_page.dart` - Fixed overflow
- ✅ `kardly-flutter/lib/features/collection/presentation/providers/collection_provider.dart` - Fixed auto-owned

## What's Different Now?

### Before
- ❌ All users shared groups, members, albums
- ❌ No authentication on group/member/album endpoints
- ❌ Text overflow on detail pages
- ❌ Cards automatically marked as owned
- ❌ No privacy or data separation

### After
- ✅ Each user has their own groups, members, albums
- ✅ All endpoints require authentication
- ✅ Clean UI with no overflow
- ✅ Cards start as unowned
- ✅ Complete privacy and data separation
- ✅ Better user experience

## Next Steps

1. ✅ Complete all testing steps above
2. ⏳ Consider adding user profile pictures
3. ⏳ Consider adding sharing/public collections feature
4. ⏳ Consider adding import/export functionality
5. ⏳ Consider adding token refresh mechanism
6. ⏳ Consider adding password reset functionality

## Need Help?

If you encounter issues:
1. Check the error message carefully
2. Review the relevant documentation file:
   - `FIXES_SUMMARY.md` - Overview of all fixes
   - `AUTHENTICATION_FIX.md` - Authentication token fix details
   - `USER_SPECIFIC_ENTITIES_MIGRATION.md` - Database migration details
3. Check backend logs for errors
4. Check Flutter console for errors
5. Verify all steps were completed in order

## Success Checklist

- [ ] Database migration applied successfully
- [ ] Backend server running without errors
- [ ] Flutter app builds and runs
- [ ] Can login/register
- [ ] Can create groups without auth errors
- [ ] Can create members without auth errors
- [ ] Can create albums without auth errors
- [ ] Can add photocards
- [ ] Photocards not automatically owned
- [ ] Can toggle owned/wishlist status
- [ ] Status persists after restart
- [ ] Different users see different data
- [ ] No overflow on detail pages
- [ ] All tests passing

If all items are checked, congratulations! Your Kardly app is fully updated and working! 🎉

