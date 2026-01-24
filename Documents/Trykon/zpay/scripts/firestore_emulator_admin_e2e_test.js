// scripts/firestore_emulator_admin_e2e_test.js
// E2E emulator test that uses the Admin SDK to set claims and the client SDK
// to sign in with a custom token, then asserts behavior against Firestore.

const admin = require('firebase-admin');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const fs = require('fs');

(async () => {
  try {
    const rules = fs.readFileSync('firestore.rules', 'utf8');

    // Initialize test environment (uses emulator env if run by firebase emulators:exec)
    const testEnv = await initializeTestEnvironment({ projectId: 'zpay-emulator-admin-e2e', firestore: { rules } });

    // Create a user and set admin claim using Admin SDK (emulator aware)
    // Configure admin to use emulator
    process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
    process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';

    admin.initializeApp({ projectId: 'zpay-emulator-admin-e2e' });

    // Create user via admin SDK
    const userRecord = await admin.auth().createUser({ email: 'e2e-admin@example.com', password: 'password123' });

    // Set admin custom claim
    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });

    // Create a custom token for client sign-in
    const customToken = await admin.auth().createCustomToken(userRecord.uid);

    // Use testEnv to create a client-authenticated context via custom token
    const client = testEnv.authenticatedContext(userRecord.uid, { email: userRecord.email, token: { admin: true } });
    const clientDb = client.firestore();

    // Admin should be able to write
    await assertSucceeds(clientDb.collection('admin_docs').doc('admin_doc_e2e').set({ title: 'E2E Admin Doc', content: 'Created by admin', createdBy: userRecord.uid }));

    // Regular (non-admin) user attempt
    const normalCtx = testEnv.authenticatedContext('normalUid', { email: 'user@example.com' });
    const normalDb = normalCtx.firestore();
    await assertFails(normalDb.collection('admin_docs').doc('user_doc_e2e').set({ title: 'User Doc', content: 'Should be blocked' }));

    console.log('Emulator admin E2E test passed ✅');
    await testEnv.cleanup();
    process.exit(0);
  } catch (err) {
    console.error('Emulator admin E2E test failed ❌', err);
    process.exit(1);
  }
})();