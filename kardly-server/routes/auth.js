/**
 * Authentication Routes
 * 
 * Endpoints for user registration and login
 */

const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const { sendSuccess, sendError } = require('../utils/response');
const { authenticateToken } = require('../middleware/auth');
const { generateToken } = require('../middleware/auth');

/**
 * POST /api/auth/register
 * Register a new user
 */
router.post('/auth/register', [
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  body('username').trim().isLength({ min: 3, max: 50 }).withMessage('Username must be 3-50 characters'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
], async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 'VALIDATION_ERROR', errors.array()[0].msg, 400);
    }

    const { email, username, password } = req.body;

    // Check if email already exists
    const emailCheck = await db.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (emailCheck.rows.length > 0) {
      return sendError(res, 'EMAIL_EXISTS', 'Email is already registered', 400);
    }

    // Check if username already exists
    const usernameCheck = await db.query(
      'SELECT id FROM users WHERE username = $1',
      [username]
    );

    if (usernameCheck.rows.length > 0) {
      return sendError(res, 'USERNAME_EXISTS', 'Username is already taken', 400);
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Insert new user
    const insertQuery = `
      INSERT INTO users (email, username, password_hash)
      VALUES ($1, $2, $3)
      RETURNING id, email, username, is_premium, created_at
    `;

    const result = await db.query(insertQuery, [email, username, passwordHash]);
    const user = result.rows[0];

    // Generate JWT token
    const token = generateToken(user);

    return sendSuccess(res, {
      message: 'Registration successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        isPremium: user.is_premium
      }
    }, 201);

  } catch (error) {
    console.error('Registration error:', error);
    return sendError(res, 'SERVER_ERROR', 'Registration failed', 500);
  }
});

/**
 * POST /api/auth/login
 * Login existing user
 */
router.post('/auth/login', [
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  body('password').notEmpty().withMessage('Password is required'),
], async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 'VALIDATION_ERROR', errors.array()[0].msg, 400);
    }

    const { email, password } = req.body;

    // Find user by email
    const userQuery = await db.query(
      'SELECT id, email, username, password_hash, is_premium FROM users WHERE email = $1',
      [email]
    );

    if (userQuery.rows.length === 0) {
      return sendError(res, 'INVALID_CREDENTIALS', 'Invalid email or password', 401);
    }

    const user = userQuery.rows[0];

    // Verify password
    const passwordMatch = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatch) {
      return sendError(res, 'INVALID_CREDENTIALS', 'Invalid email or password', 401);
    }

    // Generate JWT token
    const token = generateToken(user);

    return sendSuccess(res, {
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        isPremium: user.is_premium
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    return sendError(res, 'SERVER_ERROR', 'Login failed', 500);
  }
});

/**
 * POST /api/auth/verify
 * Verify JWT token and get user info
 */
router.post('/auth/verify', async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return sendError(res, 'NO_TOKEN', 'No token provided', 401);
    }

    const jwt = require('jsonwebtoken');
    const secret = process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';

    try {
      const decoded = jwt.verify(token, secret);
      
      // Get fresh user data from database
      const userQuery = await db.query(
        'SELECT id, email, username, is_premium FROM users WHERE id = $1',
        [decoded.userId]
      );

      if (userQuery.rows.length === 0) {
        return sendError(res, 'USER_NOT_FOUND', 'User not found', 404);
      }

      const user = userQuery.rows[0];

      return sendSuccess(res, {
        valid: true,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          isPremium: user.is_premium
        }
      });

    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        return sendError(res, 'TOKEN_EXPIRED', 'Token has expired', 401);
      } else if (error.name === 'JsonWebTokenError') {
        return sendError(res, 'INVALID_TOKEN', 'Invalid token', 401);
      }
      throw error;
    }

  } catch (error) {
    console.error('Token verification error:', error);
    return sendError(res, 'SERVER_ERROR', 'Verification failed', 500);
  }
});

/**
 * DELETE /api/auth/delete-account
 * Delete user account and all associated data
 * Requires authentication
 */
router.delete('/auth/delete-account', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    // Start transaction to ensure all deletions succeed or fail together
    await db.query('BEGIN');

    try {
      // Delete user collections first (foreign key constraints)
      await db.query('DELETE FROM user_collections WHERE user_id = $1', [userId]);

      // Delete user's photocards (this will also cascade to user_collections if any remain)
      await db.query('DELETE FROM photocards WHERE user_id = $1', [userId]);

      // Delete the user account
      const deleteResult = await db.query('DELETE FROM users WHERE id = $1 RETURNING email', [userId]);

      if (deleteResult.rows.length === 0) {
        await db.query('ROLLBACK');
        return sendError(res, 'USER_NOT_FOUND', 'User not found', 404);
      }

      // Commit the transaction
      await db.query('COMMIT');

      return sendSuccess(res, {
        message: 'Account deleted successfully'
      });

    } catch (error) {
      // Rollback transaction on error
      await db.query('ROLLBACK');
      throw error;
    }

  } catch (error) {
    console.error('Delete account error:', error);
    return sendError(res, 'SERVER_ERROR', 'Failed to delete account', 500);
  }
});

module.exports = router;

