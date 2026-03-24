# osusu

This is the osusu workspace.

- Folder was previously empty; now seeded with starter content.
- Add your project files here.

## Setup

```bash
npm install
```

## Run

```bash
npm start
```

## Dev

```bash
npm run dev
```

## Lint

```bash
npm run lint
```

## Tests

```bash
npm test
```

## API

- `GET /health`
- `POST /auth/signup` { email, password }
- `POST /auth/signin` { email, password }
- `POST /auth/forgot` { email }
- `POST /auth/logout`
- `GET /auth/oauth/:provider` (google/twitter/facebook)
- `POST /auth/refresh` { refreshToken }
- `POST /group` { name, currency, locale, country, contributionAmount, cycleType }
- `POST /group/:groupName/member` { memberName }
- `POST /group/:groupName/member/:memberName/deposit` { amount }
- `POST /group/:groupName/collect`
- `POST /group/:groupName/payout` { recipient }
- `GET /group/:groupName/status`
- `GET /group/:groupName`

### Contribution and payout flow

1. Create group with collection params.
2. Add members.
3. Staff collects contributions for a cycle with `POST /group/:groupName/collect`.
   - Computes gross pot, fee, net payout.
4. Payout recipient with `POST /group/:groupName/payout`.
   - Updates cycle status and recipient balance.
5. Check status with `GET /group/:groupName/status`.

### Dashboard roles

- User: view groups, contributions, payouts.
- Admin/treasurer: run collect/payout, manage members, view financials.
- Super Admin: global metrics, audit logs, moderation.

## Web UI (responsive)

- Single-page controls in `src/public/index.html`
- `GET /` serves UI from express static
- Mobile-friendly design with 1-column on small screens

## Web UI (responsive)

- Single-page controls in `src/public/index.html`
- `GET /` serves UI from express static
- Mobile-friendly design with 1-column on small screens

## Mobile scaffold

- `mobile/` folder (Flutter app stub + instructions)
- share core domain module `src/osusu.js` in multiplatform codebase

## Production readiness

- environment variables in `.env` (with `dotenv`)
- request logging via `morgan`
- global error handler and health-check endpoint
- CI workflow for Node.js
- linting, test coverage, dev server support

## Feature

- `src/osusu.js`: savings group domain module with `Member` and `OsusuGroup` classes.
- `src/server.js`: Express REST API and health check.
- `__tests__/osusu.test.js`: Jest unit tests.
- `__tests__/server.test.js`: API integration tests.
