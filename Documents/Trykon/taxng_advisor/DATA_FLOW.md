# TaxNG Advisor - Data Flow Architecture

## Overview
This document explains how user data is collected, processed, calculated, stored, and displayed throughout the TaxNG Advisor application.

---

## 1. User Input → Calculation Flow

### Step 1: User Interface Layer (Presentation)
**Location:** `lib/features/[tax_type]/presentation/[calculator]_screen.dart`

Users enter their financial data through **Flutter TextField widgets** with validation:

```dart
// Example: CIT Calculator Screen
TextFormField(
  controller: _turnoverController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: 'Annual Business Turnover (₦)',
    hintText: 'e.g., 75000000',
  ),
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Please enter turnover';
    if (double.tryParse(value!) == null) return 'Please enter a valid number';
    return null;
  },
)
```

**Input Validation:**
- Non-empty check
- Numeric validation using `double.tryParse()`
- Custom business rules via `TaxValidator` class

### Step 2: Data Processing
When user taps "Calculate" button:

```dart
void _calculateCIT() {
  if (_formKey.currentState!.validate()) {
    // 1. Extract user input
    final turnover = double.parse(_turnoverController.text);
    final profit = double.parse(_profitController.text);
    
    // 2. Pass to calculator
    final result = CitCalculator.calculate(
      turnover: turnover, 
      profit: profit
    );
    
    // 3. Save result
    CitStorageService.saveEstimate(result);
    
    // 4. Update UI
    setState(() {
      _showResults = true;
    });
  }
}
```

---

## 2. Calculator Layer (Business Logic)

**Location:** `lib/features/[tax_type]/data/[calculator].dart`

Pure calculation functions that accept input and return typed results:

### CIT Calculator Example
```dart
class CitCalculator {
  static CitResult calculate({
    required double turnover,
    required double profit,
  }) {
    // 1. Validate input
    if (!TaxValidator.isTurnoverGreaterThanProfit(turnover, profit)) {
      throw ArgumentError('Turnover must be >= profit');
    }
    
    // 2. Determine business category
    String category;
    double rate;
    if (turnover < 25000000) {
      category = 'Small';
      rate = 0.0;
    } else if (turnover < 100000000) {
      category = 'Medium';
      rate = 0.20;
    } else {
      category = 'Large';
      rate = 0.30;
    }
    
    // 3. Calculate tax
    final taxPayable = profit * rate;
    
    // 4. Return typed result object
    return CitResult(
      turnover: turnover,
      profit: profit,
      category: category,
      rate: rate,
      taxPayable: taxPayable,
    );
  }
}
```

**Key Features:**
- Accepts clean input parameters
- Returns **typed result objects** (not Map<String, dynamic>)
- Validates business rules
- Pure functions (no side effects)

---

## 3. Data Models (Type Safety)

**Location:** `lib/models/tax_result.dart`

All tax calculations return **strongly-typed result objects**:

```dart
class CitResult extends TaxResult {
  final double turnover;
  final double profit;
  final String category;
  final double rate;
  final double taxPayable;
  final DateTime _calculatedAt;

  CitResult({
    required this.turnover,
    required this.profit,
    required this.category,
    required this.rate,
    required this.taxPayable,
    DateTime? calculatedAt,
  }) : _calculatedAt = calculatedAt ?? DateTime.now();

  @override
  DateTime get calculatedAt => _calculatedAt;

  double get effectiveRate => 
    turnover > 0 ? taxPayable / turnover : 0.0;

  /// Serialize for storage
  Map<String, dynamic> toMap() => {
    'turnover': turnover,
    'profit': profit,
    'category': category,
    'rate': rate,
    'taxPayable': taxPayable,
    'calculatedAt': _calculatedAt.toIso8601String(),
  };

  /// Deserialize from storage
  factory CitResult.fromMap(Map<String, dynamic> map) => CitResult(
    turnover: map['turnover'] as double,
    profit: map['profit'] as double,
    category: map['category'] as String,
    rate: map['rate'] as double,
    taxPayable: map['taxPayable'] as double,
    calculatedAt: DateTime.parse(map['calculatedAt'] as String),
  );
}
```

**Benefits:**
- ✅ Type-safe throughout the application
- ✅ Easy serialization for storage
- ✅ Computed properties (effective rate, etc.)
- ✅ No runtime type errors

---

## 4. Storage Layer (Persistence)

**Location:** `lib/features/[tax_type]/services/[service]_storage_service.dart`

Results are persisted to offline storage using Hive:

```dart
class CitStorageService {
  static const String boxName = 'cit_estimates';

  /// Save a calculation result
  static Future<void> saveEstimate(CitResult result) async {
    final box = Hive.box(boxName);
    await box.add(result.toMap());  // Uses toMap() for serialization
  }

  /// Retrieve all estimates
  static List<CitResult> getAllEstimates() {
    final box = Hive.box(boxName);
    final values = box.values.cast<Map<String, dynamic>>().toList();
    values.sort((a, b) =>
      (b['calculatedAt'] as String)
        .compareTo(a['calculatedAt'] as String)
    );
    return values
      .map((map) => CitResult.fromMap(map))  // Uses fromMap() for deserialization
      .toList();
  }

  /// Query by date range
  static double calculateTotalLiability({
    DateTime? from,
    DateTime? to,
  }) {
    final estimates = getAllEstimates();
    final now = DateTime.now();
    final fromDate = from ?? DateTime(now.year);
    final toDate = to ?? now;

    double total = 0.0;
    for (final estimate in estimates) {
      if (estimate.calculatedAt.isAfter(fromDate) && 
          estimate.calculatedAt.isBefore(toDate)) {
        total += estimate.taxPayable;
      }
    }
    return total;
  }
}
```

**Data Storage:**
- **Framework:** Hive (offline-first NoSQL)
- **Format:** JSON-like key-value pairs
- **Location:** Device local storage
- **Availability:** Works without internet

---

## 5. Complete CIT Return Data Flow

### User Entry Flow

```
┌─────────────────────────────┐
│   User Enters Data          │
│ - Turnover: ₦75,000,000    │
│ - Profit: ₦15,000,000      │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  UI Validation             │
│ - Check not empty          │
│ - Check numeric            │
│ - FormState.validate()     │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  Extract from Controller   │
│ - turnover = 75000000.0    │
│ - profit = 15000000.0      │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  Calculator.calculate()     │
│ - Validate business rules  │
│ - Determine category       │
│ - Calculate tax (20%)      │
│ - Return CitResult         │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  CitResult Object          │
│ {                           │
│   turnover: 75000000,       │
│   profit: 15000000,         │
│   category: "Medium",       │
│   rate: 0.20,              │
│   taxPayable: 3000000,      │
│   effectiveRate: 0.04,     │
│   calculatedAt: now         │
│ }                           │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  Save to Storage            │
│ - result.toMap()           │
│ - Store in Hive box        │
│ - Persisted locally        │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  Display Results            │
│ - Format with CurrencyFormatter
│ - Show effective rate      │
│ - Enable history view      │
└─────────────────────────────┘
```

---

## 6. Data Retrieval & History

### Viewing Previous Calculations

```dart
// Retrieve from storage
final recentEstimates = CitStorageService.getRecent(limit: 10);

// Build UI with results
ListView.builder(
  itemCount: recentEstimates.length,
  itemBuilder: (context, index) {
    final result = recentEstimates[index];
    return ListTile(
      title: Text('CIT: ${CurrencyFormatter.formatCurrency(result.taxPayable)}'),
      subtitle: Text('${result.category} - ${DateHelper.formatDeadline(result.calculatedAt)}'),
    );
  },
)
```

### Period-based Queries

```dart
// Calculate total liability for Q1 2025
final q1Liability = CitStorageService.calculateTotalLiability(
  from: DateTime(2025, 1, 1),
  to: DateTime(2025, 3, 31),
);
```

---

## 7. All Tax Types - Data Input Parameters

### CIT (Corporate Income Tax)
```dart
CitCalculator.calculate(
  turnover: double,      // Annual business revenue
  profit: double,        // Chargeable profit
)
```

### PIT (Personal Income Tax)
```dart
PitCalculator.calculate(
  grossIncome: double,           // Annual gross income
  otherDeductions: List<double>, // Non-rent deductions
  annualRentPaid: double,        // Actual rent paid
)
```

### VAT (Value Added Tax)
```dart
VatCalculator.calculate(
  supplies: List<VatSupply>,  // List of sales by type
  totalInputVat: double,      // Total VAT on purchases
  exemptInputVat: double,     // VAT on exempt supplies
)
```

### WHT (Withholding Tax)
```dart
WhtCalculator.calculate(
  amount: double,        // Gross payment amount
  type: WhtType,        // Type of payment (dividend, rent, etc.)
)
```

### Stamp Duty
```dart
StampDutyCalculator.calculate(
  amount: double,                  // Transaction amount
  type: StampDutyType,            // Type of transaction
)
```

### Payroll
```dart
PayrollCalculator.calculateWithDeductions(
  monthlyGross: double,   // Monthly salary
  pensionRate: double,    // Pension % (e.g., 0.08)
  nhfRate: double,        // NHF % (e.g., 0.02)
  otherDeductions: double, // Other deductions
)
```

---

## 8. Utility Functions for Data Formatting

**Location:** `lib/utils/tax_helpers.dart`

### Input Validation
```dart
class TaxValidator {
  static bool isPositiveAmount(double amount) => amount > 0;
  static bool isTurnoverGreaterThanProfit(double turnover, double profit) 
    => turnover >= profit;
  static bool isValidPercentage(double value) 
    => value >= 0 && value <= 1;
}
```

### Output Formatting
```dart
class CurrencyFormatter {
  // ₦75,000,000 → "₦75M"
  static String formatCurrency(double amount) { ... }
  
  // 0.20 → "20%"
  static String formatPercentage(double value) { ... }
}
```

### Date Utilities
```dart
class DateHelper {
  static String formatDeadline(DateTime date) { ... }
  static int daysUntilDeadline(DateTime deadline) { ... }
}
```

---

## 9. Key Design Principles

### 1. **Separation of Concerns**
- **UI Layer:** Handles input/output only
- **Calculation Layer:** Pure math, no side effects
- **Storage Layer:** Persistence only
- **Models:** Data representation

### 2. **Type Safety**
- Never use `Map<String, dynamic>` for results
- All calculations return typed objects
- Compile-time type checking throughout

### 3. **Validation at Every Step**
- UI validation (empty, numeric)
- Business logic validation (rules)
- Storage serialization/deserialization

### 4. **Immutability**
- Results are immutable once created
- No modification after calculation
- New calculation = new object

### 5. **Offline-First**
- All data stored locally in Hive
- Works without internet
- Automatic persistence

---

## 10. Example: Complete CIT Return Workflow

```dart
// 1. USER ENTERS DATA
TextFormField(
  controller: turnoverController,  // User types: 75000000
)

// 2. USER TAPS CALCULATE
ElevatedButton(
  onPressed: () {
    // 3. VALIDATE
    if (formKey.currentState!.validate()) {
      
      // 4. EXTRACT
      final turnover = double.parse(turnoverController.text);
      final profit = double.parse(profitController.text);
      
      // 5. CALCULATE (Returns CitResult)
      final result = CitCalculator.calculate(
        turnover: turnover,
        profit: profit,
      );
      
      // 6. SAVE
      CitStorageService.saveEstimate(result);
      
      // 7. DISPLAY
      setState(() => showResults = true);
    }
  },
)

// 8. RESULTS DISPLAYED
Column(
  children: [
    // CIT Payable: ₦3,000,000 (formatted from result.taxPayable)
    // Category: Medium (from result.category)
    // Effective Rate: 4% (calculated from result)
  ],
)

// 9. PERSISTENCE
// Result stored in Hive:
// {
//   'turnover': 75000000,
//   'profit': 15000000,
//   'category': 'Medium',
//   'rate': 0.20,
//   'taxPayable': 3000000,
//   'calculatedAt': '2025-12-15T10:30:00.000Z'
// }

// 10. RETRIEVAL
final allResults = CitStorageService.getAllEstimates();
// Returns List<CitResult> sorted by date (newest first)
```

---

## Summary

**TaxNG Advisor Data Flow:**

```
User Input → UI Validation → Calculator → Typed Result → 
Storage (Hive) → UI Display → History/Reports
```

This architecture ensures:
- ✅ Type safety throughout
- ✅ Easy testing of calculations
- ✅ Reusable storage across features
- ✅ Offline functionality
- ✅ Clear separation of concerns
