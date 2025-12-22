import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';

/// WHT (Withholding Tax) Type
enum WhtType {
  dividends,
  interest,
  rent,
  royalties,
  directorsFees,
  professionalFees,
  construction,
  contracts,
  other,
}

/// WHT Calculator
///
/// Implements Withholding Tax rates according to 2025 Nigerian Tax rules.
/// Different rates apply to different income types:
/// - Most payments: 10% WHT
/// - Construction/Contracts: 5% WHT (reduced rate)
/// - Other specific rates as applicable
class WhtCalculator {
  /// WHT rates by payment type
  static const Map<WhtType, double> rates = {
    WhtType.dividends: 0.10,
    WhtType.interest: 0.10,
    WhtType.rent: 0.10,
    WhtType.royalties: 0.10,
    WhtType.directorsFees: 0.10,
    WhtType.professionalFees: 0.10,
    WhtType.construction: 0.05,
    WhtType.contracts: 0.05,
    WhtType.other: 0.10,
  };

  /// Standard WHT rates as strings (for storage/reference)
  static const Map<String, double> ratesByString = {
    'dividends_individual': 0.10,
    'dividends_company': 0.10,
    'interest': 0.10,
    'rent': 0.10,
    'royalties': 0.10,
    'directors_fees': 0.10,
    'professional_fees': 0.10,
    'construction': 0.05,
    'contracts': 0.05,
  };

  /// Calculate WHT on a payment
  ///
  /// Parameters:
  /// - [amount]: The gross payment amount
  /// - [type]: The type of WHT (enum)
  ///
  /// Returns: [WhtResult] with WHT calculation details
  ///
  /// Throws [ArgumentError] if inputs are invalid
  static WhtResult calculate({
    required double amount,
    required WhtType type,
  }) {
    // Validate inputs
    TaxValidator.validateWhtInputs(amount, type.toString());

    // Get rate for this type
    final rate = rates[type] ?? 0.10;

    // Calculate WHT
    final wht = amount * rate;
    final netAmount = amount - wht;

    return WhtResult(
      amount: amount,
      type: _getWhtTypeString(type),
      rate: rate,
      wht: wht,
      netAmount: netAmount,
    );
  }

  /// Calculate WHT using string type identifier (for backward compatibility)
  ///
  /// Parameters:
  /// - [amount]: The gross payment amount
  /// - [typeString]: The type of WHT as a string
  ///
  /// Returns: [WhtResult] with WHT calculation details
  static WhtResult calculateFromString({
    required double amount,
    required String typeString,
  }) {
    TaxValidator.validateWhtInputs(amount, typeString);

    final rate = ratesByString[typeString] ?? 0.10;
    final wht = amount * rate;
    final netAmount = amount - wht;

    return WhtResult(
      amount: amount,
      type: typeString,
      rate: rate,
      wht: wht,
      netAmount: netAmount,
    );
  }

  /// Get WHT type from string
  static WhtType? getWhtTypeFromString(String typeString) {
    try {
      return WhtType.values.firstWhere(
        (e) => _getWhtTypeString(e) == typeString,
      );
    } catch (e) {
      return null;
    }
  }

  /// Convert WHT type enum to readable string
  static String _getWhtTypeString(WhtType type) {
    switch (type) {
      case WhtType.dividends:
        return 'Dividends';
      case WhtType.interest:
        return 'Interest';
      case WhtType.rent:
        return 'Rent';
      case WhtType.royalties:
        return 'Royalties';
      case WhtType.directorsFees:
        return 'Directors Fees';
      case WhtType.professionalFees:
        return 'Professional Fees';
      case WhtType.construction:
        return 'Construction';
      case WhtType.contracts:
        return 'Contracts';
      case WhtType.other:
        return 'Other';
    }
  }

  /// Get WHT description for display
  static String getWhtDescription(WhtType type) {
    switch (type) {
      case WhtType.dividends:
        return 'Dividend payments to shareholders';
      case WhtType.interest:
        return 'Interest income from loans/investments';
      case WhtType.rent:
        return 'Rental income from property';
      case WhtType.royalties:
        return 'Royalty payments for intellectual property';
      case WhtType.directorsFees:
        return 'Directors fees and sitting allowances';
      case WhtType.professionalFees:
        return 'Professional service fees (legal, accounting, etc.)';
      case WhtType.construction:
        return 'Construction and installation contracts (reduced rate)';
      case WhtType.contracts:
        return 'Service and supply contracts (reduced rate)';
      case WhtType.other:
        return 'Other taxable payments';
    }
  }

  /// Calculate cumulative WHT for multiple payments
  ///
  /// Useful for annual WHT tracking
  static double calculateCumulativeWht(List<WhtResult> results) {
    return results.fold<double>(0.0, (total, result) => total + result.wht);
  }

  /// Check if payment requires WHT registration
  static bool requiresWhtRegistration(double annualWht) {
    return annualWht >= 100000.0; // Annual WHT ≥ ₦100K
  }
}
