const { Client } = require('pg');

async function main() {
  const client = new Client({
    host: 'localhost',
    port: 5432,
    database: 'antigaspi',
    user: 'antigaspi',
    password: 'antigaspi_dev_2024',
  });

  try {
    await client.connect();
    console.log('Connected to database.');

    const phoneNumber = '+213550000000';
    const displayName = 'Boulangerie de Test (Antigravity)';
    const role = 'merchant';

    // Check if user exists
    const res = await client.query('SELECT * FROM users WHERE phone_number = $1', [phoneNumber]);
    if (res.rows.length > 0) {
      // Update role
      await client.query(
        'UPDATE users SET role = $1, display_name = $2, is_verified = true WHERE phone_number = $3',
        [role, displayName, phoneNumber]
      );
      console.log(`User ${phoneNumber} updated to merchant.`);
    } else {
      // Insert user
      await client.query(
        'INSERT INTO users (id, phone_number, role, display_name, is_verified, created_at, updated_at) VALUES (gen_random_uuid(), $1, $2, $3, true, now(), now())',
        [phoneNumber, role, displayName]
      );
      console.log(`User ${phoneNumber} created as merchant.`);
    }
  } catch (err) {
    console.error('Error executing query:', err);
  } finally {
    await client.end();
  }
}

main();
