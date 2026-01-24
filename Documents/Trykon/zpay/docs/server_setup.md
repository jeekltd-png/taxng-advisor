# Server: Setting Admin Claims & Security 🔒

Use the Firebase Admin SDK to set `admin` custom claims for privileged users. This is required for secure server-side control of admin-only features.

## 1) Create a service account key

- Go to Firebase Console > Project settings > Service accounts.
- Generate a private key and download `serviceAccountKey.json`.
- Place `serviceAccountKey.json` in the project root (or use environment-based credentials).

## 2) Set an admin claim using Node.js script

- Install deps: `npm init -y && npm i firebase-admin`
- Run script: `node scripts/set_admin_claim.js user@example.com true`

This sets custom claim `admin: true` for that user. Claims are effective on token refresh (user may need to sign out/in).

## 3) Firestore rules

- Ensure you deploy `firestore.rules` (sample provided in repo) so only users with `request.auth.token.admin == true` can create/update/delete `admin_docs`.

## 4) Production notes

- Do not set admin claims directly from client code.
- Use a secure admin panel on your server or Cloud Functions with Admin SDK to set claims.
- Audit admin assignments and log changes.
