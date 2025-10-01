/**
 * Authentication middleware
 * Validates JWT tokens and extracts user information
 */

const jwt = require('jsonwebtoken');
const { sendError } = require('../utils/response');

/**
 * Middleware to verify JWT token and extract user information
 * Adds user object to req.user if token is valid
 * 
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Next middleware function
 */
const authenticateToken = (req, res, next) => {
  // Get token from Authorization header
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Format: "Bearer TOKEN"

  if (!token) {
    return sendError(res, 'NO_TOKEN', 'Authentication token is required', 401);
  }

  try {
    // Verify token
    const secret = process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';
    const decoded = jwt.verify(token, secret);
    
    // Add user info to request object
    req.user = {
      id: decoded.userId,
      email: decoded.email,
      username: decoded.username,
      isPremium: decoded.isPremium || false
    };
    
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return sendError(res, 'TOKEN_EXPIRED', 'Authentication token has expired', 401);
    } else if (error.name === 'JsonWebTokenError') {
      return sendError(res, 'INVALID_TOKEN', 'Invalid authentication token', 401);
    } else {
      return sendError(res, 'AUTH_ERROR', 'Authentication failed', 401);
    }
  }
};

/**
 * Optional authentication middleware
 * Extracts user info if token is present, but doesn't fail if missing
 * Useful for endpoints that work differently for authenticated vs anonymous users
 * 
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Next middleware function
 */
const optionalAuth = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    // No token provided, continue without user info
    req.user = null;
    return next();
  }

  try {
    const secret = process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';
    const decoded = jwt.verify(token, secret);
    
    req.user = {
      id: decoded.userId,
      email: decoded.email,
      username: decoded.username,
      isPremium: decoded.isPremium || false
    };
    
    next();
  } catch (error) {
    // Token is invalid, but we don't fail - just continue without user info
    req.user = null;
    next();
  }
};

/**
 * Generate JWT token for a user
 * 
 * @param {Object} user - User object with id, email, username, isPremium
 * @param {string} expiresIn - Token expiration time (default: '7d')
 * @returns {string} JWT token
 */
const generateToken = (user, expiresIn = '7d') => {
  const secret = process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';
  
  const payload = {
    userId: user.id,
    email: user.email,
    username: user.username,
    isPremium: user.is_premium || false
  };
  
  return jwt.sign(payload, secret, { expiresIn });
};

module.exports = {
  authenticateToken,
  optionalAuth,
  generateToken
};

