/**
=======================================================================================================================================
API Route: add_photocard
=======================================================================================================================================
Method: POST
Purpose: Add a new photocard to the database with image upload to Cloudinary
=======================================================================================================================================
Request Payload:
{
  "image": File,                       // File, required - The photocard image (jpg/jpeg/png/webp, max 5MB)
  "group_id": "uuid",                  // UUID, optional - Reference to kpop_groups table
  "member_id": "uuid",                 // UUID, optional - Reference to group_members table
  "album_id": "uuid"                   // UUID, optional - Reference to albums table
}

Success Response:
{
  "return_code": "SUCCESS",
  "photocard_id": "uuid",              // UUID, the generated photocard ID
  "image_url": "string",               // string, Cloudinary URL of uploaded image
  "message": "string"                  // string, success message
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"VALIDATION_ERROR"
"INVALID_GROUP"
"INVALID_MEMBER"
"INVALID_ALBUM"
"MEMBER_GROUP_MISMATCH"
"ALBUM_GROUP_MISMATCH"
"UPLOAD_FAILED"
"DATABASE_ERROR"
"SERVER_ERROR"
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const fs = require('fs').promises;
const path = require('path');
const os = require('os');
const { getClient } = require('../config/database');
const { uploadImage, deleteImage } = require('../config/cloudinary');
const { upload, handleUploadError } = require('../middleware/upload');
const { 
  validateAddPhotocard, 
  checkValidationResult, 
  validateImagePresent 
} = require('../middleware/validation');
const { 
  sendSuccess, 
  sendError, 
  sendServerError 
} = require('../utils/response');

/**
 * POST /api/add_photocard
 * Add a new photocard with image upload
 */
router.post(
  '/add_photocard',
  upload.single('image'),
  handleUploadError,
  validateImagePresent,
  validateAddPhotocard,
  checkValidationResult,
  async (req, res) => {
    let client;
    let tempFilePath;
    let cloudinaryPublicId;

    try {
      const { group_id, member_id, album_id } = req.body;
      const imageFile = req.file;

      // Get database client for transaction
      client = await getClient();
      await client.query('BEGIN');

      // Validate foreign key references if provided
      if (group_id) {
        const groupCheck = await client.query(
          'SELECT id FROM kpop_groups WHERE id = $1',
          [group_id]
        );
        
        if (groupCheck.rows.length === 0) {
          await client.query('ROLLBACK');
          return sendError(res, 'INVALID_GROUP', 'Group ID does not exist', 400);
        }
      }

      if (member_id) {
        const memberCheck = await client.query(
          'SELECT id, group_id FROM group_members WHERE id = $1',
          [member_id]
        );
        
        if (memberCheck.rows.length === 0) {
          await client.query('ROLLBACK');
          return sendError(res, 'INVALID_MEMBER', 'Member ID does not exist', 400);
        }

        // Validate member belongs to specified group (if group_id is provided)
        if (group_id && memberCheck.rows[0].group_id !== group_id) {
          await client.query('ROLLBACK');
          return sendError(
            res, 
            'MEMBER_GROUP_MISMATCH', 
            'Member does not belong to the specified group', 
            400
          );
        }
      }

      if (album_id) {
        const albumCheck = await client.query(
          'SELECT id, group_id FROM albums WHERE id = $1',
          [album_id]
        );
        
        if (albumCheck.rows.length === 0) {
          await client.query('ROLLBACK');
          return sendError(res, 'INVALID_ALBUM', 'Album ID does not exist', 400);
        }

        // Validate album belongs to specified group (if group_id is provided)
        if (group_id && albumCheck.rows[0].group_id !== group_id) {
          await client.query('ROLLBACK');
          return sendError(
            res, 
            'ALBUM_GROUP_MISMATCH', 
            'Album does not belong to the specified group', 
            400
          );
        }
      }

      // Write buffer to temporary file for Cloudinary upload
      const tempDir = os.tmpdir();
      const fileExtension = path.extname(imageFile.originalname);
      tempFilePath = path.join(tempDir, `photocard_${Date.now()}${fileExtension}`);
      await fs.writeFile(tempFilePath, imageFile.buffer);

      // Upload image to Cloudinary
      let uploadResult;
      try {
        uploadResult = await uploadImage(tempFilePath);
        cloudinaryPublicId = uploadResult.public_id;
      } catch (uploadError) {
        console.error('Cloudinary upload error:', uploadError);
        await client.query('ROLLBACK');
        
        // Clean up temp file
        try {
          await fs.unlink(tempFilePath);
        } catch (unlinkError) {
          console.error('Error deleting temp file:', unlinkError);
        }
        
        return sendError(
          res, 
          'UPLOAD_FAILED', 
          'Failed to upload image to Cloudinary', 
          500
        );
      }

      // Insert photocard into database
      const insertQuery = `
        INSERT INTO photocards (group_id, member_id, album_id, image_url)
        VALUES ($1, $2, $3, $4)
        RETURNING id, image_url, created_at, updated_at
      `;
      
      const insertValues = [
        group_id || null,
        member_id || null,
        album_id || null,
        uploadResult.url
      ];

      const insertResult = await client.query(insertQuery, insertValues);
      const photocard = insertResult.rows[0];

      // Commit transaction
      await client.query('COMMIT');

      // Clean up temp file
      try {
        await fs.unlink(tempFilePath);
      } catch (unlinkError) {
        console.error('Error deleting temp file:', unlinkError);
      }

      // Send success response
      return sendSuccess(res, {
        photocard_id: photocard.id,
        image_url: photocard.image_url,
        message: 'Photocard added successfully'
      }, 201);

    } catch (error) {
      console.error('Error adding photocard:', error);

      // Rollback transaction if active
      if (client) {
        try {
          await client.query('ROLLBACK');
        } catch (rollbackError) {
          console.error('Error rolling back transaction:', rollbackError);
        }
      }

      // Delete uploaded image from Cloudinary if it was uploaded
      if (cloudinaryPublicId) {
        try {
          await deleteImage(cloudinaryPublicId);
          console.log('Cleaned up Cloudinary image after error');
        } catch (deleteError) {
          console.error('Error deleting Cloudinary image:', deleteError);
        }
      }

      // Clean up temp file if it exists
      if (tempFilePath) {
        try {
          await fs.unlink(tempFilePath);
        } catch (unlinkError) {
          console.error('Error deleting temp file:', unlinkError);
        }
      }

      return sendServerError(res, 'Failed to add photocard');
    } finally {
      // Release database client
      if (client) {
        client.release();
      }
    }
  }
);

module.exports = router;

