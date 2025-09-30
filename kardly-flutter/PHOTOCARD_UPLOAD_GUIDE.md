# Photocard Upload Feature - Frontend Guide

## 🎉 What's Been Added

A complete photocard upload feature has been implemented in the Flutter app, allowing users to:
- Select images from gallery or camera
- Upload photocards to the backend server
- Optionally provide metadata (group ID, member ID, album ID)
- View upload progress and success/error messages

## 📁 Files Created

### 1. **API Service** (`lib/core/services/api_service.dart`)
- Handles HTTP communication with the Node.js backend
- Implements `addPhotocard()` method for multipart/form-data uploads
- Custom `ApiException` class for error handling
- Health check endpoint for server connectivity

### 2. **Provider** (`lib/features/photocard/presentation/providers/add_photocard_provider.dart`)
- State management for photocard upload
- Loading states, error handling, success messages
- Integrates with API service

### 3. **Add Photocard Page** (`lib/features/photocard/presentation/pages/add_photocard_page.dart`)
- Complete UI for uploading photocards
- Image picker (gallery or camera)
- Form with optional metadata fields
- UUID validation for group/member/album IDs
- Error and success message display

### 4. **Updated Files**
- `pubspec.yaml` - Added `http` package
- `lib/core/router/app_router.dart` - Added `/add-photocard` route
- `lib/core/providers/app_providers.dart` - Registered `AddPhotocardProvider`
- `lib/features/home/presentation/pages/home_page.dart` - Added "Add Photocard" quick action button

## 🚀 How to Use

### For Users

1. **Navigate to Add Photocard**
   - From the home page, tap the "Add Photocard" quick action button
   - Or navigate directly to `/add-photocard`

2. **Select an Image**
   - Tap the image picker area
   - Choose "Gallery" or "Camera"
   - Select/take a photo of the photocard

3. **Add Metadata (Optional)**
   - Enter Group ID (UUID format)
   - Enter Member ID (UUID format)
   - Enter Album ID (UUID format)
   - All fields are optional but must be valid UUIDs if provided

4. **Upload**
   - Tap "Upload Photocard" button
   - Wait for upload to complete
   - Success message will appear and navigate back automatically

### For Developers

#### Server URL Configuration

Update the server URL in `lib/core/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:3000';
```

**Important:** Change based on your environment:
- **Local development (iOS Simulator):** `http://localhost:3000`
- **Local development (Android Emulator):** `http://10.0.2.2:3000`
- **Physical device on same network:** `http://YOUR_COMPUTER_IP:3000`
- **Production:** `https://your-production-url.com`

#### Testing the Feature

1. **Start the backend server:**
   ```bash
   cd kardly-server
   npm start
   ```

2. **Run the Flutter app:**
   ```bash
   cd kardly-flutter
   flutter run
   ```

3. **Test upload:**
   - Navigate to Add Photocard page
   - Select an image
   - Submit (with or without metadata)
   - Check backend logs for upload confirmation

## 🎨 UI Features

### Image Picker
- Beautiful placeholder with dashed border
- Shows selected image preview
- Remove button to clear selection
- Supports both gallery and camera

### Form Validation
- UUID format validation for all ID fields
- Required field indicator for image
- Clear error messages
- Real-time validation feedback

### Loading States
- Loading spinner on submit button
- Disabled button during upload
- Progress indication

### Error Handling
- Network errors (server unreachable)
- Validation errors (invalid UUIDs)
- Server errors (upload failed, invalid IDs)
- User-friendly error messages
- Error banner with icon

### Success Feedback
- Success snackbar message
- Auto-navigation back to previous screen
- Uploaded photocard data available in provider

## 🔧 API Integration

### Request Format

The app sends a `multipart/form-data` POST request to `/api/add_photocard`:

```
POST http://localhost:3000/api/add_photocard
Content-Type: multipart/form-data

Fields:
- image: File (required)
- group_id: String (optional, UUID)
- member_id: String (optional, UUID)
- album_id: String (optional, UUID)
```

### Response Handling

**Success (201):**
```json
{
  "return_code": "SUCCESS",
  "photocard_id": "uuid",
  "image_url": "https://res.cloudinary.com/...",
  "message": "Photocard added successfully"
}
```

**Error (4xx/5xx):**
```json
{
  "return_code": "ERROR_CODE",
  "message": "Error description"
}
```

### Error Codes Handled

| Return Code | User Message |
|-------------|--------------|
| `VALIDATION_ERROR` | Please check your input and try again |
| `INVALID_GROUP` | The selected group does not exist |
| `INVALID_MEMBER` | The selected member does not exist |
| `INVALID_ALBUM` | The selected album does not exist |
| `MEMBER_GROUP_MISMATCH` | Member doesn't belong to chosen group |
| `ALBUM_GROUP_MISMATCH` | Album doesn't belong to chosen group |
| `FILE_TOO_LARGE` | Image file is too large (max 5MB) |
| `INVALID_FILE_TYPE` | Invalid file type (use JPG/PNG/WEBP) |
| `UPLOAD_FAILED` | Failed to upload image |
| `NETWORK_ERROR` | Cannot connect to server |
| `SERVER_ERROR` | Server error, try again later |

## 📱 Platform-Specific Notes

### iOS
- Requires camera and photo library permissions in `Info.plist`
- Already configured in the project

### Android
- Requires storage and camera permissions in `AndroidManifest.xml`
- Already configured in the project

### Web
- Image picker works with file input
- Camera option may not be available

## 🧪 Testing Scenarios

### 1. Basic Upload (Image Only)
- Select image
- Submit without metadata
- Should succeed

### 2. Full Metadata Upload
- Select image
- Enter valid UUIDs for all fields
- Submit
- Should succeed

### 3. Invalid UUID
- Select image
- Enter invalid UUID (e.g., "123")
- Submit
- Should show validation error

### 4. No Image
- Don't select image
- Try to submit
- Should show "Please select an image" error

### 5. Server Offline
- Stop backend server
- Try to upload
- Should show "Cannot connect to server" error

### 6. Large File
- Select image > 5MB
- Submit
- Should show "File too large" error

## 🔮 Future Enhancements

### Planned Features
1. **Dropdown selectors** for groups/members/albums instead of UUID input
2. **Image cropping** before upload
3. **Multiple image upload** (batch)
4. **Upload progress bar** with percentage
5. **Draft saving** (save form data locally)
6. **Recent uploads** list
7. **Image compression** before upload
8. **OCR text extraction** from photocard
9. **Auto-fill metadata** from image analysis

### API Enhancements Needed
1. **GET /api/groups** - List all K-pop groups
2. **GET /api/members?group_id=xxx** - List members by group
3. **GET /api/albums?group_id=xxx** - List albums by group
4. **GET /api/photocards** - List uploaded photocards
5. **Authentication** - JWT token validation

## 🐛 Troubleshooting

### "Cannot connect to server"
- Check if backend server is running
- Verify `baseUrl` in `api_service.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`
- Check firewall settings

### "Invalid file type"
- Only JPG, JPEG, PNG, and WEBP are supported
- Check file extension
- Try a different image

### "Validation error"
- Ensure UUIDs are in correct format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- All characters must be lowercase hexadecimal
- Use hyphens in correct positions

### Image not uploading
- Check file size (max 5MB)
- Ensure internet connection
- Check backend logs for errors
- Verify Cloudinary credentials in backend

## 📚 Code Examples

### Using the API Service Directly

```dart
import 'package:kardly/core/services/api_service.dart';

// Upload photocard
try {
  final result = await ApiService.addPhotocard(
    imagePath: '/path/to/image.jpg',
    groupId: 'uuid-here',
    memberId: 'uuid-here',
    albumId: 'uuid-here',
  );
  
  print('Success: ${result['photocard_id']}');
  print('Image URL: ${result['image_url']}');
} on ApiException catch (e) {
  print('Error: ${e.getUserFriendlyMessage()}');
}
```

### Using the Provider

```dart
import 'package:provider/provider.dart';
import 'package:kardly/features/photocard/presentation/providers/add_photocard_provider.dart';

// In your widget
final provider = context.read<AddPhotocardProvider>();

final success = await provider.addPhotocard(
  imagePath: imagePath,
  groupId: groupId,
  memberId: memberId,
  albumId: albumId,
);

if (success) {
  print('Uploaded: ${provider.uploadedPhotocard}');
} else {
  print('Error: ${provider.error}');
}
```

## ✅ Summary

The photocard upload feature is **fully functional** and ready to use! 

**What works:**
✅ Image selection from gallery/camera
✅ Image preview and removal
✅ Optional metadata input with validation
✅ Upload to backend server
✅ Error handling with user-friendly messages
✅ Success feedback and navigation
✅ Loading states and progress indication

**Next steps:**
1. Configure server URL for your environment
2. Ensure backend server is running
3. Test the upload flow
4. Consider implementing dropdown selectors for better UX
5. Add authentication when ready

