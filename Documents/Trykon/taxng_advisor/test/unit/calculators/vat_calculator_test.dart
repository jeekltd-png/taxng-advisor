import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/vat/data/vat_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';

void main() {
  group('VAT Calculator - Standard Supplies', () {
    test('calculates VAT at 7.5% for standard supply', () {
      final supplies = [
        VatSupply(
          description: 'Goods',
          amount: 1000000,
          type: SupplyType.standard,
        ),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 0,
        exemptInputVat: 0,
      );

      expect(result.outputVat, equals(1000000 * 0.075)); // 75,000
      expect(result.vatableSales, equals(1000000));
      expect(result.netPayable, equals(75000));
    });

    test('calculates VAT for multiple standard supplies', () {
      final supplies = [
        VatSupply(
            description: 'Item 1', amount: 500000, type: SupplyType.standard),
        VatSupply(
            description: 'Item 2', amount: 300000, type: SupplyType.standard),
        VatSupply(
            description: 'Item 3', amount: 200000, type: SupplyType.standard),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 0,
        exemptInputVat: 0,
      );

      expect(result.vatableSales, equals(1000000));
      expect(result.outputVat, equals(1000000 * 0.075));
    });
  });

  group('VAT Calculator - Zero-Rated Supplies', () {
    test('calculates zero VAT for zero-rated supply', () {
      final supplies = [
        VatSupply(
          description: 'Exported goods',
          amount: 1000000,
          type: SupplyType.zeroRated,
        ),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 50000,
        exemptInputVat: 0,
      );

      expect(result.outputVat, equals(0));
      expect(result.zeroRatedSales, equals(1000000));
      expect(result.recoverableInput, equals(50000));
      expect(result.netPayable, equals(0)); // No payment due
      expect(result.refundEligible, equals(50000)); // Refund available
    });

    test('allows input VAT recovery on zero-rated supplies', () {
      final supplies = [
        VatSupply(
            description: 'Export', amount: 2000000, type: SupplyType.zeroRated),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 150000,
        exemptInputVat: 0,
      );

      expect(result.recoverableInput, equals(150000));
      expect(result.netPayable, equals(0)); // No payment due
      expect(result.refundEligible, greaterThan(0)); // Has refund
    });
  });

  group('VAT Calculator - Exempt Supplies', () {
    test('calculates no VAT for exempt supply', () {
      final supplies = [
        VatSupply(
          description: 'Medical services',
          amount: 500000,
          type: SupplyType.exempt,
        ),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 0,
        exemptInputVat: 0,
      );

      expect(result.outputVat, equals(0));
      expect(result.exemptSales, equals(500000));
      expect(result.netPayable, equals(0));
    });

    test('does not allow input VAT recovery on exempt supplies', () {
      final supplies = [
        VatSupply(
            description: 'Exempt', amount: 1000000, type: SupplyType.exempt),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 75000,
        exemptInputVat: 75000, // All input VAT is exempt
      );

      expect(result.recoverableInput, equals(0));
      expect(result.netPayable, equals(0));
    });
  });

  group('VAT Calculator - Mixed Supplies', () {
    test('calculates VAT for mixed supply types', () {
      final supplies = [
        VatSupply(
            description: 'Standard',
            amount: 1000000,
            type: SupplyType.standard),
        VatSupply(
            description: 'Zero-rated',
            amount: 500000,
            type: SupplyType.zeroRated),
        VatSupply(
            description: 'Exempt', amount: 300000, type: SupplyType.exempt),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 50000,
        exemptInputVat: 10000,
      );

      expect(result.vatableSales, equals(1000000));
      expect(result.zeroRatedSales, equals(500000));
      expect(result.exemptSales, equals(300000));
      expect(result.outputVat, equals(75000)); // 7.5% of 1M
      expect(result.recoverableInput, equals(40000)); // 50k - 10k exempt
    });
  });

  group('VAT Calculator - Input VAT', () {
    test('deducts recoverable input VAT from payment', () {
      final supplies = [
        VatSupply(
            description: 'Goods', amount: 2000000, type: SupplyType.standard),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 100000,
        exemptInputVat: 0,
      );

      expect(result.outputVat, equals(150000)); // 7.5% of 2M
      expect(result.recoverableInput, equals(100000));
      expect(result.netPayable, equals(50000)); // 150k - 100k
    });

    test('creates refund when input VAT exceeds output VAT', () {
      final supplies = [
        VatSupply(
            description: 'Goods', amount: 1000000, type: SupplyType.standard),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 100000,
        exemptInputVat: 0,
      );

      expect(result.outputVat, equals(75000));
      expect(result.recoverableInput, equals(100000));
      expect(result.netPayable, equals(0));
      expect(result.refundEligible, equals(25000)); // 100k - 75k refund
    });
  });

  group('VAT Calculator - Input Validation', () {
    test('throws ArgumentError for negative supply amount', () {
      expect(
        () => VatCalculator.calculate(
          supplies: [
            VatSupply(
                description: 'Bad', amount: -1000, type: SupplyType.standard),
          ],
          totalInputVat: 0,
          exemptInputVat: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for negative input VAT', () {
      expect(
        () => VatCalculator.calculate(
          supplies: [
            VatSupply(
                description: 'Good', amount: 1000, type: SupplyType.standard),
          ],
          totalInputVat: -500,
          exemptInputVat: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when exempt input VAT exceeds total', () {
      expect(
        () => VatCalculator.calculate(
          supplies: [
            VatSupply(
                description: 'Good', amount: 1000, type: SupplyType.standard),
          ],
          totalInputVat: 100,
          exemptInputVat: 200,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('VAT Calculator - Edge Cases', () {
    test('handles empty supplies list', () {
      final result = VatCalculator.calculate(
        supplies: [],
        totalInputVat: 0,
        exemptInputVat: 0,
      );

      expect(result.outputVat, equals(0));
      expect(result.netPayable, equals(0));
    });

    test('handles very large amounts', () {
      final supplies = [
        VatSupply(
            description: 'Large',
            amount: 999999999999,
            type: SupplyType.standard),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 0,
        exemptInputVat: 0,
      );

      expect(result.outputVat, equals(999999999999 * 0.075));
    });

    test('timestamp is valid', () {
      final supplies = [
        VatSupply(description: 'Test', amount: 1000, type: SupplyType.standard),
      ];

      final result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 0,
        exemptInputVat: 0,
      );

      expect(result.calculatedAt, isNotNull);
      expect(
          result.calculatedAt
              .isBefore(DateTime.now().add(Duration(seconds: 1))),
          isTrue);
    });
  });

  group('VAT Calculator - Serialization', () {
    test('toMap and fromMap preserve all data', () {
      final supplies = [
        VatSupply(description: 'A', amount: 1000000, type: SupplyType.standard),
        VatSupply(description: 'B', amount: 500000, type: SupplyType.zeroRated),
      ];

      final original = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: 50000,
        exemptInputVat: 10000,
      );

      final map = original.toMap();
      final restored = VatResult.fromMap(map);

      expect(restored.outputVat, equals(original.outputVat));
      expect(restored.recoverableInput, equals(original.recoverableInput));
      expect(restored.netPayable, equals(original.netPayable));
      expect(restored.vatableSales, equals(original.vatableSales));
      expect(restored.zeroRatedSales, equals(original.zeroRatedSales));
      expect(restored.exemptSales, equals(original.exemptSales));
    });
  });
}
