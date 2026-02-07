# TaxNG — Smart Tax Made Simple 🇳🇬

**Nigeria's comprehensive tax compliance app** built with Flutter for web, Android & iOS.

## Features

### 🧮 Tax Calculators
- **CIT** — Corporate Income Tax (small/medium/large company tiers)
- **PIT** — Personal Income Tax (progressive bands with rent relief)
- **VAT** — Value Added Tax (standard, zero-rated, exempt supplies)
- **WHT** — Withholding Tax (9 transaction types)
- **PAYE** — Payroll/Pay-As-You-Earn (pension, NHF contributions)
- **Stamp Duty** — 9 instrument types with type-specific rates

### 📊 Analytics & Reporting
- Tax Overview Dashboard with charts (pie, bar)
- Calculation History with search, filter & date range
- Export to CSV, Excel & PDF
- Tax Calendar with deadlines

### 🔐 Security
- Encrypted local storage via `flutter_secure_storage`
- SHA-256 password hashing
- Admin access control with role hierarchy
- Route-level admin guards

### 👤 Admin System
- User management & subscription approvals
- Activity logging with CSV export
- Admin analytics dashboard
- Email notification templates
- Support ticket management

### 💳 Payments & Subscriptions
- Subscription tiers: Free, Individual, Business, Enterprise
- Bank transfer payment flow
- Payment history & receipts

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome

# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release
```

## Project Structure
```
lib/
├── config/         # App configuration
├── features/       # Feature modules (auth, calculators, admin, etc.)
├── models/         # Data models
├── services/       # Business logic services
├── theme/          # App theming
├── utils/          # Utilities (formatting, validation, helpers)
└── widgets/        # Reusable widgets
```

## Tech Stack
- **Flutter** 3.2+ / Dart 3.2+
- **Hive** — Local NoSQL storage
- **fl_chart** — Data visualization
- **pdf** / **printing** — PDF generation
- **flutter_secure_storage** — Encrypted key-value storage
- **Provider** — State management

## License
Copyright © 2025-2026 Trykon. All rights reserved.
