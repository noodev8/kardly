/**
 * Validation middleware for photocard requests
 * Uses express-validator for field validation
 */

const { body, validationResult } = require('express-validator');
const { sendValidationError } = require('../utils/response');

/**
 * Validation rules for add_photocard endpoint
 */
const validateAddPhotocard = [
  // Validate group_id (optional, but must be valid UUID if provided)
  body('group_id')
    .optional()
    .isUUID()
    .withMessage('group_id must be a valid UUID'),

  // Validate member_id (optional, but must be valid UUID if provided)
  body('member_id')
    .optional()
    .isUUID()
    .withMessage('member_id must be a valid UUID'),

  // Validate album_id (optional, but must be valid UUID if provided)
  body('album_id')
    .optional()
    .isUUID()
    .withMessage('album_id must be a valid UUID')
];

/**
 * Middleware to check validation results
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Next middleware function
 */
const checkValidationResult = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(err => ({
      field: err.path,
      message: err.msg
    }));
    
    return sendValidationError(
      res,
      'Validation failed',
      errorMessages
    );
  }
  
  next();
};

/**
 * Validate that image file is present in request
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Next middleware function
 */
const validateImagePresent = (req, res, next) => {
  if (!req.file) {
    return sendValidationError(
      res,
      'Image file is required'
    );
  }
  
  next();
};

module.exports = {
  validateAddPhotocard,
  checkValidationResult,
  validateImagePresent
};

