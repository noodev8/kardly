/**
 * Test script to verify database and Cloudinary connections
 * Run this before starting the server to ensure everything is configured correctly
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const { pool } = require('./config/database');
const { testConnection } = require('./config/cloudinary');

const testDatabaseConnection = async () => {
  console.log('\n🔍 Testing Database Connection...');
  console.log('─'.repeat(60));
  
  try {
    // Test basic connection
    const result = await pool.query('SELECT NOW() as current_time, version() as pg_version');
    console.log('✓ Database connection successful!');
    console.log(`  Current time: ${result.rows[0].current_time}`);
    console.log(`  PostgreSQL version: ${result.rows[0].pg_version.split(',')[0]}`);
    
    // Test if required tables exist
    const tablesQuery = `
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('photocards', 'kpop_groups', 'group_members', 'albums')
      ORDER BY table_name;
    `;
    
    const tablesResult = await pool.query(tablesQuery);
    const foundTables = tablesResult.rows.map(row => row.table_name);
    
    console.log('\n📊 Database Tables:');
    const requiredTables = ['albums', 'group_members', 'kpop_groups', 'photocards'];
    requiredTables.forEach(table => {
      if (foundTables.includes(table)) {
        console.log(`  ✓ ${table}`);
      } else {
        console.log(`  ✗ ${table} (MISSING!)`);
      }
    });
    
    if (foundTables.length === requiredTables.length) {
      console.log('\n✓ All required tables exist!');
    } else {
      console.log('\n⚠ Warning: Some tables are missing. Run the schema SQL file.');
    }
    
    // Count existing records
    console.log('\n📈 Record Counts:');
    for (const table of foundTables) {
      const countResult = await pool.query(`SELECT COUNT(*) as count FROM ${table}`);
      console.log(`  ${table}: ${countResult.rows[0].count} records`);
    }
    
    return true;
  } catch (error) {
    console.error('✗ Database connection failed!');
    console.error(`  Error: ${error.message}`);
    console.error('\n💡 Troubleshooting:');
    console.error('  1. Check if PostgreSQL is running');
    console.error('  2. Verify credentials in .env file');
    console.error('  3. Ensure database exists');
    console.error('  4. Check firewall/network settings');
    return false;
  }
};

const testCloudinaryConnection = async () => {
  console.log('\n🔍 Testing Cloudinary Connection...');
  console.log('─'.repeat(60));
  
  try {
    const isConnected = await testConnection();
    
    if (isConnected) {
      console.log('✓ Cloudinary connection successful!');
      console.log(`  Cloud Name: ${process.env.CLOUDINARY_CLOUD_NAME}`);
      console.log(`  API Key: ${process.env.CLOUDINARY_API_KEY?.substring(0, 8)}...`);
      return true;
    } else {
      console.error('✗ Cloudinary connection failed!');
      console.error('\n💡 Troubleshooting:');
      console.error('  1. Verify credentials in .env file');
      console.error('  2. Check Cloudinary dashboard for API status');
      console.error('  3. Ensure internet connectivity');
      console.error('  4. Try regenerating API credentials');
      return false;
    }
  } catch (error) {
    console.error('✗ Cloudinary connection failed!');
    console.error(`  Error: ${error.message}`);
    return false;
  }
};

const checkEnvironmentVariables = () => {
  console.log('\n🔍 Checking Environment Variables...');
  console.log('─'.repeat(60));
  
  const requiredVars = [
    'DB_HOST',
    'DB_PORT',
    'DB_NAME',
    'DB_USER',
    'DB_PASSWORD',
    'CLOUDINARY_CLOUD_NAME',
    'CLOUDINARY_API_KEY',
    'CLOUDINARY_API_SECRET'
  ];
  
  let allPresent = true;
  
  requiredVars.forEach(varName => {
    if (process.env[varName]) {
      console.log(`  ✓ ${varName}`);
    } else {
      console.log(`  ✗ ${varName} (MISSING!)`);
      allPresent = false;
    }
  });
  
  if (allPresent) {
    console.log('\n✓ All required environment variables are set!');
  } else {
    console.log('\n⚠ Warning: Some environment variables are missing.');
    console.log('  Please check your .env file in the project root.');
  }
  
  return allPresent;
};

const runTests = async () => {
  console.log('\n' + '='.repeat(60));
  console.log('  KARDLY SERVER - CONNECTION TEST');
  console.log('='.repeat(60));
  
  // Check environment variables
  const envOk = checkEnvironmentVariables();
  
  if (!envOk) {
    console.log('\n❌ Environment variables check failed!');
    console.log('Please configure your .env file before proceeding.\n');
    process.exit(1);
  }
  
  // Test database connection
  const dbOk = await testDatabaseConnection();
  
  // Test Cloudinary connection
  const cloudinaryOk = await testCloudinaryConnection();
  
  // Summary
  console.log('\n' + '='.repeat(60));
  console.log('  TEST SUMMARY');
  console.log('='.repeat(60));
  console.log(`  Environment Variables: ${envOk ? '✓ PASS' : '✗ FAIL'}`);
  console.log(`  Database Connection:   ${dbOk ? '✓ PASS' : '✗ FAIL'}`);
  console.log(`  Cloudinary Connection: ${cloudinaryOk ? '✓ PASS' : '✗ FAIL'}`);
  console.log('='.repeat(60));
  
  if (dbOk && cloudinaryOk) {
    console.log('\n✅ All tests passed! You can start the server with: npm start\n');
    process.exit(0);
  } else {
    console.log('\n❌ Some tests failed. Please fix the issues above before starting the server.\n');
    process.exit(1);
  }
};

// Run tests
runTests().catch(error => {
  console.error('\n❌ Unexpected error during tests:', error);
  process.exit(1);
});

