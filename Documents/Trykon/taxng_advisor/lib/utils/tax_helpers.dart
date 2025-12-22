/// Validator for tax input values
class TaxValidator {
  /// Validates positive amount
  static bool isPositiveAmount(double value) => value > 0;

  /// Validates non-negative amount
  static bool isNonNegativeAmount(double value) => value >= 0;

  /// Validates turnover is greater than or equal to profit
  static bool isTurnoverGreaterThanProfit(double turnover, double profit) =>
      turnover >= profit && profit >= 0;

  /// Validates percentage (0-100)
  static bool isValidPercentage(double value) => value >= 0 && value <= 100;

  /// Validates percentage and throws exception
  static void validatePercentage(double value, String fieldName) {
    if (!isValidPercentage(value)) {
      throw ArgumentError(
        '$fieldName must be between 0 and 100, got $value',
      );
    }
  }

  /// Throws exception if validation fails
  static void validateTaxAmount(double amount, String fieldName) {
    if (!isNonNegativeAmount(amount)) {
      throw ArgumentError('$fieldName must be non-negative');
    }
  }

  /// Validates CIT inputs
  static void validateCitInputs(double turnover, double profit) {
    validateTaxAmount(turnover, 'Turnover');
    validateTaxAmount(profit, 'Profit');
    if (!isTurnoverGreaterThanProfit(turnover, profit)) {
      throw ArgumentError('Turnover must be greater than or equal to Profit');
    }
  }

  /// Validates PIT inputs
  static void validatePitInputs(
    double grossIncome,
    List<double> deductions,
    double rentPaid,
  ) {
    validateTaxAmount(grossIncome, 'Gross Income');
    for (var i = 0; i < deductions.length; i++) {
      validateTaxAmount(deductions[i], 'Deduction $i');
    }
    validateTaxAmount(rentPaid, 'Annual Rent Paid');
  }

  /// Validates VAT inputs
  static void validateVatInputs(double outputVat, double inputVat) {
    validateTaxAmount(outputVat, 'Output VAT');
    validateTaxAmount(inputVat, 'Input VAT');
  }

  /// Validates WHT inputs
  static void validateWhtInputs(double amount, String type) {
    validateTaxAmount(amount, 'Amount');
    if (type.isEmpty) {
      throw ArgumentError('WHT type must not be empty');
    }
  }

  /// Validates Stamp Duty inputs
  static void validateStampDutyInputs(double amount, String type) {
    validateTaxAmount(amount, 'Amount');
    if (type.isEmpty) {
      throw ArgumentError('Stamp Duty type must not be empty');
    }
  }
}

/// Currency formatting helper
class CurrencyFormatter {
  static const String currencySymbol = '₦';
  static const String usdSymbol = '\$';
  static const String poundSymbol = '£';

  // Exchange rates (these should be updated periodically from API)
  // Using approximate rates as of December 2025
  static const double nairaToUsdRate = 0.00065; // 1 NGN = ~0.00065 USD
  static const double poundToUsdRate = 1.27; // 1 GBP = ~1.27 USD

  /// Formats amount as currency
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '$currencySymbol${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '$currencySymbol${(amount / 1000).toStringAsFixed(2)}K';
    }
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  /// Formats amount without symbol
  static String formatNumber(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Formats as percentage
  static String formatPercentage(double rate) {
    return '${(rate * 100).toStringAsFixed(2)}%';
  }

  /// Converts Naira to USD
  static double convertNairaToUsd(double nairaAmount) {
    return nairaAmount * nairaToUsdRate;
  }

  /// Converts Pounds to USD
  static double convertPoundsToUsd(double poundAmount) {
    return poundAmount * poundToUsdRate;
  }

  /// Formats Naira to USD currency
  static String formatNairaToUsd(double nairaAmount) {
    final usdAmount = convertNairaToUsd(nairaAmount);
    if (usdAmount >= 1000000) {
      return '$usdSymbol${(usdAmount / 1000000).toStringAsFixed(2)}M';
    } else if (usdAmount >= 1000) {
      return '$usdSymbol${(usdAmount / 1000).toStringAsFixed(2)}K';
    }
    return '$usdSymbol${usdAmount.toStringAsFixed(2)}';
  }

  /// Formats Pounds to USD currency
  static String formatPoundsToUsd(double poundAmount) {
    final usdAmount = convertPoundsToUsd(poundAmount);
    if (usdAmount >= 1000000) {
      return '$usdSymbol${(usdAmount / 1000000).toStringAsFixed(2)}M';
    } else if (usdAmount >= 1000) {
      return '$usdSymbol${(usdAmount / 1000).toStringAsFixed(2)}K';
    }
    return '$usdSymbol${usdAmount.toStringAsFixed(2)}';
  }

  /// Formats amount with all three currencies (NGN, GBP→USD, and USD equivalents)
  static Map<String, String> formatMultiCurrency(double nairaAmount) {
    return {
      'NGN': formatCurrency(nairaAmount),
      'USD_from_NGN': formatNairaToUsd(nairaAmount),
      'USD_from_GBP':
          formatPoundsToUsd(nairaAmount * 0.79), // Approximate NGN to GBP ratio
    };
  }
}

/// Date and time helper
class DateHelper {
  /// Get tax year from date
  static String getTaxYear(DateTime date) {
    return '${date.year}/${date.year + 1}';
  }

  /// Get financial year start
  static DateTime getFinancialYearStart(int year) {
    return DateTime(year, 1, 1);
  }

  /// Get financial year end
  static DateTime getFinancialYearEnd(int year) {
    return DateTime(year, 12, 31);
  }

  /// Check if within financial year
  static bool isWithinFinancialYear(DateTime date, int year) {
    final start = getFinancialYearStart(year);
    final end = getFinancialYearEnd(year);
    return date.isAfter(start) && date.isBefore(end) ||
        date.isAtSameMomentAs(start) ||
        date.isAtSameMomentAs(end);
  }

  /// Days until deadline
  static int daysUntilDeadline(DateTime deadline) {
    return deadline.difference(DateTime.now()).inDays;
  }

  /// Format deadline as user-friendly text
  static String formatDeadline(DateTime deadline) {
    final daysLeft = daysUntilDeadline(deadline);
    if (daysLeft < 0) {
      return 'Overdue by ${-daysLeft} days';
    } else if (daysLeft == 0) {
      return 'Today';
    } else if (daysLeft == 1) {
      return 'Tomorrow';
    } else {
      return '$daysLeft days left';
    }
  }
}
