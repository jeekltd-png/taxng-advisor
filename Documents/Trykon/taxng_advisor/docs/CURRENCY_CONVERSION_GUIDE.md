# Currency Conversion Implementation Guide

This guide explains how to use the currency conversion features in TaxNG Advisor.

## Overview

The app now includes built-in currency conversion to help users see their tax obligations in USD, supporting both:
- **Naira to USD** conversions (NGN → USD)
- **Pounds to USD** conversions (GBP → USD)

## Features

### 1. **CurrencyFormatter Extensions** (lib/utils/tax_helpers.dart)

New methods for currency conversion:

```dart
// Convert Naira to USD
double convertNairaToUsd(double nairaAmount)

// Format Naira to USD for display
String formatNairaToUsd(double nairaAmount)

// Convert Pounds to USD
double convertPoundsToUsd(double poundAmount)

// Format Pounds to USD for display
String formatPoundsToUsd(double poundAmount)

// Get all currency formats at once
Map<String, String> formatMultiCurrency(double nairaAmount)
```

### 2. **CurrencyConverterWidget** (lib/widgets/currency_converter_widget.dart)

Expandable widget showing tax amount in multiple currencies:

```dart
CurrencyConverterWidget(
  nairaAmount: 3000000,
  label: 'CIT Payable',
  color: Colors.red,
  isBold: true,
)
```

**Features:**
- Shows NGN amount by default
- Click "Show Conversion" to reveal USD equivalents
- Displays exchange rates
- Responsive and compact

### 3. **CurrencyConversionCard** (lib/widgets/currency_converter_widget.dart)

Non-expandable card for permanent display of all conversions:

```dart
CurrencyConversionCard(
  nairaAmount: 500000,
  title: 'Total Tax Conversion',
)
```

**Features:**
- Always shows all three currencies
- Includes GBP reference conversion
- Professional card styling
- Suitable for reports and formal documents

## Usage Examples

### Example 1: Add to CIT Calculator Screen

```dart
import 'package:taxng_advisor/widgets/currency_converter_widget.dart';

// In your build method where you display tax results:
_ResultCard(
  label: 'CIT Payable',
  value: CurrencyFormatter.formatCurrency(result!.taxPayable),
  color: Colors.red,
  isBold: true,
),
// Add conversion widget below
CurrencyConverterWidget(
  nairaAmount: result!.taxPayable,
  label: 'CIT Payable',
  color: Colors.red,
  isBold: true,
),
```

### Example 2: Add to VAT Calculator Screen

```dart
import 'package:taxng_advisor/widgets/currency_converter_widget.dart';

if (result.netPayable >= 0)
  _ResultCard(
    label: 'VAT Payable',
    value: CurrencyFormatter.formatCurrency(result.netPayable),
    color: Colors.red,
    isBold: true,
  )
else
  _ResultCard(
    label: 'VAT Refundable',
    value: CurrencyFormatter.formatCurrency(result.netPayable.abs()),
    color: Colors.green,
    isBold: true,
  ),
// Add conversion
CurrencyConverterWidget(
  nairaAmount: result.netPayable.abs(),
  label: result.netPayable >= 0 ? 'VAT Payable' : 'VAT Refundable',
  color: result.netPayable >= 0 ? Colors.red : Colors.green,
  isBold: true,
),
```

### Example 3: Use in Reports/Summaries

```dart
import 'package:taxng_advisor/widgets/currency_converter_widget.dart';

// For professional reports
CurrencyConversionCard(
  nairaAmount: totalTaxLiability,
  title: 'Annual Tax Liability Conversion',
),
```

### Example 4: Direct Formatting in Code

```dart
import 'package:taxng_advisor/utils/tax_helpers.dart';

double citAmount = 3000000;

// Format to USD
String usdAmount = CurrencyFormatter.formatNairaToUsd(citAmount);
// Output: "$1.95K"

// Get all formats
final currencies = CurrencyFormatter.formatMultiCurrency(citAmount);
// currencies['NGN'] = "₦3.00M"
// currencies['USD_from_NGN'] = "$1.95K"
// currencies['USD_from_GBP'] = "$3.01K"
```

## Exchange Rates

Current rates used in the app:

| Conversion | Rate | Example |
|------------|------|---------|
| 1 NGN → USD | 0.00065 | ₦1,000,000 = $650 |
| 1 GBP → USD | 1.27 | £1,000 = $1,270 |
| NGN → GBP | ~0.0079 | ₦1,000,000 ≈ £790 |

**Note:** To update rates, modify the constants in [tax_helpers.dart](../lib/utils/tax_helpers.dart):

```dart
static const double nairaToUsdRate = 0.00065; // Update this
static const double poundToUsdRate = 1.27;    // Update this
```

## Integration Checklist

To add currency conversion to a calculator screen:

- [ ] Import `CurrencyConverterWidget` from `lib/widgets/currency_converter_widget.dart`
- [ ] Add `CurrencyConverterWidget` or `CurrencyConversionCard` after the main tax result card
- [ ] Pass the tax amount and appropriate label
- [ ] (Optional) Set color and isBold properties to match your design
- [ ] Test the widget displays correctly
- [ ] Verify exchange rates are accurate for your region

## Best Practices

1. **Always include disclaimer:** Display a note that rates are for reference only
2. **Update rates quarterly:** Exchange rates change frequently
3. **Document rates used:** Keep screenshots of rates used for compliance
4. **Verify with banks:** Always confirm with your financial institution for formal filings
5. **Use official rates:** For CBN filings, use Central Bank of Nigeria rates

## Testing the Features

### Manual Testing Steps:

1. **Test Naira to USD conversion:**
   - Calculate any tax in NGN
   - Click "Show Conversion"
   - Verify USD amount = NGN × 0.00065

2. **Test Pounds to USD conversion:**
   - The GBP amount is calculated from NGN × 0.79
   - Verify USD from GBP = GBP amount × 1.27

3. **Test formatting:**
   - Test with large amounts (should show K/M notation)
   - Test with small amounts (should show full decimal)
   - Test with zero (should show $0.00)

## Troubleshooting

**Widget not showing?**
- Ensure widget is imported correctly
- Check that nairaAmount is a valid double
- Verify the widget is within a Column or ListView

**Exchange rates not updating?**
- Update the constants in CurrencyFormatter
- Perform a hot reload (flutter hot reload)
- Clear cache if needed (flutter clean)

**Formatting looks wrong?**
- Check screen width (K/M notation may need adjustment)
- Verify amount is not NaN or infinity
- Test with sample values

## API Reference

### CurrencyFormatter Methods

```dart
// Static methods for conversion
static double convertNairaToUsd(double nairaAmount)
static double convertPoundsToUsd(double poundAmount)

// Static methods for formatting
static String formatNairaToUsd(double nairaAmount)
static String formatPoundsToUsd(double poundAmount)
static Map<String, String> formatMultiCurrency(double nairaAmount)

// Existing methods (still available)
static String formatCurrency(double amount)
static String formatPercentage(double rate)
static String formatNumber(double amount)
```

### CurrencyConverterWidget Properties

```dart
const CurrencyConverterWidget({
  required double nairaAmount,      // Amount in Naira to convert
  String label = 'Tax Amount',      // Label to display
  Color? color,                      // Optional color for text
  bool isBold = false,              // Make amount bold
})
```

### CurrencyConversionCard Properties

```dart
const CurrencyConversionCard({
  required double nairaAmount,       // Amount in Naira
  String title = 'Tax Amount Conversion', // Card title
})
```

## FAQ

**Q: Can I change the exchange rates?**
A: Yes, edit the constants in `CurrencyFormatter` class in [tax_helpers.dart](../lib/utils/tax_helpers.dart)

**Q: Are these rates official?**
A: No, they're approximations. Always verify with CBN or your bank for official filings.

**Q: Can I hide the conversion for specific users?**
A: The widget can be conditionally included based on user settings (feature for future updates)

**Q: Will these affect tax calculations?**
A: No, conversions are display-only. All calculations remain in NGN.

---

**Last Updated:** December 2025  
**Related Files:**
- [tax_helpers.dart](../lib/utils/tax_helpers.dart) - CurrencyFormatter
- [currency_converter_widget.dart](../lib/widgets/currency_converter_widget.dart) - UI Widgets
- [CSV_EXCEL_IMPORT_GUIDE.md](../docs/CSV_EXCEL_IMPORT_GUIDE.md) - User Guide
