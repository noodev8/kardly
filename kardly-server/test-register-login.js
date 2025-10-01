/**
 * Test script for registration and login endpoints
 */

const http = require('http');

// Helper function to make HTTP requests
function makeRequest(method, path, data) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          resolve({
            statusCode: res.statusCode,
            data: JSON.parse(body)
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            data: body
          });
        }
      });
    });

    req.on('error', reject);
    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function testAuthentication() {
  console.log('='.repeat(60));
  console.log('Testing Authentication Endpoints');
  console.log('='.repeat(60));

  // Generate random test user
  const timestamp = Date.now();
  const testUser = {
    email: `testuser${timestamp}@example.com`,
    username: `testuser${timestamp}`,
    password: 'password123'
  };

  console.log('\nTest User:', {
    email: testUser.email,
    username: testUser.username,
    password: '********'
  });

  // Test 1: Register new user
  console.log('\n1. Testing Registration...');
  try {
    const registerResponse = await makeRequest('POST', '/api/auth/register', testUser);
    
    if (registerResponse.statusCode === 201) {
      console.log('✓ Registration successful');
      console.log('  User ID:', registerResponse.data.user.id);
      console.log('  Username:', registerResponse.data.user.username);
      console.log('  Token:', registerResponse.data.token.substring(0, 50) + '...');
      
      // Save token for later tests
      global.authToken = registerResponse.data.token;
      global.userId = registerResponse.data.user.id;
    } else {
      console.log('✗ Registration failed');
      console.log('  Status:', registerResponse.statusCode);
      console.log('  Error:', registerResponse.data);
      return;
    }
  } catch (error) {
    console.log('✗ Registration error:', error.message);
    return;
  }

  // Test 2: Try to register with same email (should fail)
  console.log('\n2. Testing Duplicate Email...');
  try {
    const duplicateResponse = await makeRequest('POST', '/api/auth/register', testUser);
    
    if (duplicateResponse.statusCode === 400 && duplicateResponse.data.return_code === 'EMAIL_EXISTS') {
      console.log('✓ Duplicate email correctly rejected');
    } else {
      console.log('✗ Duplicate email should have been rejected');
    }
  } catch (error) {
    console.log('✗ Error:', error.message);
  }

  // Test 3: Login with correct credentials
  console.log('\n3. Testing Login with Correct Credentials...');
  try {
    const loginResponse = await makeRequest('POST', '/api/auth/login', {
      email: testUser.email,
      password: testUser.password
    });
    
    if (loginResponse.statusCode === 200) {
      console.log('✓ Login successful');
      console.log('  User ID:', loginResponse.data.user.id);
      console.log('  Token:', loginResponse.data.token.substring(0, 50) + '...');
    } else {
      console.log('✗ Login failed');
      console.log('  Status:', loginResponse.statusCode);
      console.log('  Error:', loginResponse.data);
    }
  } catch (error) {
    console.log('✗ Login error:', error.message);
  }

  // Test 4: Login with wrong password
  console.log('\n4. Testing Login with Wrong Password...');
  try {
    const wrongPasswordResponse = await makeRequest('POST', '/api/auth/login', {
      email: testUser.email,
      password: 'wrongpassword'
    });
    
    if (wrongPasswordResponse.statusCode === 401 && wrongPasswordResponse.data.return_code === 'INVALID_CREDENTIALS') {
      console.log('✓ Wrong password correctly rejected');
    } else {
      console.log('✗ Wrong password should have been rejected');
    }
  } catch (error) {
    console.log('✗ Error:', error.message);
  }

  // Test 5: Verify token
  console.log('\n5. Testing Token Verification...');
  try {
    const verifyOptions = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/auth/verify',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${global.authToken}`
      }
    };

    const verifyResponse = await new Promise((resolve, reject) => {
      const req = http.request(verifyOptions, (res) => {
        let body = '';
        res.on('data', (chunk) => body += chunk);
        res.on('end', () => {
          resolve({
            statusCode: res.statusCode,
            data: JSON.parse(body)
          });
        });
      });
      req.on('error', reject);
      req.end();
    });
    
    if (verifyResponse.statusCode === 200 && verifyResponse.data.valid) {
      console.log('✓ Token verification successful');
      console.log('  User ID:', verifyResponse.data.user.id);
      console.log('  Username:', verifyResponse.data.user.username);
    } else {
      console.log('✗ Token verification failed');
    }
  } catch (error) {
    console.log('✗ Verification error:', error.message);
  }

  console.log('\n' + '='.repeat(60));
  console.log('All tests completed!');
  console.log('='.repeat(60));
}

// Run tests
testAuthentication().catch(console.error);

