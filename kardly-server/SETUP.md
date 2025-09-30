# Kardly Server - Quick Setup Guide

## 🚀 Quick Start

### Step 1: Configure Environment Variables

1. Copy the `.env.example` file from the project root to `.env`:
   ```bash
   # From the kardly project root
   cp .env.example .env
   ```

2. Edit the `.env` file with your actual credentials:

   **Database Configuration:**
   - Get your PostgreSQL connection details
   - Update `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`

   **Cloudinary Configuration:**
   - Sign up at https://cloudinary.com (free tier available)
   - Go to your dashboard: https://cloudinary.com/console
   - Copy your `Cloud Name`, `API Key`, and `API Secret`
   - Update `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`

### Step 2: Verify Database Schema

Make sure your PostgreSQL database has the schema loaded:

```bash
psql -U kardly_prod_user -d kardly_db -f kardly-docs/DB-schema.sql
```

### Step 3: Install Dependencies (Already Done!)

Dependencies are already installed. If you need to reinstall:

```bash
cd kardly-server
npm install
```

### Step 4: Start the Server

```bash
cd kardly-server
npm start
```

You should see:
```
✓ Database connected successfully
✓ Cloudinary connected successfully
============================================================
🚀 Kardly Server is running
📍 Port: 3000
🌍 Environment: development
📅 Started at: 2024-01-01T00:00:00.000Z
============================================================

Available endpoints:
  GET  /health - Health check
  POST /api/add_photocard - Add new photocard
============================================================
```

## 🧪 Testing the API

### Test 1: Health Check

```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "return_code": "SUCCESS",
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Test 2: Add Photocard (Image Only)

```bash
curl -X POST http://localhost:3000/api/add_photocard \
  -F "image=@/path/to/your/photocard.jpg"
```

Expected response:
```json
{
  "return_code": "SUCCESS",
  "photocard_id": "550e8400-e29b-41d4-a716-446655440000",
  "image_url": "https://res.cloudinary.com/.../photocard.jpg",
  "message": "Photocard added successfully"
}
```

### Test 3: Add Photocard with Metadata

First, get some valid UUIDs from your database:

```sql
-- Get a group ID
SELECT id, name FROM kpop_groups LIMIT 1;

-- Get a member ID (that belongs to the group)
SELECT id, name FROM group_members WHERE group_id = 'your-group-id' LIMIT 1;

-- Get an album ID (that belongs to the group)
SELECT id, title FROM albums WHERE group_id = 'your-group-id' LIMIT 1;
```

Then use those UUIDs:

```bash
curl -X POST http://localhost:3000/api/add_photocard \
  -F "image=@/path/to/your/photocard.jpg" \
  -F "group_id=your-group-uuid" \
  -F "member_id=your-member-uuid" \
  -F "album_id=your-album-uuid"
```

## 🔍 Troubleshooting

### Issue: "Database connection failed"

**Solution:**
1. Check if PostgreSQL is running: `pg_isready`
2. Verify credentials in `.env` file
3. Test connection: `psql -U kardly_prod_user -d kardly_db`
4. Check firewall settings

### Issue: "Cloudinary connection failed"

**Solution:**
1. Verify credentials in `.env` file
2. Check Cloudinary dashboard for API status
3. Ensure internet connectivity
4. Try regenerating API credentials in Cloudinary dashboard

### Issue: "INVALID_GROUP" error

**Solution:**
- The `group_id` you provided doesn't exist in the database
- Query the database to get valid group IDs:
  ```sql
  SELECT id, name FROM kpop_groups;
  ```

### Issue: "MEMBER_GROUP_MISMATCH" error

**Solution:**
- The member doesn't belong to the specified group
- Query to verify:
  ```sql
  SELECT m.id, m.name, m.group_id, g.name as group_name
  FROM group_members m
  JOIN kpop_groups g ON m.group_id = g.id
  WHERE m.id = 'your-member-id';
  ```

### Issue: "FILE_TOO_LARGE" error

**Solution:**
- Image file exceeds 5MB limit
- Compress or resize the image before uploading
- Use tools like ImageMagick or online compressors

### Issue: "INVALID_FILE_TYPE" error

**Solution:**
- Only JPG, JPEG, PNG, and WEBP formats are allowed
- Convert your image to a supported format

## 📊 Database Queries for Testing

### Insert Test Data

```sql
-- Insert a test K-pop group
INSERT INTO kpop_groups (name, is_active)
VALUES ('Test Group', true)
RETURNING id;

-- Insert a test member (use the group ID from above)
INSERT INTO group_members (group_id, name, stage_name, is_active)
VALUES ('your-group-id', 'Test Member', 'Test Stage Name', true)
RETURNING id;

-- Insert a test album (use the group ID from above)
INSERT INTO albums (group_id, title)
VALUES ('your-group-id', 'Test Album')
RETURNING id;
```

### View Uploaded Photocards

```sql
SELECT 
  p.id,
  p.image_url,
  g.name as group_name,
  m.name as member_name,
  a.title as album_title,
  p.created_at
FROM photocards p
LEFT JOIN kpop_groups g ON p.group_id = g.id
LEFT JOIN group_members m ON p.member_id = m.id
LEFT JOIN albums a ON p.album_id = a.id
ORDER BY p.created_at DESC
LIMIT 10;
```

## 🎯 Next Steps

1. **Test the endpoint** with various scenarios
2. **Verify images** are uploaded to Cloudinary
3. **Check database** to confirm records are created
4. **Implement authentication** (JWT) for protected routes
5. **Add more endpoints** (list photocards, update, delete, etc.)
6. **Set up rate limiting** for production
7. **Add logging** (Winston or similar)
8. **Write tests** (Jest, Mocha, etc.)

## 📝 Notes

- The server loads `.env` from the project root (parent directory)
- All API responses include a `return_code` field
- Images are stored in Cloudinary under `kardly/photocards` folder
- Database uses connection pooling for better performance
- Transactions ensure data consistency (rollback on errors)
- Cloudinary images are automatically cleaned up if database insert fails

## 🆘 Need Help?

Check the main README.md for detailed API documentation and examples.

