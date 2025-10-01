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

    // Build query - filter by authenticated user
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
        p.updated_at
      FROM photocards p
      LEFT JOIN kpop_groups g ON p.group_id = g.id
      LEFT JOIN group_members m ON p.member_id = m.id
      LEFT JOIN albums a ON p.album_id = a.id
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

module.exports = router;

