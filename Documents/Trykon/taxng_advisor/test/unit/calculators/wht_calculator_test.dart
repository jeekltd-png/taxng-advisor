import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/wht/data/wht_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';

void main() {
  group('WHT Calculator - Payment Types', () {
    test('calculates 10% WHT for dividend income', () {
      final result = WhtCalculator.calculate(
        amount: 1000000,
        type: WhtType.dividends,
      );

      expect(result.amount, equals(1000000));
      expect(result.wht, equals(100000)); // 10%
      expect(result.netAmount, equals(900000));
      expect(result.rate, equals(0.10));
    });

    test('calculates 10% WHT for interest income', () {
      final result = WhtCalculator.calculate(
        amount: 500000,
        type: WhtType.interest,
      );

      expect(result.wht, equals(50000)); // 10%
      expect(result.rate, equals(0.10));
    });

    test('calculates 10% WHT for rent', () {
      final result = WhtCalculator.calculate(
        amount: 2000000,
        type: WhtType.rent,
      );

      expect(result.wht, equals(200000)); // 10%
      expect(result.rate, equals(0.10));
    });

    test('calculates 10% WHT for royalties', () {
      final result = WhtCalculator.calculate(
        amount: 750000,
        type: WhtType.royalties,
      );

      expect(result.wht, equals(75000)); // 10%
      expect(result.rate, equals(0.10));
    });

    test('calculates 10% WHT for professional fees', () {
      final result = WhtCalculator.calculate(
        amount: 1500000,
        type: WhtType.professionalFees,
      );

      expect(result.wht, equals(150000)); // 10%
      expect(result.rate, equals(0.10));
    });

    test('calculates 5% WHT for construction/contracts', () {
      final result = WhtCalculator.calculate(
        amount: 10000000,
        type: WhtType.construction,
      );

      expect(result.wht, equals(500000)); // 5%
      expect(result.rate, equals(0.05));
    });
  });

  group('WHT Calculator - Calculations', () {
    test('calculates net amount correctly', () {
      final result = WhtCalculator.calculate(
        amount: 1000000,
        type: WhtType.dividends,
      );

      expect(result.netAmount, equals(result.amount - result.wht));
      expect(result.netAmount, equals(900000));
    });

    test('handles minimum amounts', () {
      final result = WhtCalculator.calculate(
        amount: 1,
        type: WhtType.dividends,
      );

      expect(result.amount, equals(1));
      expect(result.wht, closeTo(0.1, 0.01));
    });

    test('handles large amounts', () {
      final result = WhtCalculator.calculate(
        amount: 999999999999,
        type: WhtType.professionalFees,
      );

      expect(result.wht, equals(999999999999 * 0.10));
      expect(result.netAmount, equals(999999999999 * 0.90));
    });
  });

  group('WHT Calculator - Input Validation', () {
    test('throws ArgumentError for negative amount', () {
      expect(
        () => WhtCalculator.calculate(amount: -1000, type: WhtType.dividends),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('WHT Calculator - Edge Cases', () {
    test('result timestamp is valid', () {
      final result = WhtCalculator.calculate(
        amount: 1000000,
        type: WhtType.rent,
      );

      expect(result.calculatedAt, isNotNull);
      expect(
          result.calculatedAt
              .isBefore(DateTime.now().add(Duration(seconds: 1))),
          isTrue);
    });

    test('handles decimal amounts correctly', () {
      final result = WhtCalculator.calculate(
        amount: 1234567.89,
        type: WhtType.professionalFees,
      );

      expect(result.amount, equals(1234567.89));
      expect(result.wht, closeTo(123456.789, 0.01));
    });
  });

  group('WHT Calculator - Serialization', () {
    test('toMap and fromMap preserve all data', () {
      final original = WhtCalculator.calculate(
        amount: 2500000,
        type: WhtType.construction,
      );

      final map = original.toMap();
      final restored = WhtResult.fromMap(map);

      expect(restored.amount, equals(original.amount));
      expect(restored.wht, equals(original.wht));
      expect(restored.netAmount, equals(original.netAmount));
      expect(restored.rate, equals(original.rate));
      expect(restored.type, equals(original.type));
    });

    test('toMap contains all required fields', () {
      final result = WhtCalculator.calculate(
        amount: 1000000,
        type: WhtType.dividends,
      );

      final map = result.toMap();

      expect(map.containsKey('amount'), isTrue);
      expect(map.containsKey('wht'), isTrue);
      expect(map.containsKey('netAmount'), isTrue);
      expect(map.containsKey('rate'), isTrue);
      expect(map.containsKey('type'), isTrue);
      expect(map.containsKey('calculatedAt'), isTrue);
    });
  });
}
