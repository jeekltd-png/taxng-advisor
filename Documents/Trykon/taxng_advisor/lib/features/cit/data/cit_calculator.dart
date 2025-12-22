import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';

/// CIT (Corporate Income Tax) Calculator
///
/// Implements tiered rates based on turnover according to 2025 Nigerian Tax rules:
/// - Small enterprises (< ₦25M): 0% tax
/// - Medium enterprises (₦25M - ₦100M): 20% tax
/// - Large enterprises (> ₦100M): 30% tax
class CitCalculator {
  static const double smallLimit = 25000000.0;
  static const double mediumLimit = 100000000.0;

  static const double smallRate = 0.0;
  static const double mediumRate = 0.20;
  static const double largeRate = 0.30;

  /// Calculates CIT based on turnover and profit
  ///
  /// Parameters:
  /// - [turnover]: Total business turnover/revenue
  /// - [profit]: Chargeable profit before tax
  ///
  /// Returns: [CitResult] with complete tax calculation details
  ///
  /// Throws [ArgumentError] if inputs are invalid
  static CitResult calculate({
    required double turnover,
    required double profit,
  }) {
    // Validate inputs
    TaxValidator.validateCitInputs(turnover, profit);

    // Determine tax rate based on turnover tier
    final rate = _getTaxRate(turnover);

    // Determine category based on rate
    final category = _getCategory(rate);

    // Calculate tax payable
    final tax = profit * rate;

    return CitResult(
      turnover: turnover,
      profit: profit,
      category: category,
      rate: rate,
      taxPayable: tax,
    );
  }

  /// Determines the applicable tax rate based on turnover
  ///
  /// Returns the tax rate (0.0, 0.20, or 0.30)
  static double _getTaxRate(double turnover) {
    if (turnover < smallLimit) {
      return smallRate;
    } else if (turnover <= mediumLimit) {
      return mediumRate;
    } else {
      return largeRate;
    }
  }

  /// Gets the category description based on tax rate
  ///
  /// Returns a user-friendly category string
  static String _getCategory(double rate) {
    switch (rate) {
      case smallRate:
        return 'Small (0%)';
      case mediumRate:
        return 'Medium (20%)';
      case largeRate:
        return 'Large (30%)';
      default:
        return 'Unknown';
    }
  }

  /// Gets the turnover tier name
  static String getTierName(double turnover) {
    if (turnover < smallLimit) {
      return 'Small Enterprise';
    } else if (turnover <= mediumLimit) {
      return 'Medium Enterprise';
    } else {
      return 'Large Enterprise';
    }
  }
}
