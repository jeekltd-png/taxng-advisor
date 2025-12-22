import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';

/// Stamp Duty Type
enum StampDutyType {
  electronicTransfer,
  cheque,
  agreement,
  lease,
  mortgage,
  sale,
  powerOfAttorney,
  affidavit,
  other,
}

/// Stamp Duty Calculator
///
/// Implements Nigerian Stamp Duty rules on various transactions:
/// - Electronic transfers: 0.15% (₦10,000+)
/// - Cheques: Flat ₦20
/// - Agreements: Variable based on consideration
/// - Leases: Based on annual rent
/// - Mortgages: Based on loan amount
class StampDutyCalculator {
  /// Electronic transfer rate (0.15%)
  static const double electronicTransferRate = 0.0015;

  /// Minimum amount for electronic transfer duty
  static const double electronicTransferMinimum = 10000.0;

  /// Flat rate for cheques
  static const double chequeRate = 20.0;

  /// Stamp duty rates by transaction type
  static const Map<StampDutyType, double> rates = {
    StampDutyType.electronicTransfer: electronicTransferRate,
    StampDutyType.cheque: 20.0, // Fixed amount
    StampDutyType.agreement: 0.005, // 0.5%
    StampDutyType.lease: 0.01, // 1% of annual rent
    StampDutyType.mortgage: 0.005, // 0.5% of loan
    StampDutyType.sale: 0.005, // 0.5% of sale price
    StampDutyType.powerOfAttorney: 0.001, // 0.1%
    StampDutyType.affidavit: 100.0, // Fixed ₦100
    StampDutyType.other: 0.005, // Default 0.5%
  };

  /// Calculate stamp duty on a transaction
  ///
  /// Parameters:
  /// - [amount]: The transaction amount
  /// - [type]: The type of transaction
  ///
  /// Returns: [StampDutyResult] with stamp duty calculation
  ///
  /// Throws [ArgumentError] if inputs are invalid
  static StampDutyResult calculate({
    required double amount,
    required StampDutyType type,
  }) {
    TaxValidator.validateStampDutyInputs(amount, type.toString());

    final duty = _calculateDuty(amount, type);

    return StampDutyResult(
      amount: amount,
      type: _getStampDutyTypeString(type),
      duty: duty,
    );
  }

  /// Calculate stamp duty using string type identifier
  ///
  /// For backward compatibility with existing code
  static StampDutyResult calculateFromString({
    required double amount,
    required String typeString,
  }) {
    TaxValidator.validateStampDutyInputs(amount, typeString);

    late StampDutyType type;
    try {
      type = StampDutyType.values.firstWhere(
        (e) => _getStampDutyTypeString(e) == typeString,
      );
    } catch (e) {
      type = StampDutyType.other;
    }

    final duty = _calculateDuty(amount, type);

    return StampDutyResult(
      amount: amount,
      type: typeString,
      duty: duty,
    );
  }

  /// Internal method to calculate duty amount
  static double _calculateDuty(double amount, StampDutyType type) {
    switch (type) {
      case StampDutyType.electronicTransfer:
        // Electronic transfer: 0.15% on amounts > ₦10,000
        return amount > electronicTransferMinimum
            ? amount * electronicTransferRate
            : 0.0;

      case StampDutyType.cheque:
        // Flat ₦20 per cheque
        return chequeRate;

      case StampDutyType.affidavit:
        // Flat ₦100 per affidavit
        return 100.0;

      case StampDutyType.agreement:
      case StampDutyType.mortgage:
      case StampDutyType.sale:
        // 0.5% of amount
        return amount * 0.005;

      case StampDutyType.lease:
        // 1% of annual rent
        return amount * 0.01;

      case StampDutyType.powerOfAttorney:
        // 0.1% of amount
        return amount * 0.001;

      case StampDutyType.other:
        // Default 0.5%
        return amount * 0.005;
    }
  }

  /// Convert stamp duty type enum to readable string
  static String _getStampDutyTypeString(StampDutyType type) {
    switch (type) {
      case StampDutyType.electronicTransfer:
        return 'Electronic Transfer';
      case StampDutyType.cheque:
        return 'Cheque';
      case StampDutyType.agreement:
        return 'Agreement';
      case StampDutyType.lease:
        return 'Lease';
      case StampDutyType.mortgage:
        return 'Mortgage';
      case StampDutyType.sale:
        return 'Sale';
      case StampDutyType.powerOfAttorney:
        return 'Power of Attorney';
      case StampDutyType.affidavit:
        return 'Affidavit';
      case StampDutyType.other:
        return 'Other';
    }
  }

  /// Get stamp duty description
  static String getDescription(StampDutyType type) {
    switch (type) {
      case StampDutyType.electronicTransfer:
        return 'Electronic bank transfers (0.15%, min ₦10,000)';
      case StampDutyType.cheque:
        return 'Cheque deposits (flat ₦20)';
      case StampDutyType.agreement:
        return 'Business agreements and contracts (0.5%)';
      case StampDutyType.lease:
        return 'Lease agreements (1% of annual rent)';
      case StampDutyType.mortgage:
        return 'Mortgage/loan documents (0.5%)';
      case StampDutyType.sale:
        return 'Sale of goods/property (0.5%)';
      case StampDutyType.powerOfAttorney:
        return 'Power of attorney documents (0.1%)';
      case StampDutyType.affidavit:
        return 'Affidavit documents (flat ₦100)';
      case StampDutyType.other:
        return 'Other transactions (0.5%)';
    }
  }

  /// Get stamp duty type from string
  static StampDutyType? getStampDutyTypeFromString(String typeString) {
    try {
      return StampDutyType.values.firstWhere(
        (e) => _getStampDutyTypeString(e) == typeString,
      );
    } catch (e) {
      return null;
    }
  }

  /// Calculate total stamp duty for multiple transactions
  static double calculateTotalStampDuty(List<StampDutyResult> results) {
    return results.fold<double>(0.0, (total, result) => total + result.duty);
  }

  /// Check if transaction requires stamp duty registration
  static bool requiresRegistration(double totalAnnualDuty) {
    return totalAnnualDuty >= 100000.0; // Annual stamp duty ≥ ₦100K
  }
}
