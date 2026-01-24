// scripts/firestore_rules_integration_test.js
// Uses @firebase/rules-unit-testing to test Firestore rules locally

const fs = require('fs');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');

(async () => {
  const projectId = 'zpay-emulator-test';
  const rules = fs.readFileSync('firestore.rules', 'utf8');

  const testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules },
  });

  try {
    // Authenticated normal user (no admin claim)
    const userCtx = testEnv.authenticatedContext('userUid', { email: 'user@example.com' });
    const userDb = userCtx.firestore();

    // Authenticated admin user (simulate admin claim)
    const adminCtx = testEnv.authenticatedContext('adminUid', { email: 'admin@example.com', token: { admin: true } });
    const adminDb = adminCtx.firestore();

    // Admin should be able to create admin_docs
    await assertSucceeds(adminDb.collection('admin_docs').doc('doc1').set({ title: 'Admin Doc', content: 'Secret', createdAt: new Date().toISOString(), createdBy: 'adminUid' }));

    // Non-admin should NOT be able to create admin_docs
    await assertFails(userDb.collection('admin_docs').doc('doc2').set({ title: 'User Doc', content: 'Nope' }));

    // Authenticated users should be able to read admin_docs
    await assertSucceeds(userDb.collection('admin_docs').doc('doc1').get());

    console.log('Firestore rules integration tests passed ✅');
    await testEnv.cleanup();
    process.exit(0);
  } catch (err) {
    console.error('Firestore rules integration tests failed ❌', err);
    await testEnv.cleanup();
    process.exit(1);
  }
})();