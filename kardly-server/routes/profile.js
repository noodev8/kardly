/**
 * Profile Routes
 * 
 * Endpoints for managing user profiles
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const { sendSuccess, sendError } = require('../utils/response');
const { authenticateToken } = require('../middleware/auth');

/**
 * GET /api/profile
 * Get current user's profile information
 * Requires authentication
 */
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user_id = req.user.id;

    // Get user profile with collection stats
    const profileQuery = `
      SELECT 
        u.id,
        u.email,
        u.username,
        u.bio,
        u.is_premium,
        u.created_at,
        COUNT(DISTINCT CASE WHEN uc.is_owned = true THEN uc.photocard_id END) as owned_count,
        COUNT(DISTINCT CASE WHEN uc.is_wishlisted = true THEN uc.photocard_id END) as wishlist_count,
        COUNT(DISTINCT g.id) as groups_count,
        COUNT(DISTINCT gm.id) as members_count,
        COUNT(DISTINCT a.id) as albums_count
      FROM users u
      LEFT JOIN user_collections uc ON u.id = uc.user_id
      LEFT JOIN kpop_groups g ON u.id = g.user_id AND g.is_active = true
      LEFT JOIN group_members gm ON u.id = gm.user_id AND gm.is_active = true
      LEFT JOIN albums a ON u.id = a.user_id
      WHERE u.id = $1
      GROUP BY u.id, u.email, u.username, u.bio, u.is_premium, u.created_at
    `;

    const result = await db.query(profileQuery, [user_id]);

    if (result.rows.length === 0) {
      return sendError(res, 'USER_NOT_FOUND', 'User not found', 404);
    }

    const profile = result.rows[0];

    // Format the response
    const profileData = {
      id: profile.id,
      email: profile.email,
      username: profile.username,
      bio: profile.bio,
      is_premium: profile.is_premium,
      created_at: profile.created_at,
      stats: {
        owned_count: parseInt(profile.owned_count) || 0,
        wishlist_count: parseInt(profile.wishlist_count) || 0,
        groups_count: parseInt(profile.groups_count) || 0,
        members_count: parseInt(profile.members_count) || 0,
        albums_count: parseInt(profile.albums_count) || 0,
      }
    };

    sendSuccess(res, {
      message: 'Profile retrieved successfully',
      profile: profileData
    });
  } catch (error) {
    console.error('Error getting profile:', error);
    sendError(res, 'SERVER_ERROR', 'Failed to get profile', 500);
  }
});

/**
 * PUT /api/profile
 * Update current user's profile information
 * Requires authentication
 */
router.put('/profile', authenticateToken, [
  body('username').optional().trim().isLength({ min: 3, max: 50 }),
  body('bio').optional().trim().isLength({ max: 500 }),
], async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 'VALIDATION_ERROR', errors.array()[0].msg, 400);
    }

    const user_id = req.user.id;
    const { username, bio } = req.body;

    // Check if username is already taken (if provided)
    if (username) {
      const usernameCheck = await db.query(
        'SELECT id FROM users WHERE username = $1 AND id != $2',
        [username, user_id]
      );

      if (usernameCheck.rows.length > 0) {
        return sendError(res, 'USERNAME_EXISTS', 'Username is already taken', 400);
      }
    }

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramCount = 0;

    if (username !== undefined) {
      paramCount++;
      updates.push(`username = $${paramCount}`);
      values.push(username);
    }

    if (bio !== undefined) {
      paramCount++;
      updates.push(`bio = $${paramCount}`);
      values.push(bio);
    }

    if (updates.length === 0) {
      return sendError(res, 'NO_UPDATES', 'No valid fields to update', 400);
    }

    // Add updated_at
    paramCount++;
    updates.push(`updated_at = $${paramCount}`);
    values.push(new Date());

    // Add user_id for WHERE clause
    paramCount++;
    values.push(user_id);

    const updateQuery = `
      UPDATE users 
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING id, email, username, bio, is_premium, created_at, updated_at
    `;

    const result = await db.query(updateQuery, values);

    if (result.rows.length === 0) {
      return sendError(res, 'USER_NOT_FOUND', 'User not found', 404);
    }

    const updatedUser = result.rows[0];

    sendSuccess(res, {
      message: 'Profile updated successfully',
      profile: {
        id: updatedUser.id,
        email: updatedUser.email,
        username: updatedUser.username,
        bio: updatedUser.bio,
        is_premium: updatedUser.is_premium,
        created_at: updatedUser.created_at,
        updated_at: updatedUser.updated_at,
      }
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    sendError(res, 'SERVER_ERROR', 'Failed to update profile', 500);
  }
});

module.exports = router;
