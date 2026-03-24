# Osusu Go-Live Checklist

## 1. Pre-launch validation
- [ ] All unit and integration tests pass:
  - `npm test -- --runInBand --detectOpenHandles`
- [ ] Lint: `npm run lint`
- [ ] Security scan: `npm audit`, OWASP ZAP or Snyk
- [ ] API contract review (README API list)

## 2. Production config / secrets
- [ ] Set `JWT_SECRET` in secure store
- [ ] Set database URL/keys in env:
  - `SUPABASE_URL`
  - `SUPABASE_KEY`
- [ ] Set Stripe keys:
  - `STRIPE_SECRET_KEY`
  - `STRIPE_WEBHOOK_SECRET`
- [ ] Add email provider secret (e.g., SendGrid key)

## 3. Deployment (Vercel + Supabase)
- [ ] `vercel --prod`
- [ ] `supabase db push` (or proper db migrations)
- [ ] `supabase functions deploy` (if used)

## 4. Post-deploy validation
- [ ] `curl https://<prod-url>/health`
- [ ] `POST /auth/signup` test (with unique email)
- [ ] `POST /group` with token
- [ ] `POST /group/:groupName/collect`
- [ ] `POST /group/:groupName/payout`
- [ ] `GET /group/:groupName/status`
- [ ] Check admin and super admin flows by role

## 5. Monitoring + alerts
- [ ] Sentry DSN configured
- [ ] Error rate alert > 2%
- [ ] API latency alert p95 > 500ms
- [ ] Schedule daily backup

## 6. Docs update
- [ ] README updated with release notes
- [ ] User/Admin manual sections complete
- [ ] `GO_LIVE_CHECKLIST.md` in repo

## 7. Release
- [ ] Tag release: `git tag v1.0.0`
- [ ] Push tags: `git push --tags`
- [ ] Publish release notes

## 8. Post-launch
- [ ] 24-hour monitoring window active
- [ ] Incident response channel ready
- [ ] Customer support wake schedule
