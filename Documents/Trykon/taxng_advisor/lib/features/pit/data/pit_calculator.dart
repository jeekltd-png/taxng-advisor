import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';

/// PIT (Personal Income Tax) Calculator
///
/// Implements progressive tax bands according to Nigeria Tax Act 2025:
/// - ₦0 - ₦800K: 0%
/// - ₦800K - ₦3M: 15%
/// - ₦3M - ₦12M: 18%
/// - ₦12M - ₦25M: 21%
/// - ₦25M - ₦50M: 23%
/// - Above ₦50M: 25%
///
/// Features:
/// - Rent relief (max ₦500K): 20% of annual rent paid
/// - Supports multiple deductions
/// - Detailed breakdown by tax band
class PitCalculator {
  /// Tax bands with upper limits and rates
  static final List<Map<String, dynamic>> bands = [
    {'upper': 800000.0, 'rate': 0.00, 'label': 'First ₦800K'},
    {'upper': 3000000.0, 'rate': 0.15, 'label': '₦800K - ₦3M'},
    {'upper': 12000000.0, 'rate': 0.18, 'label': '₦3M - ₦12M'},
    {'upper': 25000000.0, 'rate': 0.21, 'label': '₦12M - ₦25M'},
    {'upper': 50000000.0, 'rate': 0.23, 'label': '₦25M - ₦50M'},
    {'upper': double.infinity, 'rate': 0.25, 'label': 'Above ₦50M'},
  ];

  static const double maxRentRelief = 500000.0;
  static const double rentReliefRate = 0.20; // 20% of rent paid

  /// Calculate PIT on chargeable income
  ///
  /// Parameters:
  /// - [grossIncome]: Total annual gross income
  /// - [otherDeductions]: List of other deductible amounts (pensions, etc.)
  /// - [annualRentPaid]: Annual rent paid (used for rent relief calculation)
  ///
  /// Returns: [PitResult] with detailed tax calculation and band breakdown
  ///
  /// Throws [ArgumentError] if inputs are invalid
  static PitResult calculate({
    required double grossIncome,
    required List<double> otherDeductions,
    required double annualRentPaid,
  }) {
    // Validate inputs
    TaxValidator.validatePitInputs(
        grossIncome, otherDeductions, annualRentPaid);

    // Calculate deductions
    final totalDeductions = otherDeductions.fold<double>(0.0, (a, b) => a + b);
    final rentRelief = _calculateRentRelief(annualRentPaid);
    final chargeableIncome = grossIncome - totalDeductions - rentRelief;

    // Handle zero or negative chargeable income
    if (chargeableIncome <= 0) {
      return PitResult(
        grossIncome: grossIncome,
        otherDeductions: otherDeductions,
        annualRentPaid: annualRentPaid,
        totalDeductions: totalDeductions,
        rentRelief: rentRelief,
        chargeableIncome: 0.0,
        totalTax: 0.0,
        breakdown: {},
      );
    }

    // Calculate tax by bands
    final (tax, breakdown) = _calculateTaxByBands(chargeableIncome);

    return PitResult(
      grossIncome: grossIncome,
      otherDeductions: otherDeductions,
      annualRentPaid: annualRentPaid,
      totalDeductions: totalDeductions,
      rentRelief: rentRelief,
      chargeableIncome: chargeableIncome,
      totalTax: tax,
      breakdown: breakdown,
    );
  }

  /// Calculates rent relief (20% of rent, capped at ₦500K)
  static double _calculateRentRelief(double annualRentPaid) {
    final relief = annualRentPaid * rentReliefRate;
    return relief.clamp(0.0, maxRentRelief);
  }

  /// Calculates tax using progressive bands
  ///
  /// Returns: Tuple of (totalTax, breakdown map)
  static (double, Map<String, double>) _calculateTaxByBands(
    double chargeableIncome,
  ) {
    double totalTax = 0.0;
    double previousLimit = 0.0;
    final Map<String, double> breakdown = {};

    for (final band in bands) {
      final upperLimit = band['upper'] as double;
      final rate = band['rate'] as double;

      // Calculate taxable amount in this band
      final taxableInThisBand = (chargeableIncome - previousLimit)
          .clamp(0.0, upperLimit - previousLimit);

      if (taxableInThisBand <= 0) break;

      final bandTax = taxableInThisBand * rate;
      totalTax += bandTax;

      // Create label for breakdown
      final label = _getBandLabel(band, previousLimit, upperLimit);
      breakdown[label] = bandTax;

      previousLimit = upperLimit;
    }

    return (totalTax, breakdown);
  }

  /// Generates a readable label for a tax band
  static String _getBandLabel(
    Map<String, dynamic> band,
    double previousLimit,
    double upperLimit,
  ) {
    final rate = band['rate'] as double;
    final ratePercent = (rate * 100).toInt();

    if (previousLimit == 0.0) {
      return 'First ₦800K @ $ratePercent%';
    } else if (upperLimit == double.infinity) {
      return 'Above ₦50M @ $ratePercent%';
    } else {
      final rangeM =
          ((upperLimit - previousLimit) / 1000000).toStringAsFixed(1);
      return 'Next ₦${rangeM}M @ $ratePercent%';
    }
  }
}
