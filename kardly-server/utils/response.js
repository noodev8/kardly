/**
 * Standardized response utility
 * All API responses must include a return_code field as per project rules
 */

/**
 * Send a success response
 * @param {Object} res - Express response object
 * @param {Object} data - Additional data to include in response
 * @param {number} statusCode - HTTP status code (default: 200)
 */
const sendSuccess = (res, data = {}, statusCode = 200) => {
  return res.status(statusCode).json({
    return_code: 'SUCCESS',
    ...data
  });
};

/**
 * Send an error response
 * @param {Object} res - Express response object
 * @param {string} returnCode - Error return code (e.g., 'VALIDATION_ERROR')
 * @param {string} message - Error message
 * @param {number} statusCode - HTTP status code (default: 400)
 * @param {Object} additionalData - Additional data to include in response
 */
const sendError = (res, returnCode, message, statusCode = 400, additionalData = {}) => {
  return res.status(statusCode).json({
    return_code: returnCode,
    message,
    ...additionalData
  });
};

/**
 * Send a validation error response
 * @param {Object} res - Express response object
 * @param {string} message - Error message
 * @param {Array} errors - Array of validation errors (optional)
 */
const sendValidationError = (res, message, errors = null) => {
  const response = {
    return_code: 'VALIDATION_ERROR',
    message
  };
  
  if (errors) {
    response.errors = errors;
  }
  
  return res.status(400).json(response);
};

/**
 * Send a server error response
 * @param {Object} res - Express response object
 * @param {string} message - Error message (default: 'Internal server error')
 */
const sendServerError = (res, message = 'Internal server error') => {
  return res.status(500).json({
    return_code: 'SERVER_ERROR',
    message
  });
};

module.exports = {
  sendSuccess,
  sendError,
  sendValidationError,
  sendServerError
};

