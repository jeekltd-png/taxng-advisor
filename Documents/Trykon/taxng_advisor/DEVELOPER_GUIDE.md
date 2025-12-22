# TaxNG Advisor - Developer Implementation Guide

## Quick Start Guide for Using the Refactored Code

---

## Table of Contents
1. [Using Calculators](#using-calculators)
2. [Using Storage Services](#using-storage-services)
3. [Validation & Error Handling](#validation--error-handling)
4. [Formatting Utilities](#formatting-utilities)
5. [Reminders & Notifications](#reminders--notifications)
6. [Code Examples](#code-examples)

---

## Using Calculators

### CIT Calculator

#### Basic Usage
```dart
import 'package:taxng_advisor/features/cit/data/cit_calculator.dart';

// Calculate CIT
CitResult result = CitCalculator.calculate(
  turnover: 50000000,
  profit: 10000000,
);

// Access results
print('Category: ${result.category}');           // "Medium (20%)"
print('Tax Payable: ₦${result.taxPayable}');    // ₦2000000
print('Effective Rate: ${result.effectiveRate}'); // 0.04 (4%)
```

#### Features
- **Automatic Validation**: Validates turnover >= profit
- **Rate Categorization**: Small (0%), Medium (20%), Large (30%)
- **Effective Rate Calculation**: Built-in `effectiveRate` property
- **Storage Compatible**: Use `toMap()` for storage, `fromMap()` to retrieve

---

### PIT Calculator

#### Basic Usage
```dart
import 'package:taxng_advisor/features/pit/data/pit_calculator.dart';

// Calculate PIT with rent relief
PitResult result = PitCalculator.calculate(
  grossIncome: 5000000,
  otherDeductions: [200000], // Pension, etc.
  annualRentPaid: 1200000,   // 20% relief = max ₦500K
);

// Access results
print('Chargeable Income: ₦${result.chargeableIncome}');
print('Total Tax: ₦${result.totalTax}');
print('Tax Breakdown:');
result.breakdown.forEach((label, amount) {
  print('  $label: ₦$amount');
});
```

#### Features
- **Progressive Tax Bands**: 0% → 25% based on income
- **Rent Relief**: 20% of annual rent, capped at ₦500K
- **Tax Breakdown**: Detailed breakdown by tax band
- **Effective Rates**: Both overall and chargeable rates

---

### VAT Calculator

#### Basic Usage
```dart
import 'package:taxng_advisor/features/vat/data/vat_calculator.dart';

// Define supplies
List<VatSupply> supplies = [
  VatSupply(amount: 5000000, type: SupplyType.standard),
  VatSupply(amount: 2000000, type: SupplyType.zeroRated),
  VatSupply(amount: 1000000, type: SupplyType.exempt),
];

// Calculate VAT
VatResult result = VatCalculator.calculate(
  supplies: supplies,
  totalInputVat: 400000,
  exemptInputVat: 100000,
);

// Access results
print('Output VAT: ₦${result.outputVat}');           // ₦375,000
print('Recoverable Input: ₦${result.recoverableInput}'); // ₦300,000
print('Net Payable: ₦${result.netPayable}');         // ₦75,000
print('Refund Eligible: ₦${result.refundEligible}'); // ₦0
print('Is Refund: ${result.isRefund}');              // false
```

#### Supply Types
```dart
enum SupplyType {
  standard,      // 7.5% VAT
  zeroRated,     // 0% VAT (exports, etc.)
  exempt,        // 0% VAT (no input recovery)
}
```

#### Features
- **Type-Safe Supplies**: Use enum instead of strings
- **Input Tracking**: Separate exempt and recoverable VAT
- **Refund Tracking**: Automatic refund eligibility
- **Sales Summary**: Total sales by category

---

### WHT Calculator

#### Basic Usage
```dart
import 'package:taxng_advisor/features/wht/data/wht_calculator.dart';

// Calculate WHT on dividend payment
WhtResult result = WhtCalculator.calculate(
  amount: 1000000,
  type: WhtType.dividends,
);

// Access results
print('Amount: ₦${result.amount}');        // ₦1,000,000
print('WHT Rate: ${CurrencyFormatter.formatPercentage(result.rate)}'); // 10%
print('WHT Amount: ₦${result.wht}');       // ₦100,000
print('Net to Recipient: ₦${result.netAmount}'); // ₦900,000
```

#### WHT Types
```dart
enum WhtType {
  dividends,        // 10%
  interest,         // 10%
  rent,             // 10%
  royalties,        // 10%
  directorsFees,    // 10%
  professionalFees, // 10%
  construction,     // 5% (reduced)
  contracts,        // 5% (reduced)
  other,            // 10%
}
```

#### Helper Methods
```dart
// Get cumulative WHT
List<WhtResult> payments = [...];
double totalWht = WhtCalculator.calculateCumulativeWht(payments);

// Check registration requirement
if (WhtCalculator.requiresWhtRegistration(500000)) {
  // Register with FIRS
}

// Get description
String desc = WhtCalculator.getWhtDescription(WhtType.directorsFees);
// "Directors fees and sitting allowances"
```

---

### Stamp Duty Calculator

#### Basic Usage
```dart
import 'package:taxng_advisor/features/stamp_duty/data/stamp_duty_calculator.dart';

// Calculate stamp duty on electronic transfer
StampDutyResult result = StampDutyCalculator.calculate(
  amount: 50000000,
  type: StampDutyType.electronicTransfer,
);

// Access results
print('Stamp Duty: ₦${result.duty}');      // ₦75,000 (0.15%)
print('Net Amount: ₦${result.netAmount}'); // ₦49,925,000
```

#### Supported Types
- **Electronic Transfers**: 0.15% (min ₦10K)
- **Cheques**: Flat ₦20
- **Agreements**: 0.5%
- **Leases**: 1% of annual rent
- **Mortgages**: 0.5%
- **Sale**: 0.5%
- **Power of Attorney**: 0.1%
- **Affidavit**: Flat ₦100
- **Other**: 0.5%

#### Helper Methods
```dart
// Calculate total for multiple transactions
List<StampDutyResult> transactions = [...];
double total = StampDutyCalculator.calculateTotalStampDuty(transactions);

// Check registration requirement
if (StampDutyCalculator.requiresRegistration(500000)) {
  // Register for quarterly returns
}
```

---

### Payroll Calculator

#### Basic Usage
```dart
import 'package:taxng_advisor/features/payroll/data/payroll_calculator.dart';

// Simple PAYE calculation
PayrollResult result = PayrollCalculator.calculateMonthlyPaye(
  monthlyGross: 250000,
);

// With pension and other deductions
PayrollResult detailed = PayrollCalculator.calculateWithDeductions(
  monthlyGross: 250000,
  pensionRate: 0.08,    // 8% default
  nhfRate: 0.02,        // 2% default
  otherDeductions: 5000, // Insurance, etc.
);

// Access results
print('Monthly Gross: ₦${result.monthlyGross}');
print('Monthly PAYE: ₦${result.monthlyPaye}');
print('Monthly Net: ₦${result.monthlyNet}');
print('Effective Rate: ${CurrencyFormatter.formatPercentage(result.effectiveMonthlyRate)}');
```

#### Helper Methods
```dart
// Calculate individual deductions
double pension = PayrollCalculator.calculateDefaultPension(250000);      // ₦20,000
double nhf = PayrollCalculator.calculateNhf(250000);                    // ₦5,000
double total = PayrollCalculator.calculateTotalStatutoryDeductions(
  monthlyGross: 250000,
  monthlyPaye: 35000,
);

// Check tax relief eligibility
if (PayrollCalculator.qualifiesForTaxRelief(800000)) {
  // Apply special tax relief
}

// Calculate take-home
double takeHome = PayrollCalculator.calculateTakeHome(
  monthlyGross: 250000,
  monthlyPaye: 35000,
);
```

---

## Using Storage Services

### Save Calculations

```dart
import 'package:taxng_advisor/features/cit/services/cit_storage_service.dart';
import 'package:taxng_advisor/features/cit/data/cit_calculator.dart';

// Calculate
CitResult result = CitCalculator.calculate(...);

// Save to storage
await CitStorageService.saveEstimate(result.toMap());
```

### Retrieve Calculations

```dart
// Get recent estimates (last 5)
List<Map<String, dynamic>> recent = CitStorageService.getRecent(limit: 5);

// Get all estimates
List<Map<String, dynamic>> all = CitStorageService.getAllEstimates();

// Get by timestamp
Map<String, dynamic>? estimate = CitStorageService.getEstimateByTimestamp(
  '2025-12-15T14:30:00.000Z',
);
```

### Period Queries

```dart
import 'package:taxng_advisor/features/vat/services/vat_storage_service.dart';

// Get VAT returns for period
List<Map<String, dynamic>> returns = VatStorageService.getReturnsByPeriod(
  from: DateTime(2025, 1, 1),
  to: DateTime(2025, 12, 31),
);

// Calculate total VAT for year
double totalVat = VatStorageService.calculateTotalVatPayable();

// Calculate total refund due
double refund = VatStorageService.calculateTotalRefundDue();

// Track total sales
double sales = VatStorageService.calculateTotalSales();
```

### WHT Storage Examples

```dart
import 'package:taxng_advisor/features/wht/services/wht_storage_service.dart';

// Get records by type
List<Map<String, dynamic>> dividendWht = WhtStorageService.getRecordsByType(
  'Dividends',
);

// Calculate WHT by type for period
double directorsFeeWht = WhtStorageService.calculateWhtByType(
  'Directors Fees',
  from: DateTime(2025, 1, 1),
  to: DateTime(2025, 12, 31),
);

// Get summary of all WHT
Map<String, double> summary = WhtStorageService.getSummaryByType();
// Returns: {'Dividends': 500000, 'Professional Fees': 250000, ...}
```

---

## Validation & Error Handling

### Input Validation

```dart
import 'package:taxng_advisor/utils/tax_helpers.dart';

try {
  // This will throw ArgumentError
  CitCalculator.calculate(
    turnover: -5000000, // Invalid!
    profit: 1000000,
  );
} on ArgumentError catch (e) {
  print('Validation Error: ${e.message}');
  // "Turnover must be non-negative"
}
```

### Validator Methods

```dart
// Check validity before calculation
if (TaxValidator.isPositiveAmount(amount)) {
  // Proceed with calculation
}

if (TaxValidator.isTurnoverGreaterThanProfit(turnover, profit)) {
  // Safe to calculate CIT
}

// Or let validation happen automatically
try {
  TaxValidator.validateCitInputs(turnover, profit);
} on ArgumentError {
  // Handle validation error
}
```

---

## Formatting Utilities

### Currency Formatting

```dart
import 'package:taxng_advisor/utils/tax_helpers.dart';

double amount = 5750000;

// Format as currency
String formatted = CurrencyFormatter.formatCurrency(amount);
// "₦5.75M"

// Large amounts
CurrencyFormatter.formatCurrency(1500000000);  // "₦1500.00M"
CurrencyFormatter.formatCurrency(999999);       // "₦1000.00K"
CurrencyFormatter.formatCurrency(500);          // "₦500.00"

// Format percentage
String percent = CurrencyFormatter.formatPercentage(0.15);
// "15.00%"

// Format plain number
String number = CurrencyFormatter.formatNumber(1234.567);
// "1234.57"
```

### Date Utilities

```dart
import 'package:taxng_advisor/utils/tax_helpers.dart';

DateTime now = DateTime.now();

// Tax year string
String taxYear = DateHelper.getTaxYear(now);
// "2025/2026"

// Financial year boundaries
DateTime fyStart = DateHelper.getFinancialYearStart(2025);
DateTime fyEnd = DateHelper.getFinancialYearEnd(2025);

// Check if within year
bool inYear = DateHelper.isWithinFinancialYear(now, 2025);

// Days until deadline
DateTime deadline = DateTime(2025, 5, 31);
int days = DateHelper.daysUntilDeadline(deadline);

// Format deadline for display
String display = DateHelper.formatDeadline(deadline);
// "45 days left" or "Today" or "Overdue by 5 days"
```

---

## Reminders & Notifications

### Initialize Reminders

```dart
import 'package:taxng_advisor/services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize reminder service
  await ReminderService.init();
  
  // Schedule all default tax reminders
  await ReminderService.scheduleAllDefaultReminders();
  
  runApp(const MyApp());
}
```

### Default Reminders Scheduled

| Reminder | Schedule | Time |
|----------|----------|------|
| VAT | Monthly | 21st @ 9:00 AM |
| PIT | Annual | 31st May @ 9:00 AM |
| CIT | Annual | 31st May @ 10:00 AM |
| WHT | Monthly | 15th @ 10:00 AM |
| Payroll | Monthly | Last business day @ 5:00 PM |
| Stamp Duty | Quarterly | End of quarter @ 11:00 AM |

### Custom Reminders

```dart
// Schedule custom deadline
DateTime customDeadline = DateTime(2025, 12, 31, 14, 0);

await ReminderService.scheduleCustomReminder(
  id: 100,
  title: 'Provisional Tax Payment',
  body: 'Submit provisional tax for Q4 2025',
  dateTime: customDeadline,
);

// Cancel specific reminder
await ReminderService.cancelReminder(100);

// Cancel all reminders
await ReminderService.cancelAllReminders();
```

---

## Code Examples

### Complete Workflow: Calculate and Store CIT

```dart
import 'package:taxng_advisor/features/cit/data/cit_calculator.dart';
import 'package:taxng_advisor/features/cit/services/cit_storage_service.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';

// 1. Validate inputs
double turnover = 50000000;
double profit = 15000000;

if (!TaxValidator.isTurnoverGreaterThanProfit(turnover, profit)) {
  print('Invalid: Turnover must be >= Profit');
  return;
}

// 2. Calculate
CitResult result = CitCalculator.calculate(
  turnover: turnover,
  profit: profit,
);

// 3. Display results
print('Category: ${result.category}');
print('Tax Rate: ${CurrencyFormatter.formatPercentage(result.rate)}');
print('Tax Payable: ${CurrencyFormatter.formatCurrency(result.taxPayable)}');

// 4. Store
await CitStorageService.saveEstimate(result.toMap());

// 5. Retrieve later
CitResult retrieved = CitResult.fromMap(
  CitStorageService.getRecent()[0],
);

// 6. Calculate period liability
double yearlyLiability = CitStorageService.calculateTotalLiability(
  from: DateTime(2025, 1, 1),
  to: DateTime(2025, 12, 31),
);
```

### Complete Workflow: VAT Quarterly Return

```dart
import 'package:taxng_advisor/features/vat/data/vat_calculator.dart';
import 'package:taxng_advisor/features/vat/services/vat_storage_service.dart';

// Get period data
DateTime qStart = DateTime(2025, 10, 1);
DateTime qEnd = DateTime(2025, 12, 31);

// 1. Build supplies list
List<VatSupply> supplies = [
  VatSupply(
    amount: 50000000,
    type: SupplyType.standard,
    description: 'Local sales',
  ),
  VatSupply(
    amount: 10000000,
    type: SupplyType.zeroRated,
    description: 'Export sales',
  ),
];

// 2. Calculate VAT
VatResult result = VatCalculator.calculate(
  supplies: supplies,
  totalInputVat: 5000000,
  exemptInputVat: 0,
);

// 3. Store
await VatStorageService.saveReturn(result.toMap());

// 4. Generate report
List<Map<String, dynamic>> qReturns = VatStorageService.getReturnsByPeriod(
  from: qStart,
  to: qEnd,
);

double totalVat = VatStorageService.calculateTotalVatPayable(
  from: qStart,
  to: qEnd,
);

double totalSales = VatStorageService.calculateTotalSales(
  from: qStart,
  to: qEnd,
);

print('Q4 2025 VAT Report');
print('Total Sales: ${CurrencyFormatter.formatCurrency(totalSales)}');
print('VAT Payable: ${CurrencyFormatter.formatCurrency(totalVat)}');
```

---

## Best Practices

### 1. Always Validate Before Calculation
```dart
try {
  TaxValidator.validateCitInputs(turnover, profit);
  // Safe to proceed
} on ArgumentError catch (e) {
  // Handle error gracefully
  showErrorDialog(e.message);
  return;
}
```

### 2. Use Type-Safe Models
```dart
// ❌ Don't do this
double tax = result['totalTax'] as double; // Runtime cast

// ✅ Do this
double tax = result.totalTax; // Type-safe
```

### 3. Leverage Calculated Properties
```dart
// Use built-in properties instead of manual calculation
double effectiveRate = result.effectiveRate;  // ✅ Built-in
double effective = result.totalTax / grossIncome; // ❌ Manual
```

### 4. Format for Display
```dart
// Format all amounts for UI display
String displayAmount = CurrencyFormatter.formatCurrency(result.taxPayable);
String displayRate = CurrencyFormatter.formatPercentage(result.rate);
```

### 5. Handle Errors Gracefully
```dart
try {
  CitResult result = CitCalculator.calculate(...);
} on ArgumentError catch (e) {
  // Log and display user-friendly message
  _showSnackBar('Invalid input: ${e.message}');
} catch (e) {
  // Unexpected error
  _showSnackBar('An error occurred. Please try again.');
}
```

---

## Migration from Old Code

### Before (Old Way)
```dart
Map<String, dynamic> result = CitCalculator.calculate(
  turnover: 50000000,
  profit: 10000000,
);
double tax = result['taxPayable'] as double;
String category = result['category'] as String;
```

### After (New Way)
```dart
CitResult result = CitCalculator.calculate(
  turnover: 50000000,
  profit: 10000000,
);
double tax = result.taxPayable;
String category = result.category;
```

---

## Support & Troubleshooting

### Common Issues

**Q: Getting type error with storage results?**
```dart
// ✅ Correct: Convert back to typed class
CitResult result = CitResult.fromMap(
  CitStorageService.getRecent()[0],
);
```

**Q: Validation error on valid inputs?**
```dart
// Check your inputs match the requirements
// For CIT: turnover >= profit, both >= 0
TaxValidator.validateCitInputs(turnover, profit); // Will throw if invalid
```

**Q: Reminders not showing?**
```dart
// Ensure initialized in main()
await ReminderService.init();
await ReminderService.scheduleAllDefaultReminders();

// Check system notification permissions
```

---

**For questions or issues, refer to the `REFACTORING_SUMMARY.md` document.**

