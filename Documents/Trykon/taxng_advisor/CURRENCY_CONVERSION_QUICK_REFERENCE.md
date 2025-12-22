# Currency Conversion - Quick Reference

## 🚀 Quick Start for Developers

### Add Currency Conversion to Any Calculator

**Step 1:** Import the widget
```dart
import 'package:taxng_advisor/widgets/currency_converter_widget.dart';
```

**Step 2:** Add after your tax result card
```dart
CurrencyConverterWidget(
  nairaAmount: result.taxPayable,
  label: 'Tax Payable',
  color: Colors.red,
  isBold: true,
)
```

**That's it!** The widget handles the rest.

---

## 📱 What Users Will See

### Expandable Widget (Default)
```
┌─────────────────────────────┐
│ CIT Payable: ₦3,000,000     │
│                             │
│ [Show Conversion] ▼         │
└─────────────────────────────┘
```

Click "Show Conversion":
```
┌─────────────────────────────┐
│ CIT Payable: ₦3,000,000     │
│                             │
│ [Hide Conversion] ▲         │
│                             │
│ Currency Conversion:        │
│ USD (from NGN): $1.95K      │
│ GBP Equivalent: £2.37M      │
│ USD (from GBP): $3.01K      │
│                             │
│ Exchange Rate: 1 NGN=$0.00065
└─────────────────────────────┘
```

### Permanent Card
```
┌─────────────────────────────────┐
│ Tax Amount Conversion           │
├─────────────────────────────────┤
│ Amount (NGN):        ₦500,000   │
├─────────────────────────────────┤
│ USD (from NGN):      $325       │
│ GBP Reference:       £395,000   │
│ USD (from GBP):      $501.65    │
├─────────────────────────────────┤
│ 📌 Rates: 1 NGN=$0.00065, 1 GBP=$1.27
└─────────────────────────────────┘
```

---

## 💻 Code Examples

### Using CurrencyConverterWidget (Expandable)
```dart
CurrencyConverterWidget(
  nairaAmount: 5000000,
  label: 'VAT Payable',
  color: Colors.red,
  isBold: true,
)
```

### Using CurrencyConversionCard (Always Visible)
```dart
CurrencyConversionCard(
  nairaAmount: 10000000,
  title: 'Annual Tax Liability',
)
```

### Direct Formatting (in text)
```dart
Text(CurrencyFormatter.formatNairaToUsd(3000000)) // Outputs: "$1.95K"
```

### Get All Currencies
```dart
final currencies = CurrencyFormatter.formatMultiCurrency(5000000);
print(currencies['NGN']);         // "₦5.00M"
print(currencies['USD_from_NGN']); // "$3.25K"
print(currencies['USD_from_GBP']); // "$6.36K"
```

---

## 🔢 Exchange Rate Reference

| From | To | Rate | Example |
|------|-----|------|---------|
| ₦1,000,000 | USD | 0.00065 | = $650 |
| £1,000 | USD | 1.27 | = $1,270 |
| ₦1 million | ≈ | £790,000 | GBP approx |

---

## ⚙️ Update Exchange Rates

**File:** `lib/utils/tax_helpers.dart`

**Find these lines:**
```dart
static const double nairaToUsdRate = 0.00065;  // 1 NGN
static const double poundToUsdRate = 1.27;     // 1 GBP
```

**Update values** and save. Changes apply immediately on hot reload.

---

## 📍 Where to Add Widgets

### CIT Calculator
```dart
// File: lib/features/cit/presentation/cit_calculator_screen.dart
// After: _ResultCard for "CIT Payable"
CurrencyConverterWidget(
  nairaAmount: result!.taxPayable,
  label: 'CIT Payable',
  color: Colors.red,
  isBold: true,
)
```

### VAT Calculator
```dart
// File: lib/features/vat/presentation/vat_calculator_screen.dart
// After: VAT Payable result card
CurrencyConverterWidget(
  nairaAmount: result.netPayable.abs(),
  label: result.netPayable >= 0 ? 'VAT Payable' : 'VAT Refundable',
  color: result.netPayable >= 0 ? Colors.red : Colors.green,
  isBold: true,
)
```

### PIT Calculator
```dart
// File: lib/features/pit/presentation/pit_calculator_screen.dart
// After: Total PIT result
CurrencyConverterWidget(
  nairaAmount: result.totalTax,
  label: 'Total PIT',
  color: Colors.red,
  isBold: true,
)
```

**Similar pattern for WHT, Payroll, and Stamp Duty calculators.**

---

## 🎯 Common Tasks

### Task: Show conversion for all taxes
**Solution:** Add `CurrencyConverterWidget` after each tax result card

### Task: Change exchange rate
**Solution:** Update constants in `CurrencyFormatter` (tax_helpers.dart)

### Task: Hide conversions from specific users
**Solution:** Wrap widget in conditional: `if (user.showCurrencyConversions) ...`

### Task: Export with currencies
**Solution:** Use `formatMultiCurrency()` to get all formats, include in report

### Task: Display only USD amount
**Solution:** Use `CurrencyFormatter.formatNairaToUsd(amount)` directly

---

## 📚 Documentation Links

| Document | Purpose | Audience |
|----------|---------|----------|
| `CSV_EXCEL_IMPORT_GUIDE.md` | User guide with examples | End Users |
| `CURRENCY_CONVERSION_GUIDE.md` | Complete dev reference | Developers |
| `CURRENCY_CONVERSION_IMPLEMENTATION.md` | Feature overview | Everyone |
| `CURRENCY_CONVERSION_SUMMARY.md` | Executive summary | Project Managers |

---

## ✅ Testing Checklist

- [ ] Expandable widget shows/hides properly
- [ ] Currency card displays all 4 currency values
- [ ] Exchange rates are correct
- [ ] Large amounts format with K/M notation
- [ ] Small amounts display full decimal
- [ ] Works with all 6 tax calculators
- [ ] No compilation errors
- [ ] Responsive design on mobile

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Widget not showing | Check import statement |
| Wrong USD amount | Verify exchange rate constant |
| Widget too wide | Check screen width, may need padding |
| Exchange rate not updating | Clear cache: `flutter clean` |
| Compilation error | Check that CurrencyFormatter methods exist |

---

## 🔗 Related Files

- **Utilities:** `lib/utils/tax_helpers.dart` - CurrencyFormatter
- **Widgets:** `lib/widgets/currency_converter_widget.dart` - UI Components
- **Documentation:** `docs/CURRENCY_CONVERSION_GUIDE.md` - Full Guide

---

**Last Updated:** December 2025  
**Status:** ✅ Production Ready
