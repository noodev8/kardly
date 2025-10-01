# Authentication Token Fix

## Problem
The app was showing "Failed to load groups: Authentication token is required" error when trying to add a photocard.

## Root Cause
The API service methods for groups, members, and albums were not including the authentication token in their requests. They were using hardcoded headers instead of the `_getHeaders()` method which includes the JWT token.

## Solution
Updated all API methods to use `_getHeaders()` instead of hardcoded headers.

## Files Modified

### `kardly-flutter/lib/core/services/api_service.dart`

**Methods Fixed:**
1. `getGroups()` - Line 351
2. `createGroup()` - Line 393
3. `getMembers()` - Line 436
4. `createMember()` - Line 485
5. `getAlbums()` - Line 528
6. `createAlbum()` - Line 573

**Before:**
```dart
final response = await http.post(
  uri,
  headers: {'Content-Type': 'application/json'},
  body: json.encode(body),
);
```

**After:**
```dart
final response = await http.post(
  uri,
  headers: _getHeaders(), // Now includes Authorization token
  body: json.encode(body),
);
```

## What `_getHeaders()` Does

The `_getHeaders()` method automatically includes the JWT token if the user is logged in:

```dart
static Map<String, String> _getHeaders() {
  final headers = {
    'Content-Type': 'application/json',
  };
  
  if (_authToken != null) {
    headers['Authorization'] = 'Bearer $_authToken';
  }
  
  return headers;
}
```

## Impact

### Before
- ❌ Groups, members, albums API calls failed with "Authentication token is required"
- ❌ Users couldn't add photocards
- ❌ Users couldn't create groups, members, or albums

### After
- ✅ All API calls include authentication token
- ✅ Users can add photocards
- ✅ Users can create groups, members, and albums
- ✅ Backend correctly identifies which user is making the request
- ✅ Data is properly filtered by user

## Testing

1. **Login:**
   - Open app
   - Login with your credentials
   - Token is stored in ApiService

2. **Add Photocard:**
   - Navigate to "Add Photocard" page
   - Page should load without errors
   - Groups dropdown should populate (if you have groups)
   - No "Authentication token is required" error

3. **Create Group:**
   - Tap the "+" button next to group dropdown
   - Enter group name
   - Group should be created successfully
   - Group should appear in dropdown

4. **Create Member:**
   - Select a group
   - Tap the "+" button next to member dropdown
   - Enter member name
   - Member should be created successfully
   - Member should appear in dropdown

5. **Create Album:**
   - Select a group
   - Tap the "+" button next to album dropdown
   - Enter album title
   - Album should be created successfully
   - Album should appear in dropdown

## Related Changes

This fix works in conjunction with the user-specific entities migration:
- Backend routes now require authentication
- Backend filters data by user_id
- Frontend sends authentication token with all requests
- Each user sees only their own data

## Next Steps

1. ✅ Run database migration (if not done yet)
2. ✅ Restart backend server
3. ✅ Hot reload or restart Flutter app
4. ✅ Test adding photocards
5. ✅ Test creating groups, members, albums

## Troubleshooting

### Still getting "Authentication token is required"
- Make sure you're logged in
- Check that login was successful
- Try logging out and logging back in
- Check backend logs for authentication errors

### Token expired
- JWT tokens expire after 7 days
- Log out and log back in to get a new token
- Consider implementing token refresh in the future

### Backend not running
- Make sure backend server is running on port 3000
- Check `kardly-server` terminal for errors
- Verify database connection is working

### Database migration not applied
- Run the migration script first
- See `USER_SPECIFIC_ENTITIES_MIGRATION.md` for instructions
- Backend will fail if migration is not applied

## Summary

The authentication fix ensures that all API requests include the JWT token, allowing the backend to:
1. Verify the user is logged in
2. Identify which user is making the request
3. Filter data by user_id
4. Enforce user-specific data separation

This is a critical fix that makes the user-specific entities feature work correctly!

