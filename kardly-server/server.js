/**
 * Kardly Server - Main Entry Point
 * Backend server for K-Pop photocard collection and trading app
 */

// Load environment variables first
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { pool } = require('./config/database');
const { testConnection } = require('./config/cloudinary');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    return_code: 'SUCCESS',
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// API Routes
const addPhotocardRoute = require('./routes/add_photocard');
const photocardsRoute = require('./routes/photocards');
const groupsRoute = require('./routes/groups');
const membersRoute = require('./routes/members');
const albumsRoute = require('./routes/albums');

app.use('/api', addPhotocardRoute);
app.use('/api', photocardsRoute);
app.use('/api', groupsRoute);
app.use('/api', membersRoute);
app.use('/api', albumsRoute);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    return_code: 'NOT_FOUND',
    message: 'Endpoint not found'
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    return_code: 'SERVER_ERROR',
    message: 'An unexpected error occurred'
  });
});

// Start server
const startServer = async () => {
  try {
    // Test database connection
    console.log('Testing database connection...');
    await pool.query('SELECT NOW()');
    console.log('✓ Database connection successful');

    // Test Cloudinary connection
    console.log('Testing Cloudinary connection...');
    await testConnection();

    // Start listening
    app.listen(PORT, () => {
      console.log('='.repeat(60));
      console.log(`🚀 Kardly Server is running`);
      console.log(`📍 Port: ${PORT}`);
      console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`📅 Started at: ${new Date().toISOString()}`);
      console.log('='.repeat(60));
      console.log('\nAvailable endpoints:');
      console.log(`  GET  /health - Health check`);
      console.log(`  POST /api/add_photocard - Add new photocard`);
      console.log('='.repeat(60));
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM signal received: closing HTTP server');
  await pool.end();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT signal received: closing HTTP server');
  await pool.end();
  process.exit(0);
});

// Start the server
startServer();

