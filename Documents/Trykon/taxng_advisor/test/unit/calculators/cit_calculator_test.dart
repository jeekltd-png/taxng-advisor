import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/cit/data/cit_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';

void main() {
  group('CIT Calculator - Basic Calculations', () {
    test('calculates CIT for small company (turnover < 25M)', () {
      final result = CitCalculator.calculate(
        turnover: 20000000,
        profit: 5000000,
      );

      expect(result.turnover, equals(20000000));
      expect(result.profit, equals(5000000));
      expect(result.taxPayable, equals(0)); // Small company exemption
      expect(result.effectiveRate, equals(0));
    });

    test('calculates CIT for medium company (turnover 25M-100M)', () {
      final result = CitCalculator.calculate(
        turnover: 50000000,
        profit: 10000000,
      );

      expect(result.turnover, equals(50000000));
      expect(result.profit, equals(10000000));
      // Medium company rate calculation
      expect(result.taxPayable, greaterThan(0));
      expect(result.effectiveRate, lessThan(30));
    });

    test('calculates CIT for large company (turnover > 100M)', () {
      final result = CitCalculator.calculate(
        turnover: 150000000,
        profit: 45000000,
      );

      expect(result.turnover, equals(150000000));
      expect(result.profit, equals(45000000));
      expect(result.taxPayable, equals(45000000 * 0.30)); // 30% rate
      expect(result.rate, equals(0.30)); // Rate is decimal
    });

    test('handles zero profit correctly', () {
      final result = CitCalculator.calculate(
        turnover: 100000000,
        profit: 0,
      );

      expect(result.taxPayable, equals(0));
      expect(result.effectiveRate, equals(0));
    });

    test('handles minimum taxable values', () {
      final result = CitCalculator.calculate(
        turnover: 1,
        profit: 1,
      );

      expect(result.turnover, equals(1));
      expect(result.profit, equals(1));
      expect(result.taxPayable, greaterThanOrEqualTo(0));
    });
  });

  group('CIT Calculator - Input Validation', () {
    test('throws ArgumentError for negative turnover', () {
      expect(
        () => CitCalculator.calculate(turnover: -1000, profit: 5000),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for negative profit', () {
      expect(
        () => CitCalculator.calculate(turnover: 50000000, profit: -1000),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when profit exceeds turnover', () {
      expect(
        () => CitCalculator.calculate(turnover: 1000000, profit: 2000000),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CIT Calculator - Edge Cases', () {
    test('handles very large numbers', () {
      final result = CitCalculator.calculate(
        turnover: 999999999999,
        profit: 100000000000,
      );

      expect(result.taxPayable, equals(100000000000 * 0.30));
      expect(result.rate, equals(0.30)); // Large company rate is decimal
    });

    test('handles decimal precision correctly', () {
      final result = CitCalculator.calculate(
        turnover: 100000000.50,
        profit: 30000000.75,
      );

      expect(result.turnover, equals(100000000.50));
      expect(result.profit, equals(30000000.75));
      expect(result.taxPayable, closeTo(9000000.225, 0.01));
    });

    test('result contains valid timestamp', () {
      final result = CitCalculator.calculate(
        turnover: 50000000,
        profit: 10000000,
      );

      expect(result.calculatedAt, isNotNull);
      expect(
          result.calculatedAt
              .isBefore(DateTime.now().add(Duration(seconds: 1))),
          isTrue);
      expect(
          result.calculatedAt
              .isAfter(DateTime.now().subtract(Duration(seconds: 60))),
          isTrue);
    });
  });

  group('CIT Calculator - Serialization', () {
    test('toMap and fromMap preserve data', () {
      final original = CitCalculator.calculate(
        turnover: 75000000,
        profit: 20000000,
      );

      final map = original.toMap();
      final restored = CitResult.fromMap(map);

      expect(restored.turnover, equals(original.turnover));
      expect(restored.profit, equals(original.profit));
      expect(restored.taxPayable, equals(original.taxPayable));
      expect(restored.rate, equals(original.rate));
      expect(restored.calculatedAt.millisecondsSinceEpoch,
          equals(original.calculatedAt.millisecondsSinceEpoch));
    });

    test('toMap contains all required fields', () {
      final result = CitCalculator.calculate(
        turnover: 50000000,
        profit: 10000000,
      );

      final map = result.toMap();

      expect(map.containsKey('turnover'), isTrue);
      expect(map.containsKey('profit'), isTrue);
      expect(map.containsKey('taxPayable'), isTrue);
      expect(map.containsKey('rate'), isTrue);
      expect(map.containsKey('calculatedAt'), isTrue);
    });
  });
}
