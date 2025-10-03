/**
 * Simple migration runner script
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const fs = require('fs').promises;
const path = require('path');
const { pool } = require('./config/database');

const runMigration = async (migrationFile) => {
  console.log(`\n🔄 Running migration: ${migrationFile}`);
  console.log('─'.repeat(60));
  
  try {
    // Read migration file
    const migrationPath = path.join(__dirname, 'migrations', migrationFile);
    const migrationSQL = await fs.readFile(migrationPath, 'utf8');
    
    // Execute migration
    await pool.query(migrationSQL);
    
    console.log('✓ Migration completed successfully!');
    
  } catch (error) {
    console.error('✗ Migration failed:', error.message);
    throw error;
  }
};

const main = async () => {
  try {
    // Run the favorites migration
    await runMigration('002_add_favorites_to_user_collections.sql');
    
    // Test the new column exists
    const testQuery = `
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns 
      WHERE table_name = 'user_collections' 
      AND column_name = 'is_favorite';
    `;
    
    const result = await pool.query(testQuery);
    
    if (result.rows.length > 0) {
      console.log('\n✓ Verified: is_favorite column added successfully');
      console.log('  Column details:', result.rows[0]);
    } else {
      console.log('\n✗ Warning: is_favorite column not found');
    }
    
    console.log('\n🎉 Migration process completed!');
    
  } catch (error) {
    console.error('\n💥 Migration process failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
};

main();
