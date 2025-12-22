import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';

/// Supply type for VAT calculation
enum SupplyType {
  standard,
  zeroRated,
  exempt,
}

/// Represents a taxable supply for VAT purposes
class VatSupply {
  final double amount;
  final SupplyType type;
  final String? description;

  VatSupply({
    required this.amount,
    required this.type,
    this.description,
  });

  /// Check if supply is standard rated
  bool get isStandardRated => type == SupplyType.standard;

  /// Check if supply is zero rated
  bool get isZeroRated => type == SupplyType.zeroRated;

  /// Check if supply is exempt
  bool get isExempt => type == SupplyType.exempt;
}

/// VAT Calculator
///
/// Implements the 2025 VAT reform in Nigeria:
/// - Standard rate: 7.5%
/// - Zero-rated supplies: 0% (includes goods for export, etc.)
/// - Exempt supplies: 0% (includes financial services, insurance, etc.)
/// - Full input VAT recovery (except for exempt supplies)
class VatCalculator {
  static const double standardRate = 0.075; // 7.5%
  static const double zeroRate = 0.0;
  static const double exemptRate = 0.0;

  /// Calculate VAT liability
  ///
  /// Parameters:
  /// - [supplies]: List of supplies made (standard, zero-rated, exempt)
  /// - [totalInputVat]: Total VAT paid on purchases/inputs
  /// - [exemptInputVat]: VAT on inputs attributable to exempt supplies (not recoverable)
  ///
  /// Returns: [VatResult] with detailed VAT calculation
  ///
  /// Throws [ArgumentError] if inputs are invalid
  static VatResult calculate({
    required List<VatSupply> supplies,
    required double totalInputVat,
    required double exemptInputVat,
  }) {
    // Validate inputs
    TaxValidator.validateVatInputs(totalInputVat, exemptInputVat);
    if (exemptInputVat > totalInputVat) {
      throw ArgumentError('Exempt input VAT cannot exceed total input VAT');
    }

    // Process supplies
    double outputVat = 0.0;
    double vatableSales = 0.0;
    double zeroRatedSales = 0.0;
    double exemptSales = 0.0;

    for (final supply in supplies) {
      TaxValidator.validateTaxAmount(supply.amount, 'Supply amount');

      switch (supply.type) {
        case SupplyType.standard:
          outputVat += supply.amount * standardRate;
          vatableSales += supply.amount;
          break;
        case SupplyType.zeroRated:
          zeroRatedSales += supply.amount;
          break;
        case SupplyType.exempt:
          exemptSales += supply.amount;
          break;
      }
    }

    // Calculate recoverable input VAT
    final recoverableInput = totalInputVat - exemptInputVat;

    // Calculate net VAT payable or refund eligible
    final netPayable = outputVat - recoverableInput;

    return VatResult(
      vatableSales: vatableSales,
      zeroRatedSales: zeroRatedSales,
      exemptSales: exemptSales,
      outputVat: outputVat,
      recoverableInput: recoverableInput,
      netPayable: netPayable > 0 ? netPayable : 0.0,
      refundEligible: netPayable < 0 ? -netPayable : 0.0,
    );
  }

  /// Calculate output VAT on a standard-rated supply
  ///
  /// Convenience method for single supply calculations
  static double calculateOutputVat(double amount) {
    TaxValidator.validateTaxAmount(amount, 'Supply amount');
    return amount * standardRate;
  }

  /// Determine if a business qualifies for VAT registration
  ///
  /// Generally, businesses with turnover above ₦25M must register
  static bool shouldRegisterForVat(double annualTurnover) {
    return annualTurnover >= 25000000.0;
  }

  /// Calculate effective VAT rate considering input recovery
  ///
  /// Returns the net VAT as percentage of total sales
  static double calculateEffectiveRate(
    double totalOutputVat,
    double totalSales,
    double netVatPayable,
  ) {
    if (totalSales <= 0) return 0.0;
    return netVatPayable / totalSales;
  }
}
