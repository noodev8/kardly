/**
 * Groups Routes
 * 
 * Endpoints for managing K-pop groups
 */

const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const db = require('../config/database');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * POST /api/groups
 * Get all groups or search by name
 */
router.post('/groups', [
  body('search').optional().isString().trim(),
], async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 'VALIDATION_ERROR', 'Invalid request parameters', 400);
    }

    const { search } = req.body;

    let query = 'SELECT id, name, image_url, is_active, created_at FROM kpop_groups WHERE 1=1';
    const params = [];

    // Add search filter if provided
    if (search) {
      query += ' AND LOWER(name) LIKE LOWER($1)';
      params.push(`%${search}%`);
    }

    query += ' ORDER BY name ASC';

    const result = await db.query(query, params);

    return sendSuccess(res, {
      groups: result.rows,
      count: result.rows.length,
    }, 200);

  } catch (error) {
    console.error('Error fetching groups:', error);
    return sendError(res, 'SERVER_ERROR', 'Failed to fetch groups', 500);
  }
});

/**
 * POST /api/groups/create
 * Create a new K-pop group
 */
router.post('/groups/create', [
  body('name').notEmpty().trim().isLength({ min: 1, max: 100 }),
  body('image_url').optional().isURL(),
], async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 'VALIDATION_ERROR', 'Invalid group data', 400);
    }

    const { name, image_url } = req.body;

    // Check if group already exists
    const existingGroup = await db.query(
      'SELECT id, name FROM kpop_groups WHERE LOWER(name) = LOWER($1)',
      [name]
    );

    if (existingGroup.rows.length > 0) {
      return sendSuccess(res, {
        group_id: existingGroup.rows[0].id,
        name: existingGroup.rows[0].name,
        already_exists: true,
      }, 200);
    }

    // Create new group
    const result = await db.query(
      `INSERT INTO kpop_groups (name, image_url, is_active)
       VALUES ($1, $2, true)
       RETURNING id, name, image_url, is_active, created_at`,
      [name, image_url || null]
    );

    const newGroup = result.rows[0];

    return sendSuccess(res, {
      group_id: newGroup.id,
      name: newGroup.name,
      image_url: newGroup.image_url,
      is_active: newGroup.is_active,
      created_at: newGroup.created_at,
      already_exists: false,
    }, 201);

  } catch (error) {
    console.error('Error creating group:', error);
    return sendError(res, 'SERVER_ERROR', 'Failed to create group', 500);
  }
});

module.exports = router;

