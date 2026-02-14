import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/stamp_duty/data/stamp_duty_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';

void main() {
  group('Stamp Duty Calculator - Fixed Rates', () {
    test('calculates ₦20 duty for cheque', () {
      final result = StampDutyCalculator.calculate(
        amount: 100000,
        type: StampDutyType.cheque,
      );

      expect(result.duty, equals(20.0));
      expect(result.amount, equals(100000));
    });

    test('calculates ₦100 duty for affidavit', () {
      final result = StampDutyCalculator.calculate(
        amount: 50000,
        type: StampDutyType.affidavit,
      );

      expect(result.duty, equals(100.0));
    });

    test('fixed rates do not depend on amount', () {
      final result1 = StampDutyCalculator.calculate(
        amount: 1000,
        type: StampDutyType.cheque,
      );

      final result2 = StampDutyCalculator.calculate(
        amount: 1000000,
        type: StampDutyType.cheque,
      );

      expect(result1.duty, equals(result2.duty));
      expect(result1.duty, equals(20.0));
    });
  });

  group('Stamp Duty Calculator - Electronic Transfer', () {
    test('calculates 0.15% duty on electronic transfer', () {
      final result = StampDutyCalculator.calculate(
        amount: 100000,
        type: StampDutyType.electronicTransfer,
      );

      expect(result.duty, equals(150.0)); // 0.15% of 100,000
    });

    test('no duty on electronic transfer below ₦10,000', () {
      final result = StampDutyCalculator.calculate(
        amount: 9000,
        type: StampDutyType.electronicTransfer,
      );

      expect(result.duty, equals(0.0));
    });

    test('applies duty on electronic transfer at ₦10,000', () {
      final result = StampDutyCalculator.calculate(
        amount: 10001,
        type: StampDutyType.electronicTransfer,
      );

      expect(result.duty, greaterThan(0.0));
      expect(result.duty, equals(10001 * 0.0015));
    });

    test('calculates duty on large electronic transfer', () {
      final result = StampDutyCalculator.calculate(
        amount: 50000000,
        type: StampDutyType.electronicTransfer,
      );

      expect(result.duty, equals(75000.0)); // 0.15% of 50M
    });
  });

  group('Stamp Duty Calculator - Percentage Rates', () {
    test('calculates 0.5% duty on agreement', () {
      final result = StampDutyCalculator.calculate(
        amount: 1000000,
        type: StampDutyType.agreement,
      );

      expect(result.duty, equals(5000.0)); // 0.5% of 1M
    });

    test('calculates 0.5% duty on mortgage', () {
      final result = StampDutyCalculator.calculate(
        amount: 10000000,
        type: StampDutyType.mortgage,
      );

      expect(result.duty, equals(50000.0)); // 0.5% of 10M
    });

    test('calculates 0.5% duty on sale', () {
      final result = StampDutyCalculator.calculate(
        amount: 5000000,
        type: StampDutyType.sale,
      );

      expect(result.duty, equals(25000.0)); // 0.5% of 5M
    });

    test('calculates 1% duty on lease', () {
      final result = StampDutyCalculator.calculate(
        amount: 2000000,
        type: StampDutyType.lease,
      );

      expect(result.duty, equals(20000.0)); // 1% of 2M
    });

    test('calculates 0.1% duty on power of attorney', () {
      final result = StampDutyCalculator.calculate(
        amount: 1000000,
        type: StampDutyType.powerOfAttorney,
      );

      expect(result.duty, equals(1000.0)); // 0.1% of 1M
    });
  });

  group('Stamp Duty Calculator - All Transaction Types', () {
    test('handles all 9 transaction types', () {
      final types = [
        StampDutyType.electronicTransfer,
        StampDutyType.cheque,
        StampDutyType.agreement,
        StampDutyType.lease,
        StampDutyType.mortgage,
        StampDutyType.sale,
        StampDutyType.powerOfAttorney,
        StampDutyType.affidavit,
        StampDutyType.other,
      ];

      for (final type in types) {
        final result = StampDutyCalculator.calculate(
          amount: 100000,
          type: type,
        );

        expect(result.duty, greaterThanOrEqualTo(0.0));
        expect(result.amount, equals(100000));
      }
    });

    test('other type uses default 0.5% rate', () {
      final result = StampDutyCalculator.calculate(
        amount: 1000000,
        type: StampDutyType.other,
      );

      expect(result.duty, equals(5000.0)); // 0.5%
    });
  });

  group('Stamp Duty Calculator - Input Validation', () {
    test('throws ArgumentError for negative amount', () {
      expect(
        () => StampDutyCalculator.calculate(
          amount: -1000,
          type: StampDutyType.cheque,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles zero amount', () {
      final result = StampDutyCalculator.calculate(
        amount: 0,
        type: StampDutyType.agreement,
      );

      expect(result.duty, equals(0.0));
      expect(result.amount, equals(0.0));
    });
  });

  group('Stamp Duty Calculator - Edge Cases', () {
    test('handles minimum values', () {
      final result = StampDutyCalculator.calculate(
        amount: 1,
        type: StampDutyType.agreement,
      );

      expect(result.amount, equals(1));
      expect(result.duty, closeTo(0.005, 0.001));
    });

    test('handles very large amounts', () {
      final result = StampDutyCalculator.calculate(
        amount: 999999999999,
        type: StampDutyType.sale,
      );

      expect(result.duty, equals(999999999999 * 0.005));
    });

    test('handles decimal amounts', () {
      final result = StampDutyCalculator.calculate(
        amount: 1234567.89,
        type: StampDutyType.mortgage,
      );

      expect(result.amount, equals(1234567.89));
      expect(result.duty, closeTo(6172.83945, 0.01));
    });

    test('result has valid timestamp', () {
      final result = StampDutyCalculator.calculate(
        amount: 100000,
        type: StampDutyType.agreement,
      );

      expect(result.calculatedAt, isNotNull);
      expect(
        result.calculatedAt.isBefore(DateTime.now().add(Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  group('Stamp Duty Calculator - Net Amount', () {
    test('calculates net amount correctly for percentage duty', () {
      final result = StampDutyCalculator.calculate(
        amount: 1000000,
        type: StampDutyType.agreement,
      );

      expect(result.netAmount, equals(995000.0)); // 1M - 5k
    });

    test('calculates net amount correctly for fixed duty', () {
      final result = StampDutyCalculator.calculate(
        amount: 100000,
        type: StampDutyType.cheque,
      );

      expect(result.netAmount, equals(99980.0)); // 100k - 20
    });
  });

  group('Stamp Duty Calculator - Serialization', () {
    test('toMap and fromMap preserve all data', () {
      final original = StampDutyCalculator.calculate(
        amount: 5000000,
        type: StampDutyType.mortgage,
      );

      final map = original.toMap();
      final restored = StampDutyResult.fromMap(map);

      expect(restored.amount, equals(original.amount));
      expect(restored.duty, equals(original.duty));
      expect(restored.type, equals(original.type));
    });

    test('toMap contains all required fields', () {
      final result = StampDutyCalculator.calculate(
        amount: 1000000,
        type: StampDutyType.sale,
      );

      final map = result.toMap();

      expect(map.containsKey('amount'), isTrue);
      expect(map.containsKey('duty'), isTrue);
      expect(map.containsKey('type'), isTrue);
      expect(map.containsKey('calculatedAt'), isTrue);
    });
  });

  group('Stamp Duty Calculator - Bulk Calculations', () {
    test('calculates total stamp duty for multiple transactions', () {
      final results = [
        StampDutyCalculator.calculate(
          amount: 1000000,
          type: StampDutyType.agreement,
        ),
        StampDutyCalculator.calculate(
          amount: 500000,
          type: StampDutyType.sale,
        ),
        StampDutyCalculator.calculate(
          amount: 100000,
          type: StampDutyType.cheque,
        ),
      ];

      final total = StampDutyCalculator.calculateTotalStampDuty(results);

      expect(total, equals(5000.0 + 2500.0 + 20.0)); // 7,520
    });

    test('determines registration requirement', () {
      expect(StampDutyCalculator.requiresRegistration(50000), isFalse);
      expect(StampDutyCalculator.requiresRegistration(100000), isTrue);
      expect(StampDutyCalculator.requiresRegistration(200000), isTrue);
    });
  });

  group('Stamp Duty Calculator - Type Conversion', () {
    test('converts enum to readable string', () {
      final result = StampDutyCalculator.calculate(
        amount: 100000,
        type: StampDutyType.electronicTransfer,
      );

      expect(result.type, equals('Electronic Transfer'));
    });

    test('calculateFromString works with string type', () {
      final result = StampDutyCalculator.calculateFromString(
        amount: 1000000,
        typeString: 'Agreement',
      );

      expect(result.duty, equals(5000.0));
      expect(result.type, equals('Agreement'));
    });

    test('getDescription provides detailed information', () {
      final description =
          StampDutyCalculator.getDescription(StampDutyType.electronicTransfer);

      expect(description, contains('0.15%'));
      expect(description, contains('₦10,000'));
    });
  });

  group('Stamp Duty Calculator - Rate Verification', () {
    test('electronic transfer rate is 0.15%', () {
      final result = StampDutyCalculator.calculate(
        amount: 1000000, // Above minimum
        type: StampDutyType.electronicTransfer,
      );

      expect(result.duty / result.amount, equals(0.0015));
    });

    test('agreement/mortgage/sale rate is 0.5%', () {
      final types = [
        StampDutyType.agreement,
        StampDutyType.mortgage,
        StampDutyType.sale,
      ];

      for (final type in types) {
        final result = StampDutyCalculator.calculate(
          amount: 1000000,
          type: type,
        );

        expect(result.duty / result.amount, equals(0.005));
      }
    });

    test('lease rate is 1%', () {
      final result = StampDutyCalculator.calculate(
        amount: 1000000,
        type: StampDutyType.lease,
      );

      expect(result.duty / result.amount, equals(0.01));
    });

    test('power of attorney rate is 0.1%', () {
      final result = StampDutyCalculator.calculate(
        amount: 1000000,
        type: StampDutyType.powerOfAttorney,
      );

      expect(result.duty / result.amount, equals(0.001));
    });
  });
}
