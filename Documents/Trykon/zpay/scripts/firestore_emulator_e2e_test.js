// scripts/firestore_emulator_e2e_test.js
// Runs basic end-to-end checks against the running Firestore & Auth emulators.
// This script assumes it's executed inside `firebase emulators:exec` which
// sets emulator env vars for Firestore and Auth.

const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const fs = require('fs');

(async () => {
  try {
    const rules = fs.readFileSync('firestore.rules', 'utf8');
    const testEnv = await initializeTestEnvironment({ projectId: 'zpay-emulator-e2e', firestore: { rules } });

    const adminCtx = testEnv.authenticatedContext('adminUid', { email: 'admin@example.com', token: { admin: true } });
    const adminDb = adminCtx.firestore();
    const userCtx = testEnv.authenticatedContext('userUid', { email: 'user@example.com' });
    const userDb = userCtx.firestore();

    console.log('Running e2e checks (emulator) — admin should succeed, user should fail writes...');

    // Admin write should succeed
    await assertSucceeds(adminDb.collection('admin_docs').doc('e2e_doc').set({ title: 'E2E', content: 'Hello', createdAt: new Date().toISOString(), createdBy: 'adminUid' }));
    console.log('Admin write: OK');

    // Non-admin write should fail
    await assertFails(userDb.collection('admin_docs').doc('e2e_doc_user').set({ title: 'E2E', content: 'Nope' }));
    console.log('Non-admin write blocked: OK');

    // Read should be allowed to authenticated user
    await assertSucceeds(userDb.collection('admin_docs').doc('e2e_doc').get());
    console.log('Read by user: OK');

    await testEnv.cleanup();
    console.log('Emulator E2E tests passed ✅');
    process.exit(0);
  } catch (err) {
    console.error('Emulator E2E tests failed ❌', err);
    process.exit(1);
  }
})();