# Osusu Mobile Scaffold

This folder contains a basic mobile app onboarding plan for Osusu.

## Goals

1. Native mobile user experience (Flutter primary).
2. Shared backend and business logic with `src/osusu.js`.
3. Realtime notifications and offline sync.

## Setup (Flutter)

```bash
cd mobile
flutter create osusu_mobile
```

## Shared domain

- The backend module in `src/osusu.js` contains `Member` and `OsusuGroup`.
- In an advanced implementation, you can replicate these types in Dart/TS and run rules via server edge functions.

## API end points

- `GET http://localhost:3000/health`
- `POST http://localhost:3000/group`
- `POST http://localhost:3000/group/:groupName/member`
- `POST http://localhost:3000/group/:groupName/member/:memberName/deposit`
- `GET http://localhost:3000/group/:groupName`

## Notes

- For production, integrate with Supabase Auth + Stripe + persistent Postgres.
- Ensure Flutter app uses secure storage and offline queueing for contributions.
