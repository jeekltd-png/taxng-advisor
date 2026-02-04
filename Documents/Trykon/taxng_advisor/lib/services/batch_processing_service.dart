import 'package:taxng_advisor/services/tax_analytics_service.dart';
import 'package:hive/hive.dart';
import 'package:taxng_advisor/services/hive_service.dart';

/// Model for batch processing rule
class BatchRule {
  final String id;
  final String name;
  final String description;
  final BatchRuleType type;
  final Map<String, dynamic> parameters;

  BatchRule({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.parameters,
  });
}

enum BatchRuleType {
  applyDiscount,
  applyMarkup,
  recalculateWithRate,
  addFixedAmount,
  multiplyByFactor,
  setCategory,
  addTags,
}

/// Service for batch processing calculations
class BatchProcessingService {
  /// Apply discount to selected calculations
  static Future<List<Map<String, dynamic>>> applyDiscount({
    required List<TaxCalculationItem> calculations,
    required double discountPercent,
    bool preview = false,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (final calc in calculations) {
      final discount = calc.amount * (discountPercent / 100);
      final newAmount = calc.amount - discount;

      results.add({
        'original': calc,
        'newAmount': newAmount,
        'difference': -discount,
        'operation': 'Discount $discountPercent%',
      });

      if (!preview) {
        await _updateCalculationAmount(calc, newAmount);
      }
    }

    return results;
  }

  /// Apply markup to selected calculations
  static Future<List<Map<String, dynamic>>> applyMarkup({
    required List<TaxCalculationItem> calculations,
    required double markupPercent,
    bool preview = false,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (final calc in calculations) {
      final markup = calc.amount * (markupPercent / 100);
      final newAmount = calc.amount + markup;

      results.add({
        'original': calc,
        'newAmount': newAmount,
        'difference': markup,
        'operation': 'Markup $markupPercent%',
      });

      if (!preview) {
        await _updateCalculationAmount(calc, newAmount);
      }
    }

    return results;
  }

  /// Add fixed amount to selected calculations
  static Future<List<Map<String, dynamic>>> addFixedAmount({
    required List<TaxCalculationItem> calculations,
    required double amount,
    bool preview = false,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (final calc in calculations) {
      final newAmount = calc.amount + amount;

      results.add({
        'original': calc,
        'newAmount': newAmount,
        'difference': amount,
        'operation': 'Add ₦${amount.toStringAsFixed(2)}',
      });

      if (!preview) {
        await _updateCalculationAmount(calc, newAmount);
      }
    }

    return results;
  }

  /// Multiply by factor
  static Future<List<Map<String, dynamic>>> multiplyByFactor({
    required List<TaxCalculationItem> calculations,
    required double factor,
    bool preview = false,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (final calc in calculations) {
      final newAmount = calc.amount * factor;
      final difference = newAmount - calc.amount;

      results.add({
        'original': calc,
        'newAmount': newAmount,
        'difference': difference,
        'operation': 'Multiply by $factor',
      });

      if (!preview) {
        await _updateCalculationAmount(calc, newAmount);
      }
    }

    return results;
  }

  /// Recalculate with new rate
  static Future<List<Map<String, dynamic>>> recalculateWithRate({
    required List<TaxCalculationItem> calculations,
    required double newRate,
    bool preview = false,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (final calc in calculations) {
      // This is a simplified recalculation
      // In reality, you'd need to access the original calculation data
      final newAmount = calc.amount * (newRate / 100);

      results.add({
        'original': calc,
        'newAmount': newAmount,
        'difference': newAmount - calc.amount,
        'operation': 'Recalculate at $newRate%',
      });

      if (!preview) {
        await _updateCalculationAmount(calc, newAmount);
      }
    }

    return results;
  }

  /// Apply batch rule
  static Future<List<Map<String, dynamic>>> applyBatchRule({
    required List<TaxCalculationItem> calculations,
    required BatchRule rule,
    bool preview = false,
  }) async {
    switch (rule.type) {
      case BatchRuleType.applyDiscount:
        return applyDiscount(
          calculations: calculations,
          discountPercent: rule.parameters['percent'],
          preview: preview,
        );

      case BatchRuleType.applyMarkup:
        return applyMarkup(
          calculations: calculations,
          markupPercent: rule.parameters['percent'],
          preview: preview,
        );

      case BatchRuleType.addFixedAmount:
        return addFixedAmount(
          calculations: calculations,
          amount: rule.parameters['amount'],
          preview: preview,
        );

      case BatchRuleType.multiplyByFactor:
        return multiplyByFactor(
          calculations: calculations,
          factor: rule.parameters['factor'],
          preview: preview,
        );

      case BatchRuleType.recalculateWithRate:
        return recalculateWithRate(
          calculations: calculations,
          newRate: rule.parameters['rate'],
          preview: preview,
        );

      default:
        return [];
    }
  }

  /// Get predefined batch rules
  static List<BatchRule> getPredefinedRules() {
    return [
      BatchRule(
        id: 'discount_5',
        name: '5% Discount',
        description: 'Apply 5% discount to selected calculations',
        type: BatchRuleType.applyDiscount,
        parameters: {'percent': 5.0},
      ),
      BatchRule(
        id: 'discount_10',
        name: '10% Discount',
        description: 'Apply 10% discount to selected calculations',
        type: BatchRuleType.applyDiscount,
        parameters: {'percent': 10.0},
      ),
      BatchRule(
        id: 'markup_5',
        name: '5% Markup',
        description: 'Apply 5% markup to selected calculations',
        type: BatchRuleType.applyMarkup,
        parameters: {'percent': 5.0},
      ),
      BatchRule(
        id: 'markup_10',
        name: '10% Markup',
        description: 'Apply 10% markup to selected calculations',
        type: BatchRuleType.applyMarkup,
        parameters: {'percent': 10.0},
      ),
      BatchRule(
        id: 'double',
        name: 'Double Amount',
        description: 'Multiply amount by 2',
        type: BatchRuleType.multiplyByFactor,
        parameters: {'factor': 2.0},
      ),
      BatchRule(
        id: 'half',
        name: 'Half Amount',
        description: 'Multiply amount by 0.5',
        type: BatchRuleType.multiplyByFactor,
        parameters: {'factor': 0.5},
      ),
    ];
  }

  /// Update calculation amount in Hive
  static Future<void> _updateCalculationAmount(
    TaxCalculationItem calc,
    double newAmount,
  ) async {
    final parts = calc.id.split(':');
    if (parts.length != 2) return;

    final taxType = parts[0];
    final key = parts[1];

    Box box;
    String amountKey;

    switch (taxType) {
      case 'CIT':
        box = Hive.box(HiveService.citBox);
        amountKey = 'taxPayable';
        break;
      case 'PIT':
        box = Hive.box(HiveService.pitBox);
        amountKey = 'totalTax';
        break;
      case 'VAT':
        box = Hive.box(HiveService.vatBox);
        amountKey = 'netPayable';
        break;
      case 'WHT':
        box = Hive.box(HiveService.whtBox);
        amountKey = 'wht';
        break;
      case 'PAYE':
        box = Hive.box(HiveService.payrollBox);
        amountKey = 'monthlyPaye';
        break;
      case 'STAMP':
        box = Hive.box(HiveService.stampDutyBox);
        amountKey = 'duty';
        break;
      default:
        return;
    }

    final data = box.get(key);
    if (data != null) {
      final map = Map<String, dynamic>.from(data);
      map[amountKey] = newAmount;
      await box.put(key, map);
    }
  }

  /// Calculate total impact of batch operation
  static Map<String, dynamic> calculateBatchImpact(
    List<Map<String, dynamic>> results,
  ) {
    double totalOriginal = 0;
    double totalNew = 0;
    double totalDifference = 0;

    for (final result in results) {
      totalOriginal += (result['original'] as TaxCalculationItem).amount;
      totalNew += result['newAmount'] as double;
      totalDifference += result['difference'] as double;
    }

    return {
      'totalOriginal': totalOriginal,
      'totalNew': totalNew,
      'totalDifference': totalDifference,
      'count': results.length,
      'percentageChange': totalOriginal > 0
          ? ((totalDifference / totalOriginal) * 100)
          : 0.0,
    };
  }
}
