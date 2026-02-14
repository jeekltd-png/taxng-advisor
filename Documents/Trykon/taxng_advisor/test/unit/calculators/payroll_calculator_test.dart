import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/payroll/data/payroll_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';

void main() {
  group('Payroll Calculator - Basic PAYE', () {
    test('calculates PAYE for low income', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 200000,
        pensionRate: 8.0 / 100,
        nhfRate: 2.5 / 100,
        otherDeductions: 0,
      );

      expect(result.monthlyGross, equals(200000));
      expect(result.monthlyPaye, greaterThanOrEqualTo(0));
      expect(result.monthlyNet, lessThan(200000));
    });

    test('calculates PAYE for medium income', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 500000,
        pensionRate: 8.0 / 100,
        nhfRate: 2.5 / 100,
        otherDeductions: 0,
      );

      expect(result.monthlyPaye, greaterThan(0));
      expect(result.annualPaye, equals(result.monthlyPaye * 12));
    });

    test('calculates PAYE for high income', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 2000000,
        pensionRate: 8.0 / 100,
        nhfRate: 2.5 / 100,
        otherDeductions: 0,
      );

      expect(result.monthlyPaye, greaterThan(100000));
      expect(result.monthlyNet, lessThan(result.monthlyGross));
    });
  });

  group('Payroll Calculator - Deductions', () {
    test('pension deduction reduces gross salary', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 1000000,
        pensionRate: 8.0 / 100, // 8%
        nhfRate: 0,
        otherDeductions: 0,
      );

      // Pension deduction is 80k, so net < gross - PAYE
      expect(result.monthlyNet,
          lessThan(result.monthlyGross - result.monthlyPaye));
    });

    test('NHF deduction reduces gross salary', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 1000000,
        pensionRate: 0,
        nhfRate: 2.5 / 100, // 2.5%
        otherDeductions: 0,
      );

      // NHF deduction is 25k, so net < gross - PAYE
      expect(result.monthlyNet,
          lessThan(result.monthlyGross - result.monthlyPaye));
    });

    test('applies other deductions correctly', () {
      final withoutDeductions = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 1000000,
        pensionRate: 0,
        nhfRate: 0,
        otherDeductions: 0,
      );

      final withDeductions = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 1000000,
        pensionRate: 0,
        nhfRate: 0,
        otherDeductions: 50000,
      );

      // With 50k deductions, net should be 50k less
      expect(withDeductions.monthlyNet,
          equals(withoutDeductions.monthlyNet - 50000));
    });

    test('applies all deductions together', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 1000000,
        pensionRate: 8.0 / 100,
        nhfRate: 2.5 / 100,
        otherDeductions: 30000,
      );

      // All deductions should reduce net pay
      expect(result.monthlyNet,
          lessThan(1000000 - 135000)); // After all deductions + tax
    });
  });

  group('Payroll Calculator - Annual Calculations', () {
    test('multiplies monthly values by 12', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 500000,
        pensionRate: 8.0,
        nhfRate: 2.5,
        otherDeductions: 10000,
      );

      expect(result.annualGross, equals(result.monthlyGross * 12));
      expect(result.annualPaye, equals(result.monthlyPaye * 12));
      expect(result.annualNet, equals(result.monthlyNet * 12));
    });
  });

  group('Payroll Calculator - Input Validation', () {
    test('throws ArgumentError for negative gross salary', () {
      expect(
        () => PayrollCalculator.calculateWithDeductions(
          monthlyGross: -10000,
          pensionRate: 8.0 / 100,
          nhfRate: 2.5 / 100,
          otherDeductions: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for negative pension rate', () {
      expect(
        () => PayrollCalculator.calculateWithDeductions(
          monthlyGross: 500000,
          pensionRate: -1.0 / 100,
          nhfRate: 2.5 / 100,
          otherDeductions: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for negative other deductions', () {
      expect(
        () => PayrollCalculator.calculateWithDeductions(
          monthlyGross: 500000,
          pensionRate: 8.0 / 100,
          nhfRate: 2.5 / 100,
          otherDeductions: -5000,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Payroll Calculator - Edge Cases', () {
    test('handles zero gross salary', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 0,
        pensionRate: 8.0,
        nhfRate: 2.5,
        otherDeductions: 0,
      );

      expect(result.monthlyPaye, equals(0));
      expect(result.monthlyNet, equals(0));
    });

    test('handles minimum salary', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 1,
        pensionRate: 0,
        nhfRate: 0,
        otherDeductions: 0,
      );

      expect(result.monthlyGross, equals(1));
      expect(result.monthlyPaye, equals(0));
    });

    test('handles zero deduction rates', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 500000,
        pensionRate: 0,
        nhfRate: 0,
        otherDeductions: 0,
      );

      expect(
          result.monthlyNet, equals(result.monthlyGross - result.monthlyPaye));
    });

    test('timestamp is valid', () {
      final result = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 500000,
        pensionRate: 8.0 / 100,
        nhfRate: 2.5 / 100,
        otherDeductions: 0,
      );

      expect(result.calculatedAt, isNotNull);
      expect(
          result.calculatedAt
              .isBefore(DateTime.now().add(Duration(seconds: 1))),
          isTrue);
    });
  });

  group('Payroll Calculator - Serialization', () {
    test('toMap and fromMap preserve all data', () {
      final original = PayrollCalculator.calculateWithDeductions(
        monthlyGross: 800000,
        pensionRate: 8.0 / 100,
        nhfRate: 2.5 / 100,
        otherDeductions: 25000,
      );

      final map = original.toMap();
      final restored = PayrollResult.fromMap(map);

      expect(restored.monthlyGross, equals(original.monthlyGross));
      expect(restored.monthlyPaye, equals(original.monthlyPaye));
      expect(restored.monthlyNet, equals(original.monthlyNet));
      expect(restored.annualGross, equals(original.annualGross));
      expect(restored.annualPaye, equals(original.annualPaye));
      expect(restored.annualNet, equals(original.annualNet));
    });
  });
}
