# 🚀 Kardly Quick Start Guide

## Prerequisites

- Node.js (v16+)
- PostgreSQL database
- Flutter SDK (v3.0+)
- Cloudinary account (for image uploads)

## 1. Backend Setup (5 minutes)

### Step 1: Install Dependencies
```bash
cd kardly-server
npm install
```

### Step 2: Configure Environment
Make sure your `.env` file has these variables:
```env
# Database
DB_HOST=your-db-host
DB_PORT=5432
DB_NAME=kardly_db
DB_USER=your-db-user
DB_PASSWORD=your-db-password

# Cloudinary
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# JWT (already configured)
JWT_SECRET=a6ebd713bc7058b7326ccfe55c652d96074b59dafc251e142ffd40e1fa8b331df8813d7c54e3f590d68b731ae965145f6836d51411839a06937ace04350d2d644

# Server
PORT=3000
NODE_ENV=development
```

### Step 3: Run Database Migration (if needed)
If you haven't added the `user_id` column to photocards table:
```sql
-- Run this in your PostgreSQL database
ALTER TABLE photocards ADD COLUMN user_id UUID NOT NULL REFERENCES users(id);
CREATE INDEX idx_photocards_user_id ON photocards(user_id);
```

### Step 4: Start Server
```bash
npm start
```

You should see:
```
✓ Database connected successfully
✓ Cloudinary connected successfully
🚀 Kardly Server is running
📍 Port: 3000
```

### Step 5: Test Authentication (Optional)
```bash
node test-register-login.js
```

All tests should pass! ✓

## 2. Frontend Setup (3 minutes)

### Step 1: Install Dependencies
```bash
cd kardly-flutter
flutter pub get
```

### Step 2: Configure API URL
Check `lib/core/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3000';
```

Change to your server URL if different.

### Step 3: Run App
```bash
flutter run
```

Or use your IDE's run button.

## 3. First Use (2 minutes)

### Create Your Account
1. App opens to login screen
2. Tap "Sign Up"
3. Enter:
   - Email: `your@email.com`
   - Username: `yourname`
   - Password: `password123` (or better!)
4. Check "I accept the terms"
5. Tap "Sign Up"
6. See success message: "Welcome, yourname!"
7. Redirected to home screen

### Add Your First Photocard
1. From home screen, tap "+" button
2. Fill in:
   - Group name (e.g., "BTS")
   - Member name (e.g., "Jungkook")
   - Album name (e.g., "Map of the Soul: 7")
3. Upload a photo
4. Tap "Add Photocard"
5. See your photocard in your collection!

## 4. Test Everything Works

### Test Login
1. Tap profile icon
2. Tap "Sign Out"
3. Enter your email and password
4. Tap "Sign In"
5. See "Welcome back!" message
6. See your photocards still there

### Test User-Specific Collections
1. Create a second account (different email)
2. Add different photocards
3. Sign out and sign in as first user
4. Verify you only see your own photocards

## 5. Common Issues

### "Cannot connect to server"
- ✅ Check server is running: `npm start`
- ✅ Check API URL in `api_service.dart`
- ✅ Check firewall settings

### "Database connection failed"
- ✅ Check PostgreSQL is running
- ✅ Check `.env` database credentials
- ✅ Check database exists

### "Email already registered"
- ✅ This is normal - use a different email
- ✅ Or login with existing account

### "Token expired"
- ✅ This is normal after 7 days
- ✅ Just login again

### Flutter build errors
- ✅ Run `flutter clean`
- ✅ Run `flutter pub get`
- ✅ Restart IDE

## 6. Development Tips

### Backend Development
```bash
# Watch mode (auto-restart on changes)
npm install -g nodemon
nodemon server.js

# View logs
# Server logs appear in terminal

# Test endpoints
node test-register-login.js
```

### Frontend Development
```bash
# Hot reload is automatic in Flutter

# Check for issues
flutter analyze

# Format code
flutter format .

# Run tests
flutter test
```

### Database Management
```bash
# Connect to database
psql -h localhost -U your-user -d kardly_db

# View users
SELECT id, email, username, created_at FROM users;

# View photocards
SELECT p.id, u.username, p.image_url, p.created_at 
FROM photocards p 
JOIN users u ON p.user_id = u.id;

# Count photocards per user
SELECT u.username, COUNT(p.id) as photocard_count
FROM users u
LEFT JOIN photocards p ON u.id = p.user_id
GROUP BY u.username;
```

## 7. API Endpoints Reference

### Authentication
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/verify
```

### Photocards (Requires Auth)
```
POST /api/add_photocard
GET  /api/photocards
```

### Collection (Requires Auth)
```
POST /api/collection/toggle-owned
POST /api/collection/toggle-wishlist
POST /api/collection/status
```

### Health Check
```
GET /health
```

## 8. Next Steps

### Recommended Enhancements
1. **Token Persistence**
   - Install `flutter_secure_storage`
   - Store token on login
   - Auto-login on app start

2. **Password Reset**
   - Add forgot password screen
   - Send reset email
   - Implement reset flow

3. **Email Verification**
   - Send verification email
   - Add verification screen
   - Mark users as verified

4. **Profile Management**
   - Edit username
   - Change password
   - Upload profile picture

5. **Social Features**
   - Follow other users
   - View public collections
   - Trading system

## 9. Deployment

### Backend Deployment (Heroku Example)
```bash
# Install Heroku CLI
heroku login

# Create app
heroku create kardly-api

# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Set environment variables
heroku config:set JWT_SECRET=your-secret
heroku config:set CLOUDINARY_CLOUD_NAME=your-name
# ... etc

# Deploy
git push heroku main
```

### Frontend Deployment
```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web
```

## 10. Support

### Documentation
- `AUTHENTICATION_SETUP.md` - Detailed auth setup
- `UI_AUTHENTICATION.md` - UI design guide
- `USER_SPECIFIC_PHOTOCARDS.md` - Architecture overview
- `DB-schema.sql` - Database schema

### Testing
- `test-register-login.js` - Backend auth tests
- `test-auth.js` - JWT token tests

### Need Help?
- Check the documentation files
- Review the code comments
- Test with the provided test scripts

## 🎉 You're Ready!

Your Kardly app is now fully set up with:
- ✅ User authentication
- ✅ Secure password storage
- ✅ JWT token system
- ✅ User-specific photocards
- ✅ Beautiful UI
- ✅ Complete error handling

Start collecting K-Pop photocards! 🎴✨

