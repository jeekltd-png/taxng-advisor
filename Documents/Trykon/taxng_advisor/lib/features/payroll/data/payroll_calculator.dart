import 'package:taxng_advisor/features/pit/data/pit_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';

/// Payroll Calculator
///
/// Calculates PAYE (Pay As You Earn) tax using annual PIT rates
/// and provides comprehensive payroll information.
///
/// Features:
/// - Monthly PAYE calculation from annual PIT rates
/// - Support for pension contributions
/// - Social security deductions
/// - Other salary deductions
class PayrollCalculator {
  /// Standard pension contribution rate (8%)
  static const double pensionContributionRate = 0.08;

  /// National Housing Fund contribution rate (2%)
  static const double nhfContributionRate = 0.02;

  /// Calculate monthly PAYE tax using annual PIT rates
  ///
  /// Parameters:
  /// - [monthlyGross]: Monthly gross salary
  /// - [annualDeductions]: Annual deductions (other than pension)
  /// - [monthlyPensionContribution]: Monthly pension contribution (if any)
  ///
  /// Returns: [PayrollResult] with monthly and annual payroll details
  ///
  /// Throws [ArgumentError] if inputs are invalid
  static PayrollResult calculateMonthlyPaye({
    required double monthlyGross,
    List<double> annualDeductions = const [],
    double monthlyPensionContribution = 0.0,
  }) {
    // Validate inputs
    TaxValidator.validateTaxAmount(monthlyGross, 'Monthly Gross Salary');
    TaxValidator.validateTaxAmount(
      monthlyPensionContribution,
      'Monthly Pension Contribution',
    );

    // Calculate annual figures
    final annualGross = monthlyGross * 12;

    // Calculate PIT on annual income
    final pitResult = PitCalculator.calculate(
      grossIncome: annualGross,
      otherDeductions: annualDeductions,
      annualRentPaid: 0.0, // Rent relief handled separately in payroll context
    );

    // Monthly PAYE
    final monthlyPaye = pitResult.totalTax / 12;

    // Calculate net pay
    final monthlyNet = monthlyGross - monthlyPaye - monthlyPensionContribution;
    final annualNet =
        monthlyNet * 12; // Simplified; consider monthly variations

    return PayrollResult(
      monthlyGross: monthlyGross,
      annualGross: annualGross,
      monthlyPaye: monthlyPaye,
      annualPaye: pitResult.totalTax,
      monthlyNet: monthlyNet,
      annualNet: annualNet,
    );
  }

  /// Calculate payroll with comprehensive deductions
  ///
  /// Parameters:
  /// - [monthlyGross]: Monthly gross salary
  /// - [pensionRate]: Pension contribution rate (default 8%)
  /// - [nhfRate]: NHF contribution rate (default 2%)
  /// - [otherDeductions]: Other deductions (insurance, loans, etc.)
  /// - [annualOtherDeductions]: Annual deductions for PIT calculation
  ///
  /// Returns: [PayrollResult] with full payroll breakdown
  static PayrollResult calculateWithDeductions({
    required double monthlyGross,
    double pensionRate = pensionContributionRate,
    double nhfRate = nhfContributionRate,
    double otherDeductions = 0.0,
    List<double> annualOtherDeductions = const [],
  }) {
    // Validate inputs
    TaxValidator.validateTaxAmount(monthlyGross, 'Monthly Gross Salary');
    TaxValidator.validateTaxAmount(otherDeductions, 'Other Monthly Deductions');
    TaxValidator.validatePercentage(pensionRate, 'Pension Rate');
    TaxValidator.validatePercentage(nhfRate, 'NHF Rate');

    // Calculate pension and NHF
    final monthlyPension = monthlyGross * pensionRate;
    final monthlyNhf = monthlyGross * nhfRate;
    final totalMonthlyDeductions =
        monthlyPension + monthlyNhf + otherDeductions;

    // Calculate PAYE using annual figures
    final annualGross = monthlyGross * 12;
    final annualPension = monthlyPension * 12;

    // Combine annual deductions
    final allAnnualDeductions = [
      ...annualOtherDeductions,
      annualPension, // Pension is deductible from taxable income
    ];

    // Calculate PIT
    final pitResult = PitCalculator.calculate(
      grossIncome: annualGross,
      otherDeductions: allAnnualDeductions,
      annualRentPaid: 0.0,
    );

    final monthlyPaye = pitResult.totalTax / 12;
    final monthlyNet = monthlyGross - monthlyPaye - totalMonthlyDeductions;
    final annualNet = monthlyNet * 12;

    return PayrollResult(
      monthlyGross: monthlyGross,
      annualGross: annualGross,
      monthlyPaye: monthlyPaye,
      annualPaye: pitResult.totalTax,
      monthlyNet: monthlyNet,
      annualNet: annualNet,
    );
  }

  /// Calculate default pension contribution
  ///
  /// Standard rate: 8% of gross salary
  static double calculateDefaultPension(double grossSalary) {
    TaxValidator.validateTaxAmount(grossSalary, 'Gross Salary');
    return grossSalary * pensionContributionRate;
  }

  /// Calculate NHF contribution
  ///
  /// Standard rate: 2% of gross salary
  static double calculateNhf(double grossSalary) {
    TaxValidator.validateTaxAmount(grossSalary, 'Gross Salary');
    return grossSalary * nhfContributionRate;
  }

  /// Calculate total statutory deductions
  ///
  /// Includes PAYE, Pension, and NHF
  static double calculateTotalStatutoryDeductions({
    required double monthlyGross,
    required double monthlyPaye,
    double pensionRate = pensionContributionRate,
    double nhfRate = nhfContributionRate,
  }) {
    final pension = monthlyGross * pensionRate;
    final nhf = monthlyGross * nhfRate;
    return monthlyPaye + pension + nhf;
  }

  /// Determine if employee qualifies for tax relief
  ///
  /// Generally, employees with annual income below ₦800K may get relief
  static bool qualifiesForTaxRelief(double annualGrossIncome) {
    return annualGrossIncome <= 800000.0;
  }

  /// Calculate take-home pay
  static double calculateTakeHome({
    required double monthlyGross,
    required double monthlyPaye,
    double pensionRate = pensionContributionRate,
    double nhfRate = nhfContributionRate,
    double otherDeductions = 0.0,
  }) {
    final pension = monthlyGross * pensionRate;
    final nhf = monthlyGross * nhfRate;
    return monthlyGross - monthlyPaye - pension - nhf - otherDeductions;
  }
}
