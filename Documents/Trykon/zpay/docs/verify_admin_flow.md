# Verifying Admin Flow Locally & CI

This guide shows how to verify admin functionality end-to-end.

## 1) Set an admin via the script (local)

- Place `serviceAccountKey.json` (downloaded from Firebase Console) in project root.
- Run:
  - `npm init -y && npm i firebase-admin`
  - `node scripts/set_admin_claim.js admin@example.com true`
- Wait a moment, then sign out and sign in with that account in the app.

## 2) Verify UI behavior in app

- Sign in as admin: visit `/admin` — you should be able to add/delete documents.
- Sign in as non-admin: visit `/admin` — you should see “Access denied. Admins only.”

## 3) Verify Firestore Rules

- Deploy rules via CI (push to `main`) or locally using Firebase CLI:
  - `firebase deploy --only firestore:rules --token "$(firebase login:ci)"`
- Try to write to `admin_docs` from a user without the admin claim — operations should be blocked by rules.

## 4) Testing with Emulators

- Start emulators: `firebase emulators:start --only firestore,auth`
- Use the Admin SDK with a local service account to manipulate user claims against the emulator as needed.

---

If you'd like, I can add an automated integration test to check the admin workflow using the emulator. Let me know and I’ll scaffold a test in `test/` and a CI job to run it.