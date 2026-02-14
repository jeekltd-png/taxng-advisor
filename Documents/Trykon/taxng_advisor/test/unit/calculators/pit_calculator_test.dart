import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/pit/data/pit_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';

void main() {
  group('PIT Calculator - Progressive Tax Bands', () {
    test('calculates tax for income below first band (300k)', () {
      final result = PitCalculator.calculate(
        grossIncome: 200000,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      // Below first band, only CRA (20% + 1%) applies
      expect(result.totalTax, equals(0)); // Tax-free after CRA
      expect(result.chargeableIncome, lessThanOrEqualTo(200000));
    });

    test('calculates tax for income in first band (300k-600k)', () {
      final result = PitCalculator.calculate(
        grossIncome: 500000,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      // After CRA, chargeable income taxed at 7%
      expect(result.totalTax, greaterThanOrEqualTo(0));
      expect(result.chargeableIncome, lessThanOrEqualTo(500000));
    });

    test('calculates tax for income across multiple bands', () {
      final result = PitCalculator.calculate(
        grossIncome: 5000000,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      expect(result.totalTax, greaterThan(0));
      expect(result.breakdown.isNotEmpty, isTrue);
      expect(result.effectiveRate, greaterThan(0));
      expect(result.effectiveRate, lessThan(24.0)); // Max rate
    });

    test('applies all progressive tax bands correctly', () {
      final result = PitCalculator.calculate(
        grossIncome: 10000000,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      // Should have entries for multiple tax bands
      expect(result.breakdown.length, greaterThan(1));
      expect(result.totalTax, greaterThan(1000000)); // Significant tax
      expect(result.effectiveRate, lessThanOrEqualTo(24.0));
    });
  });

  group('PIT Calculator - Deductions', () {
    test('applies pension deduction correctly', () {
      final withoutPension = PitCalculator.calculate(
        grossIncome: 3000000,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      final withPension = PitCalculator.calculate(
        grossIncome: 3000000,
        otherDeductions: [240000], // 8% of 3M
        annualRentPaid: 0,
      );

      expect(withPension.totalTax, lessThan(withoutPension.totalTax));
      expect(withPension.chargeableIncome,
          lessThan(withoutPension.chargeableIncome));
    });

    test('applies rent relief correctly', () {
      final withoutRent = PitCalculator.calculate(
        grossIncome: 2000000,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      final withRent = PitCalculator.calculate(
        grossIncome: 2000000,
        otherDeductions: [],
        annualRentPaid: 1200000,
      );

      expect(withRent.rentRelief, greaterThan(0));
      expect(withRent.totalTax, lessThan(withoutRent.totalTax));
    });

    test('caps rent relief appropriately', () {
      // High income with high rent
      final result = PitCalculator.calculate(
        grossIncome: 5000000,
        otherDeductions: [],
        annualRentPaid: 5000000, // Very high rent
      );

      // Rent relief should be capped
      expect(result.rentRelief, lessThanOrEqualTo(1000000)); // Max cap
    });

    test('applies multiple deductions together', () {
      final result = PitCalculator.calculate(
        grossIncome: 5000000,
        otherDeductions: [400000, 125000], // Pension + NHF
        annualRentPaid: 1500000,
      );

      expect(result.totalDeductions, greaterThanOrEqualTo(400000 + 125000));
      expect(result.rentRelief, greaterThan(0));
      expect(result.chargeableIncome, lessThan(5000000));
    });
  });

  group('PIT Calculator - Input Validation', () {
    test('throws ArgumentError for negative gross income', () {
      expect(
        () => PitCalculator.calculate(
          grossIncome: -1000,
          otherDeductions: [],
          annualRentPaid: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for negative deduction', () {
      expect(
        () => PitCalculator.calculate(
          grossIncome: 3000000,
          otherDeductions: [-5000],
          annualRentPaid: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for negative rent', () {
      expect(
        () => PitCalculator.calculate(
          grossIncome: 3000000,
          otherDeductions: [],
          annualRentPaid: -50000,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('PIT Calculator - Edge Cases', () {
    test('handles zero income', () {
      final result = PitCalculator.calculate(
        grossIncome: 0,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      expect(result.totalTax, equals(0));
      expect(result.chargeableIncome, equals(0));
      expect(result.effectiveRate, equals(0));
    });

    test('handles minimum income', () {
      final result = PitCalculator.calculate(
        grossIncome: 1,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      expect(result.grossIncome, equals(1));
      expect(result.totalTax, equals(0));
    });

    test('handles very high income', () {
      final result = PitCalculator.calculate(
        grossIncome: 100000000,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      expect(result.totalTax, greaterThan(10000000));
      // Effective rate is decimal (0.24 not 24), approaches max 24%
      expect(result.effectiveRate * 100, greaterThan(20)); // > 20%
      expect(result.effectiveRate * 100, lessThanOrEqualTo(24)); // <= 24%
    });

    test('result timestamp is valid', () {
      final result = PitCalculator.calculate(
        grossIncome: 3000000,
        otherDeductions: [],
        annualRentPaid: 0,
      );

      expect(result.calculatedAt, isNotNull);
      expect(
          result.calculatedAt
              .isBefore(DateTime.now().add(Duration(seconds: 1))),
          isTrue);
    });
  });

  group('PIT Calculator - Serialization', () {
    test('toMap and fromMap preserve all data', () {
      final original = PitCalculator.calculate(
        grossIncome: 4000000,
        otherDeductions: [320000, 100000],
        annualRentPaid: 1200000,
      );

      final map = original.toMap();
      final restored = PitResult.fromMap(map);

      expect(restored.grossIncome, equals(original.grossIncome));
      expect(restored.totalDeductions, equals(original.totalDeductions));
      expect(restored.rentRelief, equals(original.rentRelief));
      expect(restored.chargeableIncome, equals(original.chargeableIncome));
      expect(restored.totalTax, equals(original.totalTax));
      expect(restored.effectiveRate, equals(original.effectiveRate));
    });
  });
}
