# CI Setup — Deploying Firestore Rules & Setting Admin Claims

This document explains how to configure the repository's GitHub Actions for:

- Deploying `firestore.rules` automatically on pushes to `main`, and
- Manually setting `admin` custom claims via a secure GitHub workflow.

---

## Secrets required (GitHub repository -> Settings -> Secrets)

1. FIREBASE_TOKEN (string)
   - Obtain by running: `firebase login:ci` (local dev machine with Firebase CLI) and copy the token.
   - Add as repository secret `FIREBASE_TOKEN`.
   - Used by `deploy_firestore_rules.yml` to deploy Firestore rules.

2. SERVICE_ACCOUNT_JSON (base64-encoded)
   - Download `serviceAccountKey.json` from Firebase Console (Project Settings -> Service Accounts -> Generate Private Key).
   - Encode it: `base64 serviceAccountKey.json | pbcopy` (macOS) or `base64 serviceAccountKey.json | clip` (Windows) and copy the output.
   - Add as repository secret `SERVICE_ACCOUNT_JSON` (the base64 string).
   - Used by `set_admin_claim.yml` to run `scripts/set_admin_claim.js`.

3. (Optional) Add repo secret `CI_RUN_RULES_TESTS` = `true` to gate unit tests if you want to toggle them in CI.

---

## Workflows

- `.github/workflows/deploy_firestore_rules.yml`
  - Triggers on push to `main` and `workflow_dispatch`.
  - Deploys `firestore.rules` with `firebase deploy --only firestore:rules --token "$FIREBASE_TOKEN"`.

- `.github/workflows/set_admin_claim.yml`
  - Triggered via `Actions -> Set Admin Claim` (workflow_dispatch).
  - Inputs: `identifier` (email or uid) and `flag` (true|false).
  - Uses `SERVICE_ACCOUNT_JSON` secret to create `serviceAccountKey.json` and runs the script.

- `.github/workflows/firestore_rules_unit_tests.yml` (new)
  - Runs unit/integration tests against the Firestore rules using `@firebase/rules-unit-testing`.
  - Triggers on push to `main` and `workflow_dispatch`.
  - Executes `scripts/firestore_rules_integration_test.js` which simulates admin vs non-admin users and validates rule behavior locally (no external network needed).

---

## Protected branch recommendation (safe deploys) 🔒

To prevent accidental rule deployment and require verification before pushing `firestore.rules` to production, protect the `main` branch in GitHub:

1. Go to your repository → Settings → Branches → Add Rule, or run the helper script/workflow to apply branch protection (see below).
2. Use `main` as the branch pattern.
3. Enable:
   - "Require pull request reviews before merging" (set at least 1 approver).
   - "Require status checks to pass before merging" and select the status checks for:
     - `Firestore Rules Unit Tests` (job: `rules-unit-tests` in `.github/workflows/firestore_rules_unit_tests.yml`)
     - `Emulator E2E Tests` (job: `emulator-e2e` in `.github/workflows/firestore_emulator_e2e.yml`)
     - `Emulator Admin E2E` (job: `emulator-admin-e2e` in `.github/workflows/firestore_emulator_admin_e2e.yml`)
   - (Optional) "Include administrators" to enforce policy on admins as well.

Option A — Apply via workflow dispatch
- Use the `Apply Branch Protection` workflow in the Actions tab. It accepts inputs for branch, status checks (comma-separated), and required review count.

Option B — Apply locally with GitHub token
- Export `GITHUB_REPOSITORY` if not set, and run:
  - `GITHUB_TOKEN=<your_token> BRANCH=main STATUS_CHECKS="rules-unit-tests,emulator-e2e,emulator-admin-e2e" REVIEW_COUNT=1 node scripts/apply_branch_protection.js`

This ensures PRs must pass the rules unit tests and emulator E2E tests and receive review before rules are deployed.

---

## Running rules tests locally (quick)

1. Install dependencies locally (Node.js):
   - `npm init -y`
   - `npm i --save-dev @firebase/rules-unit-testing`
2. Run the test script:
   - `node scripts/firestore_rules_integration_test.js`

The script will simulate an admin and a non-admin and assert rule behavior (create/write/read) using the rules file in the repo.

---

## Notes & Security

- Never commit service account keys to source control.
- Use GitHub repository secrets for storing credentials securely.
- After setting claims, users may need to sign out and sign in again for client tokens to refresh and reflect the new claims.

---

If you want, I can also:
- Add a protected branch rule so `firestore.rules` only deploys from `main` after PR approval.
- Add a badge or workflow status summary to the README.
