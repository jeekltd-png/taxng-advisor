import 'package:hive/hive.dart';
import 'package:taxng_advisor/services/hive_service.dart';

/// Tax Analytics Service - Aggregates data across all tax types
class TaxAnalyticsService {
  /// Get total tax calculated across all types
  static double getTotalTaxCalculated(
      {DateTime? startDate, DateTime? endDate}) {
    double total = 0.0;

    // CIT
    final citBox = Hive.box(HiveService.citBox);
    for (var item in citBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        total += (map['taxPayable'] ?? 0.0);
      }
    }

    // PIT
    final pitBox = Hive.box(HiveService.pitBox);
    for (var item in pitBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        total += (map['totalTax'] ?? 0.0);
      }
    }

    // VAT
    final vatBox = Hive.box(HiveService.vatBox);
    for (var item in vatBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        total += (map['netPayable'] ?? 0.0).abs();
      }
    }

    // WHT
    final whtBox = Hive.box(HiveService.whtBox);
    for (var item in whtBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        total += (map['wht'] ?? 0.0);
      }
    }

    // Payroll
    final payrollBox = Hive.box(HiveService.payrollBox);
    for (var item in payrollBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        total += (map['monthlyPaye'] ?? 0.0);
      }
    }

    // Stamp Duty
    final stampBox = Hive.box(HiveService.stampDutyBox);
    for (var item in stampBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        total += (map['duty'] ?? 0.0);
      }
    }

    return total;
  }

  /// Get tax breakdown by type
  static Map<String, double> getTaxBreakdown(
      {DateTime? startDate, DateTime? endDate}) {
    Map<String, double> breakdown = {
      'CIT': 0.0,
      'PIT': 0.0,
      'VAT': 0.0,
      'WHT': 0.0,
      'PAYE': 0.0,
      'Stamp Duty': 0.0,
    };

    // CIT
    final citBox = Hive.box(HiveService.citBox);
    for (var item in citBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        breakdown['CIT'] = breakdown['CIT']! + (map['taxPayable'] ?? 0.0);
      }
    }

    // PIT
    final pitBox = Hive.box(HiveService.pitBox);
    for (var item in pitBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        breakdown['PIT'] = breakdown['PIT']! + (map['totalTax'] ?? 0.0);
      }
    }

    // VAT
    final vatBox = Hive.box(HiveService.vatBox);
    for (var item in vatBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        breakdown['VAT'] = breakdown['VAT']! + (map['netPayable'] ?? 0.0).abs();
      }
    }

    // WHT
    final whtBox = Hive.box(HiveService.whtBox);
    for (var item in whtBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        breakdown['WHT'] = breakdown['WHT']! + (map['wht'] ?? 0.0);
      }
    }

    // Payroll
    final payrollBox = Hive.box(HiveService.payrollBox);
    for (var item in payrollBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        breakdown['PAYE'] = breakdown['PAYE']! + (map['monthlyPaye'] ?? 0.0);
      }
    }

    // Stamp Duty
    final stampBox = Hive.box(HiveService.stampDutyBox);
    for (var item in stampBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final calculatedAt = DateTime.parse(map['calculatedAt']);
      if (_isInDateRange(calculatedAt, startDate, endDate)) {
        breakdown['Stamp Duty'] =
            breakdown['Stamp Duty']! + (map['duty'] ?? 0.0);
      }
    }

    return breakdown;
  }

  /// Get total paid from payment records
  static double getTotalPaid({DateTime? startDate, DateTime? endDate}) {
    final paymentsBox = Hive.box(HiveService.paymentsBox);
    double total = 0.0;

    for (var item in paymentsBox.values) {
      final map = Map<String, dynamic>.from(item as Map);
      final paidAt = DateTime.parse(map['paidAt']);
      if (_isInDateRange(paidAt, startDate, endDate)) {
        total += (map['amount'] ?? 0.0);
      }
    }

    return total;
  }

  /// Get recent calculations across all tax types
  static List<TaxCalculationItem> getRecentCalculations({int limit = 10}) {
    List<TaxCalculationItem> items = [];

    // CIT
    final citBox = Hive.box(HiveService.citBox);
    for (var key in citBox.keys) {
      final map = Map<String, dynamic>.from(citBox.get(key) as Map);
      items.add(TaxCalculationItem(
        id: 'CIT:$key',
        type: 'CIT',
        amount: (map['taxPayable'] ?? 0.0),
        date: DateTime.parse(map['calculatedAt']),
        description: 'Corporate Income Tax',
      ));
    }

    // PIT
    final pitBox = Hive.box(HiveService.pitBox);
    for (var key in pitBox.keys) {
      final map = Map<String, dynamic>.from(pitBox.get(key) as Map);
      items.add(TaxCalculationItem(
        id: 'PIT:$key',
        type: 'PIT',
        amount: (map['totalTax'] ?? 0.0),
        date: DateTime.parse(map['calculatedAt']),
        description: 'Personal Income Tax',
      ));
    }

    // VAT
    final vatBox = Hive.box(HiveService.vatBox);
    for (var key in vatBox.keys) {
      final map = Map<String, dynamic>.from(vatBox.get(key) as Map);
      items.add(TaxCalculationItem(
        id: 'VAT:$key',
        type: 'VAT',
        amount: (map['netPayable'] ?? 0.0).abs(),
        date: DateTime.parse(map['calculatedAt']),
        description: 'Value Added Tax',
      ));
    }

    // WHT
    final whtBox = Hive.box(HiveService.whtBox);
    for (var key in whtBox.keys) {
      final map = Map<String, dynamic>.from(whtBox.get(key) as Map);
      items.add(TaxCalculationItem(
        id: 'WHT:$key',
        type: 'WHT',
        amount: (map['wht'] ?? 0.0),
        date: DateTime.parse(map['calculatedAt']),
        description: 'Withholding Tax - ${map['type'] ?? ''}',
      ));
    }

    // Payroll
    final payrollBox = Hive.box(HiveService.payrollBox);
    for (var key in payrollBox.keys) {
      final map = Map<String, dynamic>.from(payrollBox.get(key) as Map);
      items.add(TaxCalculationItem(
        id: 'PAYE:$key',
        type: 'PAYE',
        amount: (map['monthlyPaye'] ?? 0.0),
        date: DateTime.parse(map['calculatedAt']),
        description: 'Payroll Tax (PAYE)',
      ));
    }

    // Stamp Duty
    final stampBox = Hive.box(HiveService.stampDutyBox);
    for (var key in stampBox.keys) {
      final map = Map<String, dynamic>.from(stampBox.get(key) as Map);
      items.add(TaxCalculationItem(
        id: 'STAMP:$key',
        type: 'Stamp Duty',
        amount: (map['duty'] ?? 0.0),
        date: DateTime.parse(map['calculatedAt']),
        description: 'Stamp Duty - ${map['type'] ?? ''}',
      ));
    }

    // Sort by date descending and limit
    items.sort((a, b) => b.date.compareTo(a.date));
    return items.take(limit).toList();
  }

  /// Get calculation count by tax type
  static Map<String, int> getCalculationCount(
      {DateTime? startDate, DateTime? endDate}) {
    Map<String, int> counts = {
      'CIT': 0,
      'PIT': 0,
      'VAT': 0,
      'WHT': 0,
      'PAYE': 0,
      'Stamp Duty': 0,
    };

    final citBox = Hive.box(HiveService.citBox);
    counts['CIT'] = citBox.values.where((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return _isInDateRange(
          DateTime.parse(map['calculatedAt']), startDate, endDate);
    }).length;

    final pitBox = Hive.box(HiveService.pitBox);
    counts['PIT'] = pitBox.values.where((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return _isInDateRange(
          DateTime.parse(map['calculatedAt']), startDate, endDate);
    }).length;

    final vatBox = Hive.box(HiveService.vatBox);
    counts['VAT'] = vatBox.values.where((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return _isInDateRange(
          DateTime.parse(map['calculatedAt']), startDate, endDate);
    }).length;

    final whtBox = Hive.box(HiveService.whtBox);
    counts['WHT'] = whtBox.values.where((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return _isInDateRange(
          DateTime.parse(map['calculatedAt']), startDate, endDate);
    }).length;

    final payrollBox = Hive.box(HiveService.payrollBox);
    counts['PAYE'] = payrollBox.values.where((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return _isInDateRange(
          DateTime.parse(map['calculatedAt']), startDate, endDate);
    }).length;

    final stampBox = Hive.box(HiveService.stampDutyBox);
    counts['Stamp Duty'] = stampBox.values.where((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return _isInDateRange(
          DateTime.parse(map['calculatedAt']), startDate, endDate);
    }).length;

    return counts;
  }

  /// Delete a calculation by id
  Future<void> deleteCalculation(String id) async {
    final parts = id.split(':');
    if (parts.length != 2) return;

    final taxType = parts[0];
    final key = parts[1];

    Box box;
    switch (taxType) {
      case 'CIT':
        box = Hive.box(HiveService.citBox);
        break;
      case 'PIT':
        box = Hive.box(HiveService.pitBox);
        break;
      case 'VAT':
        box = Hive.box(HiveService.vatBox);
        break;
      case 'WHT':
        box = Hive.box(HiveService.whtBox);
        break;
      case 'PAYE':
        box = Hive.box(HiveService.payrollBox);
        break;
      case 'STAMP':
        box = Hive.box(HiveService.stampDutyBox);
        break;
      default:
        return;
    }

    await box.delete(key);
  }

  /// Helper to check if date is in range
  static bool _isInDateRange(
      DateTime date, DateTime? startDate, DateTime? endDate) {
    if (startDate != null && date.isBefore(startDate)) return false;
    if (endDate != null && date.isAfter(endDate)) return false;
    return true;
  }

  /// Get monthly trend data for charts
  static Map<String, double> getMonthlyTrend(int months) {
    Map<String, double> trend = {};
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final total = getTotalTaxCalculated(
        startDate: month,
        endDate: nextMonth,
      );

      final monthKey = '${_getMonthName(month.month)} ${month.year}';
      trend[monthKey] = total;
    }

    return trend;
  }

  static String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }
}

/// Model for tax calculation items
class TaxCalculationItem {
  final String id; // Hive key
  final String type;
  final double amount;
  final DateTime date;
  final String description;

  TaxCalculationItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });
}
