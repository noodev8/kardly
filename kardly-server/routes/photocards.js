/**
=======================================================================================================================================
API Route: photocards
=======================================================================================================================================
Method: POST
Purpose: Get all photocards with optional filters
=======================================================================================================================================
Request Payload:
{
  "group_id": "uuid",                  // UUID, optional - Filter by group
  "member_id": "uuid",                 // UUID, optional - Filter by member
  "album_id": "uuid",                  // UUID, optional - Filter by album
  "search": "string",                  // string, optional - Search in group/member/album names
  "limit": 50,                         // number, optional - Number of results (default: 50)
  "offset": 0                          // number, optional - Pagination offset (default: 0)
}

Success Response:
{
  "return_code": "SUCCESS",
  "photocards": [
    {
      "id": "uuid",
      "image_url": "string",
      "group_id": "uuid",
      "group_name": "string",
      "member_id": "uuid",
      "member_name": "string",
      "member_stage_name": "string",
      "album_id": "uuid",
      "album_title": "string",
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  ],
  "count": 10,
  "total": 100
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"VALIDATION_ERROR"
"SERVER_ERROR"
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const { sendSuccess, sendError } = require('../utils/response');
const { authenticateToken } = require('../middleware/auth');

/**
 * POST /api/photocards
 * Get all photocards for the authenticated user with optional filters
 * Requires authentication - only returns photocards owned by the user
 */
router.post('/photocards',
  authenticateToken,
  [
    body('group_id').optional().isUUID(),
    body('member_id').optional().isUUID(),
    body('album_id').optional().isUUID(),
    body('search').optional().isString().trim(),
    body('limit').optional().isInt({ min: 1, max: 100 }),
    body('offset').optional().isInt({ min: 0 }),
  ],
  async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 'VALIDATION_ERROR', 'Invalid request parameters', 400);
    }

    const { 
      group_id, 
      member_id, 
      album_id, 
      search,
      limit = 50,
      offset = 0 
    } = req.body;

    // Build query - filter by authenticated user and include collection status
    let query = `
      SELECT
        p.id,
        p.user_id,
        p.image_url,
        p.group_id,
        g.name as group_name,
        p.member_id,
        m.name as member_name,
        m.stage_name as member_stage_name,
        p.album_id,
        a.title as album_title,
        p.created_at,
        p.updated_at,
        COALESCE(uc.is_owned, false) as is_owned,
        COALESCE(uc.is_wishlisted, false) as is_wishlisted,
        COALESCE(uc.is_favorite, false) as is_favorite
      FROM photocards p
      LEFT JOIN kpop_groups g ON p.group_id = g.id
      LEFT JOIN group_members m ON p.member_id = m.id
      LEFT JOIN albums a ON p.album_id = a.id
      LEFT JOIN user_collections uc ON p.id = uc.photocard_id AND uc.user_id = p.user_id
      WHERE p.user_id = $1
    `;

    const params = [req.user.id];
    let paramCount = 1;

    // Filter by group
    if (group_id) {
      paramCount++;
      query += ` AND p.group_id = $${paramCount}`;
      params.push(group_id);
    }

    // Filter by member
    if (member_id) {
      paramCount++;
      query += ` AND p.member_id = $${paramCount}`;
      params.push(member_id);
    }

    // Filter by album
    if (album_id) {
      paramCount++;
      query += ` AND p.album_id = $${paramCount}`;
      params.push(album_id);
    }

    // Search filter
    if (search) {
      paramCount++;
      query += ` AND (
        LOWER(g.name) LIKE LOWER($${paramCount}) OR
        LOWER(m.name) LIKE LOWER($${paramCount}) OR
        LOWER(m.stage_name) LIKE LOWER($${paramCount}) OR
        LOWER(a.title) LIKE LOWER($${paramCount})
      )`;
      params.push(`%${search}%`);
    }

    // Get total count before pagination
    const countQuery = `SELECT COUNT(*) as total FROM (${query}) as filtered`;
    const countResult = await db.query(countQuery, params);
    const total = parseInt(countResult.rows[0].total);

    // Add ordering and pagination
    query += ` ORDER BY p.created_at DESC`;
    
    paramCount++;
    query += ` LIMIT $${paramCount}`;
    params.push(limit);
    
    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(offset);

    // Execute query
    const result = await db.query(query, params);

    return sendSuccess(res, {
      photocards: result.rows,
      count: result.rows.length,
      total: total,
      limit: limit,
      offset: offset,
    }, 200);

  } catch (error) {
    console.error('Error fetching photocards:', error);
    return sendError(res, 'SERVER_ERROR', 'Failed to fetch photocards', 500);
  }
});

/**
 * POST /api/photocards/:id/toggle-favorite
 * Toggle favorite status for a photocard
 * Requires authentication
 */
router.post('/photocards/:id/toggle-favorite',
  authenticateToken,
  async (req, res) => {
    try {
      const photocardId = req.params.id;
      const userId = req.user.id;

      // Validate UUID format
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
      if (!uuidRegex.test(photocardId)) {
        return sendError(res, 'VALIDATION_ERROR', 'Invalid photocard ID format', 400);
      }

      // Check if photocard exists and belongs to user
      const photocardCheck = await db.query(
        'SELECT id FROM photocards WHERE id = $1 AND user_id = $2',
        [photocardId, userId]
      );

      if (photocardCheck.rows.length === 0) {
        return sendError(res, 'NOT_FOUND', 'Photocard not found', 404);
      }

      // Check if collection entry exists
      const collectionCheck = await db.query(
        'SELECT is_favorite FROM user_collections WHERE user_id = $1 AND photocard_id = $2',
        [userId, photocardId]
      );

      let newFavoriteStatus;

      if (collectionCheck.rows.length === 0) {
        // Create new collection entry with favorite = true
        await db.query(
          'INSERT INTO user_collections (user_id, photocard_id, is_owned, is_wishlisted, is_favorite) VALUES ($1, $2, false, false, true)',
          [userId, photocardId]
        );
        newFavoriteStatus = true;
      } else {
        // Toggle existing favorite status
        const currentStatus = collectionCheck.rows[0].is_favorite;
        newFavoriteStatus = !currentStatus;

        await db.query(
          'UPDATE user_collections SET is_favorite = $1 WHERE user_id = $2 AND photocard_id = $3',
          [newFavoriteStatus, userId, photocardId]
        );
      }

      return sendSuccess(res, {
        message: newFavoriteStatus ? 'Added to favorites' : 'Removed from favorites',
        is_favorite: newFavoriteStatus,
        photocard_id: photocardId
      });

    } catch (error) {
      console.error('Error toggling favorite:', error);
      return sendError(res, 'SERVER_ERROR', 'Failed to toggle favorite status', 500);
    }
  }
);

/**
 * DELETE /api/photocards/:id
 * Delete a photocard
 * Requires authentication - only owner can delete
 */
router.delete('/photocards/:id',
  authenticateToken,
  async (req, res) => {
    try {
      const photocardId = req.params.id;
      const userId = req.user.id;

      // Validate UUID format
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
      if (!uuidRegex.test(photocardId)) {
        return sendError(res, 'VALIDATION_ERROR', 'Invalid photocard ID format', 400);
      }

      // Check if photocard exists and belongs to user
      const photocardCheck = await db.query(
        'SELECT id, image_url FROM photocards WHERE id = $1 AND user_id = $2',
        [photocardId, userId]
      );

      if (photocardCheck.rows.length === 0) {
        return sendError(res, 'NOT_FOUND', 'Photocard not found or access denied', 404);
      }

      const photocard = photocardCheck.rows[0];

      // Delete from user_collections first (foreign key constraint)
      await db.query(
        'DELETE FROM user_collections WHERE photocard_id = $1',
        [photocardId]
      );

      // Delete the photocard
      await db.query(
        'DELETE FROM photocards WHERE id = $1',
        [photocardId]
      );

      // TODO: Delete image from Cloudinary if needed
      // This would require extracting the public_id from the image_url
      // and calling deleteImage(public_id)

      return sendSuccess(res, {
        message: 'Photocard deleted successfully'
      });

    } catch (error) {
      console.error('Error deleting photocard:', error);
      return sendError(res, 'SERVER_ERROR', 'Failed to delete photocard', 500);
    }
  }
);

/**
 * PUT /api/photocards/:id
 * Update a photocard's metadata
 * Requires authentication - only owner can edit
 */
router.put('/photocards/:id',
  authenticateToken,
  [
    body('group_id').optional().isUUID(),
    body('member_id').optional().isUUID(),
    body('album_id').optional().isUUID(),
  ],
  async (req, res) => {
    try {
      // Validate request
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, 'VALIDATION_ERROR', 'Invalid request parameters', 400);
      }

      const photocardId = req.params.id;
      const userId = req.user.id;
      const { group_id, member_id, album_id } = req.body;

      // Validate UUID format
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
      if (!uuidRegex.test(photocardId)) {
        return sendError(res, 'VALIDATION_ERROR', 'Invalid photocard ID format', 400);
      }

      // Check if photocard exists and belongs to user
      const photocardCheck = await db.query(
        'SELECT id FROM photocards WHERE id = $1 AND user_id = $2',
        [photocardId, userId]
      );

      if (photocardCheck.rows.length === 0) {
        return sendError(res, 'NOT_FOUND', 'Photocard not found or access denied', 404);
      }

      // Validate foreign key references if provided
      if (group_id) {
        const groupCheck = await db.query(
          'SELECT id FROM kpop_groups WHERE id = $1',
          [group_id]
        );

        if (groupCheck.rows.length === 0) {
          return sendError(res, 'INVALID_GROUP', 'Group ID does not exist', 400);
        }
      }

      if (member_id) {
        const memberCheck = await db.query(
          'SELECT id FROM group_members WHERE id = $1',
          [member_id]
        );

        if (memberCheck.rows.length === 0) {
          return sendError(res, 'INVALID_MEMBER', 'Member ID does not exist', 400);
        }
      }

      if (album_id) {
        const albumCheck = await db.query(
          'SELECT id FROM albums WHERE id = $1',
          [album_id]
        );

        if (albumCheck.rows.length === 0) {
          return sendError(res, 'INVALID_ALBUM', 'Album ID does not exist', 400);
        }
      }

      // Update the photocard
      const updateQuery = `
        UPDATE photocards
        SET group_id = $1, member_id = $2, album_id = $3, updated_at = CURRENT_TIMESTAMP
        WHERE id = $4 AND user_id = $5
        RETURNING id, user_id, group_id, member_id, album_id, image_url, created_at, updated_at
      `;

      const updateResult = await db.query(updateQuery, [
        group_id || null,
        member_id || null,
        album_id || null,
        photocardId,
        userId
      ]);

      const updatedPhotocard = updateResult.rows[0];

      return sendSuccess(res, {
        message: 'Photocard updated successfully',
        photocard: updatedPhotocard
      });

    } catch (error) {
      console.error('Error updating photocard:', error);
      return sendError(res, 'SERVER_ERROR', 'Failed to update photocard', 500);
    }
  }
);

module.exports = router;

