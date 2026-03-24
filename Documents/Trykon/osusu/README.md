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
- `POST /group` { name }
- `POST /group/:groupName/member` { memberName }
- `POST /group/:groupName/member/:memberName/deposit` { amount }
- `GET /group/:groupName`

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
