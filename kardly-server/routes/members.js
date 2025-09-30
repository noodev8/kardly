/**
 * Members Routes
 * 
 * Endpoints for managing K-pop group members
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * POST /api/members
 * Get all members or filter by group
 */
router.post('/members', [
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
        m.id, 
        m.group_id, 
        m.name, 
        m.stage_name, 
        m.image_url, 
        m.is_active, 
        m.created_at,
        g.name as group_name
      FROM group_members m
      LEFT JOIN kpop_groups g ON m.group_id = g.id
      WHERE 1=1
    `;
    const params = [];
    let paramCount = 0;

    // Filter by group if provided
    if (group_id) {
      paramCount++;
      query += ` AND m.group_id = $${paramCount}`;
      params.push(group_id);
    }

    // Add search filter if provided
    if (search) {
      paramCount++;
      query += ` AND (LOWER(m.name) LIKE LOWER($${paramCount}) OR LOWER(m.stage_name) LIKE LOWER($${paramCount}))`;
      params.push(`%${search}%`);
    }

    query += ' ORDER BY m.name ASC';

    const result = await db.query(query, params);

    return sendSuccess(res, {
      members: result.rows,
      count: result.rows.length,
    }, 200);

  } catch (error) {
    console.error('Error fetching members:', error);
    return sendError(res, 'SERVER_ERROR', 'Failed to fetch members', 500);
  }
});

/**
 * POST /api/members/create
 * Create a new group member
 */
router.post('/members/create', [
  body('group_id').notEmpty().isUUID(),
  body('name').notEmpty().trim().isLength({ min: 1, max: 100 }),
  body('stage_name').optional().trim().isLength({ max: 100 }),
  body('image_url').optional().isURL(),
], async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 'VALIDATION_ERROR', 'Invalid member data', 400);
    }

    const { group_id, name, stage_name, image_url } = req.body;

    // Verify group exists
    const groupCheck = await db.query(
      'SELECT id, name FROM kpop_groups WHERE id = $1',
      [group_id]
    );

    if (groupCheck.rows.length === 0) {
      return sendError(res, 'INVALID_GROUP', 'Group does not exist', 400);
    }

    // Check if member already exists in this group
    const existingMember = await db.query(
      `SELECT id, name, stage_name
       FROM group_members
       WHERE group_id = $1 AND (LOWER(name) = LOWER($2) OR LOWER(stage_name) = LOWER($3))`,
      [group_id, name, stage_name || name]
    );

    if (existingMember.rows.length > 0) {
      return sendSuccess(res, {
        member_id: existingMember.rows[0].id,
        name: existingMember.rows[0].name,
        stage_name: existingMember.rows[0].stage_name,
        already_exists: true,
      }, 200);
    }

    // Create new member
    const result = await db.query(
      `INSERT INTO group_members (group_id, name, stage_name, image_url, is_active)
       VALUES ($1, $2, $3, $4, true)
       RETURNING id, group_id, name, stage_name, image_url, is_active, created_at`,
      [group_id, name, stage_name || null, image_url || null]
    );

    const newMember = result.rows[0];

    return sendSuccess(res, {
      member_id: newMember.id,
      group_id: newMember.group_id,
      name: newMember.name,
      stage_name: newMember.stage_name,
      image_url: newMember.image_url,
      is_active: newMember.is_active,
      created_at: newMember.created_at,
      already_exists: false,
    }, 201);

  } catch (error) {
    console.error('Error creating member:', error);
    return sendError(res, 'SERVER_ERROR', 'Failed to create member', 500);
  }
});

module.exports = router;

