/**
 * Test script for authentication middleware
 * Tests JWT token generation and validation
 */

const { generateToken } = require('./middleware/auth');

// Test user object
const testUser = {
  id: '123e4567-e89b-12d3-a456-426614174000',
  email: 'test@example.com',
  username: 'testuser',
  is_premium: false
};

console.log('='.repeat(60));
console.log('Testing JWT Authentication');
console.log('='.repeat(60));

// Generate token
console.log('\n1. Generating JWT token for test user...');
const token = generateToken(testUser);
console.log('✓ Token generated successfully');
console.log('Token:', token.substring(0, 50) + '...');

// Verify token structure
console.log('\n2. Verifying token structure...');
const parts = token.split('.');
if (parts.length === 3) {
  console.log('✓ Token has correct structure (3 parts)');
} else {
  console.log('✗ Token has incorrect structure');
}

// Decode payload (without verification)
console.log('\n3. Decoding token payload...');
try {
  const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
  console.log('✓ Payload decoded successfully');
  console.log('Payload:', JSON.stringify(payload, null, 2));
  
  // Verify payload contents
  if (payload.userId === testUser.id) {
    console.log('✓ User ID matches');
  } else {
    console.log('✗ User ID does not match');
  }
  
  if (payload.email === testUser.email) {
    console.log('✓ Email matches');
  } else {
    console.log('✗ Email does not match');
  }
  
  if (payload.username === testUser.username) {
    console.log('✓ Username matches');
  } else {
    console.log('✗ Username does not match');
  }
} catch (error) {
  console.log('✗ Failed to decode payload:', error.message);
}

console.log('\n' + '='.repeat(60));
console.log('Test completed!');
console.log('='.repeat(60));
console.log('\nTo test with the server:');
console.log('1. Start the server: npm start');
console.log('2. Use this token in Authorization header:');
console.log(`   Authorization: Bearer ${token}`);
console.log('='.repeat(60));

