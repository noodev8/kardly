/**
 * Albums Routes
 * 
 * Endpoints for managing K-pop albums
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * POST /api/albums
 * Get all albums or filter by group
 */
router.post('/albums', [
  body('group_id').optional().isUUID(),
  body('search').optional().isString().trim(),
], async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 'VALIDATION_ERROR', 'Invalid request parameters', 400);
    }

    const { group_id, search } = req.body;

    let query = `
      SELECT
        a.id,
        a.group_id,
        a.title,
        a.cover_image_url,
        a.created_at,
        g.name as group_name
      FROM albums a
      LEFT JOIN kpop_groups g ON a.group_id = g.id
      WHERE 1=1
    `;
    const params = [];
    let paramCount = 0;

    // Filter by group if provided
    if (group_id) {
      paramCount++;
      query += ` AND a.group_id = $${paramCount}`;
      params.push(group_id);
    }

    // Add search filter if provided
    if (search) {
      paramCount++;
      query += ` AND LOWER(a.title) LIKE LOWER($${paramCount})`;
      params.push(`%${search}%`);
    }

    query += ' ORDER BY a.created_at DESC';

    const result = await db.query(query, params);

    return sendSuccess(res, {
      albums: result.rows,
      count: result.rows.length,
    }, 200);

  } catch (error) {
    console.error('Error fetching albums:', error);
    return sendError(res, 'SERVER_ERROR', 'Failed to fetch albums', 500);
  }
});

/**
 * POST /api/albums/create
 * Create a new album
 */
router.post('/albums/create', [
  body('group_id').notEmpty().isUUID(),
  body('title').notEmpty().trim().isLength({ min: 1, max: 200 }),
  body('cover_image_url').optional().isURL(),
], async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 'VALIDATION_ERROR', 'Invalid album data', 400);
    }

    const { group_id, title, cover_image_url } = req.body;

    // Verify group exists
    const groupCheck = await db.query(
      'SELECT id, name FROM kpop_groups WHERE id = $1',
      [group_id]
    );

    if (groupCheck.rows.length === 0) {
      return sendError(res, 'INVALID_GROUP', 'Group does not exist', 400);
    }

    // Check if album already exists for this group
    const existingAlbum = await db.query(
      'SELECT id, title FROM albums WHERE group_id = $1 AND LOWER(title) = LOWER($2)',
      [group_id, title]
    );

    if (existingAlbum.rows.length > 0) {
      return sendSuccess(res, {
        album_id: existingAlbum.rows[0].id,
        title: existingAlbum.rows[0].title,
        already_exists: true,
      }, 200);
    }

    // Create new album
    const result = await db.query(
      `INSERT INTO albums (group_id, title, cover_image_url)
       VALUES ($1, $2, $3)
       RETURNING id, group_id, title, cover_image_url, created_at`,
      [group_id, title, cover_image_url || null]
    );

    const newAlbum = result.rows[0];

    return sendSuccess(res, {
      album_id: newAlbum.id,
      group_id: newAlbum.group_id,
      title: newAlbum.title,
      cover_image_url: newAlbum.cover_image_url,
      created_at: newAlbum.created_at,
      already_exists: false,
    }, 201);

  } catch (error) {
    console.error('Error creating album:', error);
    return sendError(res, 'SERVER_ERROR', 'Failed to create album', 500);
  }
});

module.exports = router;

