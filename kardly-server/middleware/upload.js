/**
 * Multer middleware for handling file uploads
 * Validates file type and size before processing
 */

const multer = require('multer');
const path = require('path');

// Configure multer to use memory storage
const storage = multer.memoryStorage();

/**
 * File filter to validate image types
 * @param {Object} req - Express request object
 * @param {Object} file - Multer file object
 * @param {Function} cb - Callback function
 */
const fileFilter = (req, file, cb) => {
  // Allowed image MIME types
  const allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp'
  ];

  // Check MIME type
  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only JPG, JPEG, PNG, and WEBP images are allowed.'), false);
  }
};

// Configure multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max file size
    files: 1 // Only allow 1 file per request
  }
});

/**
 * Middleware to handle multer errors
 * @param {Error} err - Error object
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Next middleware function
 */
const handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    // Multer-specific errors
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        return_code: 'FILE_TOO_LARGE',
        message: 'File size exceeds 5MB limit'
      });
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        return_code: 'TOO_MANY_FILES',
        message: 'Only one file can be uploaded at a time'
      });
    }
    if (err.code === 'LIMIT_UNEXPECTED_FILE') {
      return res.status(400).json({
        return_code: 'UNEXPECTED_FIELD',
        message: 'Unexpected file field'
      });
    }
    
    return res.status(400).json({
      return_code: 'UPLOAD_ERROR',
      message: err.message
    });
  } else if (err) {
    // Other errors (e.g., file filter errors)
    return res.status(400).json({
      return_code: 'INVALID_FILE_TYPE',
      message: err.message
    });
  }
  
  next();
};

module.exports = {
  upload,
  handleUploadError
};

