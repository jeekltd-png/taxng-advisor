// scripts/set_admin_claim.js
// Node.js script to set an 'admin' custom claim for a user (by email or uid)
// Usage: node set_admin_claim.js <email|uid> [true|false]

const admin = require('firebase-admin');
const fs = require('fs');

if (process.argv.length < 3) {
  console.error('Usage: node set_admin_claim.js <email|uid> [true|false]');
  process.exit(1);
}

const identifier = process.argv[2];
const flag = process.argv[3] !== 'false'; // default true

// Load service account JSON from local file (download from Firebase Console)
if (!fs.existsSync('./serviceAccountKey.json')) {
  console.error('Missing serviceAccountKey.json. Download from Firebase Console and place in project root.');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

async function run() {
  try {
    // Try to get user by email, fallback to uid lookup
    let userRecord;
    if (identifier.includes('@')) {
      userRecord = await admin.auth().getUserByEmail(identifier);
    } else {
      userRecord = await admin.auth().getUser(identifier);
    }

    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: flag });

    console.log(`Successfully set admin=${flag} for user ${userRecord.uid} (${userRecord.email})`);
  } catch (e) {
    console.error('Error:', e);
  }
}

run();
