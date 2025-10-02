# Kardly Server

Backend server for Kardly - K-Pop photocard collection app.

## Tech Stack

- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **PostgreSQL** - Database (direct connection with pg library)
- **Cloudinary** - Image hosting and management
- **Multer** - File upload handling
- **Express Validator** - Request validation

## Project Structure

```
kardly-server/
├── server.js                    # Main entry point
├── config/
│   ├── database.js             # PostgreSQL connection pool
│   └── cloudinary.js           # Cloudinary configuration
├── middleware/
│   ├── upload.js               # Multer file upload middleware
│   └── validation.js           # Request validation middleware
├── routes/
│   └── add_photocard.js        # POST /api/add_photocard
├── utils/
│   └── response.js             # Standardized response helpers
└── package.json
```

## Setup Instructions

### Prerequisites

- Node.js (v14 or higher)
- PostgreSQL database (with schema from `kardly-docs/DB-schema.sql`)
- Cloudinary account

### Installation

1. **Install dependencies:**
   ```bash
   cd kardly-server
   npm install
   ```

2. **Configure environment variables:**
   - Copy `.env.example` to `.env` in the project root (parent directory)
   - Fill in your actual values:
     ```env
     # Database
     DB_HOST=localhost
     DB_PORT=5432
     DB_NAME=kardly_db
     DB_USER=kardly_prod_user
     DB_PASSWORD=your_password

     # Cloudinary
     CLOUDINARY_CLOUD_NAME=your_cloud_name
     CLOUDINARY_API_KEY=your_api_key
     CLOUDINARY_API_SECRET=your_api_secret

     # Server
     PORT=3000
     NODE_ENV=development
     ```

3. **Ensure database is set up:**
   - Make sure PostgreSQL is running
   - Database schema should be created using `kardly-docs/DB-schema.sql`

### Running the Server

**Development mode:**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

The server will start on `http://localhost:3000` (or the port specified in `.env`).

## API Endpoints

### Health Check

**GET** `/health`

Check if the server is running.

**Response:**
```json
{
  "return_code": "SUCCESS",
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

### Add Photocard

**POST** `/api/add_photocard`

Add a new photocard to the database with image upload to Cloudinary.

**Content-Type:** `multipart/form-data`

**Request Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | File | Yes | Photocard image (JPG/JPEG/PNG/WEBP, max 5MB) |
| `group_id` | UUID | No | Reference to kpop_groups table |
| `member_id` | UUID | No | Reference to group_members table |
| `album_id` | UUID | No | Reference to albums table |

**Success Response (201):**
```json
{
  "return_code": "SUCCESS",
  "photocard_id": "550e8400-e29b-41d4-a716-446655440000",
  "image_url": "https://res.cloudinary.com/your-cloud/image/upload/v1234567890/kardly/photocards/abc123.jpg",
  "message": "Photocard added successfully"
}
```

**Error Responses:**

| Return Code | Status | Description |
|-------------|--------|-------------|
| `VALIDATION_ERROR` | 400 | Invalid request data (missing image, invalid UUIDs) |
| `INVALID_GROUP` | 400 | Group ID does not exist |
| `INVALID_MEMBER` | 400 | Member ID does not exist |
| `INVALID_ALBUM` | 400 | Album ID does not exist |
| `MEMBER_GROUP_MISMATCH` | 400 | Member does not belong to specified group |
| `ALBUM_GROUP_MISMATCH` | 400 | Album does not belong to specified group |
| `FILE_TOO_LARGE` | 400 | File size exceeds 5MB limit |
| `INVALID_FILE_TYPE` | 400 | File type not allowed |
| `UPLOAD_FAILED` | 500 | Failed to upload image to Cloudinary |
| `SERVER_ERROR` | 500 | Internal server error |

**Example Error Response:**
```json
{
  "return_code": "VALIDATION_ERROR",
  "message": "Image file is required"
}
```

---

## Testing the API

### Using cURL

**Add photocard with image only:**
```bash
curl -X POST http://localhost:3000/api/add_photocard \
  -F "image=@/path/to/photocard.jpg"
```

**Add photocard with all fields:**
```bash
curl -X POST http://localhost:3000/api/add_photocard \
  -F "image=@/path/to/photocard.jpg" \
  -F "group_id=550e8400-e29b-41d4-a716-446655440000" \
  -F "member_id=660e8400-e29b-41d4-a716-446655440001" \
  -F "album_id=770e8400-e29b-41d4-a716-446655440002"
```

### Using Postman

1. Set method to **POST**
2. URL: `http://localhost:3000/api/add_photocard`
3. Go to **Body** tab
4. Select **form-data**
5. Add fields:
   - `image` (type: File) - Select your image file
   - `group_id` (type: Text) - Optional UUID
   - `member_id` (type: Text) - Optional UUID
   - `album_id` (type: Text) - Optional UUID
6. Click **Send**

## Features

### Image Upload
- Accepts JPG, JPEG, PNG, and WEBP formats
- Maximum file size: 5MB
- Automatic upload to Cloudinary
- Images stored in `kardly/photocards` folder

### Validation
- File type and size validation
- UUID format validation for foreign keys
- Foreign key existence validation
- Relationship validation (member belongs to group, album belongs to group)

### Error Handling
- Comprehensive error handling with descriptive messages
- Database transaction rollback on errors
- Automatic Cloudinary cleanup if database insert fails
- Temporary file cleanup

### Security
- Helmet.js for security headers
- CORS enabled
- Parameterized SQL queries to prevent injection
- File type validation
- File size limits

## Database Schema

The photocard table structure:

```sql
CREATE TABLE public.photocards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid,
    member_id uuid,
    album_id uuid,
    image_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
```

**Foreign Key Relationships:**
- `group_id` → `kpop_groups(id)` ON DELETE CASCADE
- `member_id` → `group_members(id)` ON DELETE CASCADE
- `album_id` → `albums(id)` ON DELETE CASCADE

## Troubleshooting

### Database Connection Issues
- Verify PostgreSQL is running
- Check database credentials in `.env`
- Ensure database exists and schema is loaded
- Check firewall/network settings

### Cloudinary Upload Issues
- Verify Cloudinary credentials in `.env`
- Check Cloudinary account limits
- Ensure internet connectivity
- Check Cloudinary dashboard for errors

### File Upload Issues
- Verify file size is under 5MB
- Check file format (JPG/JPEG/PNG/WEBP only)
- Ensure `Content-Type: multipart/form-data` header is set
- Check server disk space for temporary files

## Development Notes

### API Design Principles
- All routes use POST method (per project rules)
- All responses include `return_code` field
- Simplified JSON responses
- Lowercase filenames
- Standardized route documentation headers

### Future Enhancements
- Authentication/authorization (JWT)
- Rate limiting
- Image optimization and resizing
- Batch upload support
- Admin approval workflow
- Pagination for listing photocards
- Search and filter endpoints

## License

ISC

