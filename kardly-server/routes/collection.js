/**
 * Collection Routes
 * 
 * Endpoints for managing user's photocard collection status (owned/wishlist)
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const { sendSuccess, sendError } = require('../utils/response');
const { authenticateToken } = require('../middleware/auth');

/**
 * POST /api/collection/toggle-owned
 * Toggle owned status for a photocard
 */
router.post('/collection/toggle-owned', 
  authenticateToken,
  [
    body('photocard_id').notEmpty().isUUID().withMessage('photocard_id must be a valid UUID'),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, 'VALIDATION_ERROR', 'Invalid request parameters', 400);
      }

      const { photocard_id } = req.body;
      const user_id = req.user.id;

      // Check if photocard exists and belongs to user
      const photocardCheck = await db.query(
        'SELECT id, user_id FROM photocards WHERE id = $1',
        [photocard_id]
      );

      if (photocardCheck.rows.length === 0) {
        return sendError(res, 'PHOTOCARD_NOT_FOUND', 'Photocard not found', 404);
      }

      if (photocardCheck.rows[0].user_id !== user_id) {
        return sendError(res, 'UNAUTHORIZED', 'You do not own this photocard', 403);
      }

      // Check if collection entry exists
      const collectionCheck = await db.query(
        'SELECT id, is_owned FROM user_collections WHERE user_id = $1 AND photocard_id = $2',
        [user_id, photocard_id]
      );

      let isOwned;
      if (collectionCheck.rows.length === 0) {
        // Create new collection entry with is_owned = true
        await db.query(
          'INSERT INTO user_collections (user_id, photocard_id, is_owned) VALUES ($1, $2, $3)',
          [user_id, photocard_id, true]
        );
        isOwned = true;
      } else {
        // Toggle existing is_owned status
        isOwned = !collectionCheck.rows[0].is_owned;
        await db.query(
          'UPDATE user_collections SET is_owned = $1, updated_at = CURRENT_TIMESTAMP WHERE user_id = $2 AND photocard_id = $3',
          [isOwned, user_id, photocard_id]
        );
      }

      return sendSuccess(res, {
        photocard_id,
        is_owned: isOwned,
        message: isOwned ? 'Added to collection' : 'Removed from collection'
      });
    } catch (error) {
      console.error('Error toggling owned status:', error);
      return sendError(res, 'SERVER_ERROR', 'Failed to update collection', 500);
    }
  }
);

/**
 * POST /api/collection/toggle-wishlist
 * Toggle wishlist status for a photocard
 */
router.post('/collection/toggle-wishlist', 
  authenticateToken,
  [
    body('photocard_id').notEmpty().isUUID().withMessage('photocard_id must be a valid UUID'),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, 'VALIDATION_ERROR', 'Invalid request parameters', 400);
      }

      const { photocard_id } = req.body;
      const user_id = req.user.id;

      // Check if photocard exists and belongs to user
      const photocardCheck = await db.query(
        'SELECT id, user_id FROM photocards WHERE id = $1',
        [photocard_id]
      );

      if (photocardCheck.rows.length === 0) {
        return sendError(res, 'PHOTOCARD_NOT_FOUND', 'Photocard not found', 404);
      }

      if (photocardCheck.rows[0].user_id !== user_id) {
        return sendError(res, 'UNAUTHORIZED', 'You do not own this photocard', 403);
      }

      // Check if collection entry exists
      const collectionCheck = await db.query(
        'SELECT id, is_wishlisted FROM user_collections WHERE user_id = $1 AND photocard_id = $2',
        [user_id, photocard_id]
      );

      let isWishlisted;
      if (collectionCheck.rows.length === 0) {
        // Create new collection entry with is_wishlisted = true
        await db.query(
          'INSERT INTO user_collections (user_id, photocard_id, is_wishlisted) VALUES ($1, $2, $3)',
          [user_id, photocard_id, true]
        );
        isWishlisted = true;
      } else {
        // Toggle existing is_wishlisted status
        isWishlisted = !collectionCheck.rows[0].is_wishlisted;
        await db.query(
          'UPDATE user_collections SET is_wishlisted = $1, updated_at = CURRENT_TIMESTAMP WHERE user_id = $2 AND photocard_id = $3',
          [isWishlisted, user_id, photocard_id]
        );
      }

      return sendSuccess(res, {
        photocard_id,
        is_wishlisted: isWishlisted,
        message: isWishlisted ? 'Added to wishlist' : 'Removed from wishlist'
      });
    } catch (error) {
      console.error('Error toggling wishlist status:', error);
      return sendError(res, 'SERVER_ERROR', 'Failed to update wishlist', 500);
    }
  }
);

/**
 * POST /api/collection/status
 * Get collection status for photocards (owned/wishlist flags)
 */
router.post('/collection/status',
  authenticateToken,
  [
    body('photocard_ids').isArray().withMessage('photocard_ids must be an array'),
    body('photocard_ids.*').isUUID().withMessage('Each photocard_id must be a valid UUID'),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, 'VALIDATION_ERROR', 'Invalid request parameters', 400);
      }

      const { photocard_ids } = req.body;
      const user_id = req.user.id;

      if (photocard_ids.length === 0) {
        return sendSuccess(res, { statuses: [] });
      }

      // Get collection status for all requested photocards
      const result = await db.query(
        `SELECT photocard_id, is_owned, is_wishlisted, is_favorite
         FROM user_collections
         WHERE user_id = $1 AND photocard_id = ANY($2)`,
        [user_id, photocard_ids]
      );

      // Create a map of photocard_id to status
      const statusMap = {};
      result.rows.forEach(row => {
        statusMap[row.photocard_id] = {
          is_owned: row.is_owned,
          is_wishlisted: row.is_wishlisted
        };
      });

      // Fill in missing entries with default values
      const statuses = photocard_ids.map(id => ({
        photocard_id: id,
        is_owned: statusMap[id]?.is_owned || false,
        is_wishlisted: statusMap[id]?.is_wishlisted || false
      }));

      return sendSuccess(res, { statuses });
    } catch (error) {
      console.error('Error getting collection status:', error);
      return sendError(res, 'SERVER_ERROR', 'Failed to get collection status', 500);
    }
  }
);

/**
 * POST /api/collection/photocards
 * Get photocards by collection status (owned, wishlist, unallocated, favorites)
 */
router.post('/collection/photocards',
  authenticateToken,
  [
    body('status').isIn(['owned', 'wishlist', 'unallocated', 'favorites']).withMessage('status must be owned, wishlist, unallocated, or favorites'),
    body('limit').optional().isInt({ min: 1, max: 100 }),
    body('offset').optional().isInt({ min: 0 }),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return sendError(res, 'VALIDATION_ERROR', 'Invalid request parameters', 400);
      }

      const { status, limit = 50, offset = 0 } = req.body;
      const user_id = req.user.id;

      let whereClause;
      switch (status) {
        case 'owned':
          whereClause = 'uc.is_owned = true';
          break;
        case 'wishlist':
          whereClause = 'uc.is_wishlisted = true';
          break;
        case 'unallocated':
          whereClause = 'uc.is_owned = false AND uc.is_wishlisted = false';
          break;
        case 'favorites':
          whereClause = 'uc.is_favorite = true';
          break;
      }

      const query = `
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
          uc.is_owned,
          uc.is_wishlisted,
          uc.is_favorite
        FROM photocards p
        INNER JOIN user_collections uc ON p.id = uc.photocard_id
        LEFT JOIN kpop_groups g ON p.group_id = g.id
        LEFT JOIN group_members m ON p.member_id = m.id
        LEFT JOIN albums a ON p.album_id = a.id
        WHERE p.user_id = $1 AND uc.user_id = $1 AND ${whereClause}
        ORDER BY p.created_at DESC
        LIMIT $2 OFFSET $3
      `;

      const result = await db.query(query, [user_id, limit, offset]);

      return sendSuccess(res, {
        photocards: result.rows,
        count: result.rows.length,
        status: status
      });
    } catch (error) {
      console.error('Error getting collection photocards:', error);
      return sendError(res, 'SERVER_ERROR', 'Failed to get collection photocards', 500);
    }
  }
);

module.exports = router;

