const fs = require('fs');
const path = require('path');
const { pool } = require('../config/db');

async function initDatabase() {
  console.log('🚀 Starting QRent Database Initialization...');
  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const seedPath = path.join(__dirname, 'seed.sql');

    const schemaSql = fs.readFileSync(schemaPath, 'utf8');
    const seedSql = fs.readFileSync(seedPath, 'utf8');

    console.log('⏳ Running schema.sql...');
    await pool.query(schemaSql);
    console.log('✅ Tables created successfully!');

    console.log('⏳ Running seed.sql...');
    await pool.query(seedSql);
    console.log('✅ Seed data inserted successfully!');

    console.log('🎉 Database initialization complete!');
  } catch (err) {
    console.error('❌ Failed to initialize database:', err.message);
  } finally {
    await pool.end();
  }
}

initDatabase();
