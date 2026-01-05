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

  /// Validates Nigerian TIN (Tax Identification Number)
  /// TIN format: 8-10 digits for individuals, or may contain hyphens
  /// Example: 12345678-0001 or 1234567890
  static bool isValidTIN(String? tin) {
    if (tin == null || tin.isEmpty) return false;

    // Remove spaces and hyphens for validation
    final cleanTin = tin.replaceAll(RegExp(r'[\s\-]'), '');

    // Must be 8-14 digits (to accommodate various Nigerian TIN formats)
    if (cleanTin.length < 8 || cleanTin.length > 14) return false;

    // Must contain only digits
    return RegExp(r'^\d+$').hasMatch(cleanTin);
  }

  /// Validates TIN and throws exception if invalid
  static void validateTIN(String? tin, {bool required = false}) {
    if (required && (tin == null || tin.isEmpty)) {
      throw ArgumentError('TIN is required for tax compliance');
    }
    if (tin != null && tin.isNotEmpty && !isValidTIN(tin)) {
      throw ArgumentError(
        'Invalid TIN format. TIN must be 8-14 digits (may contain hyphens)',
      );
    }
  }

  /// Validates Nigerian CAC Registration Number (RC or BN)
  /// Format: RC1234567 or BN1234567
  static bool isValidCAC(String? cac) {
    if (cac == null || cac.isEmpty) return false;

    // Remove spaces for validation
    final cleanCAC = cac.replaceAll(' ', '').toUpperCase();

    // Must start with RC or BN followed by digits
    return RegExp(r'^(RC|BN)\d{6,8}$').hasMatch(cleanCAC);
  }

  /// Validates CAC number and throws exception if invalid
  static void validateCAC(String? cac, {bool required = false}) {
    if (required && (cac == null || cac.isEmpty)) {
      throw ArgumentError('CAC Registration Number is required for businesses');
    }
    if (cac != null && cac.isNotEmpty && !isValidCAC(cac)) {
      throw ArgumentError(
        'Invalid CAC format. Must be RC or BN followed by 6-8 digits (e.g., RC1234567)',
      );
    }
  }

  /// Validates Nigerian BVN (Bank Verification Number)
  /// Format: 11 digits
  static bool isValidBVN(String? bvn) {
    if (bvn == null || bvn.isEmpty) return false;

    // Remove spaces and hyphens
    final cleanBVN = bvn.replaceAll(RegExp(r'[\s\-]'), '');

    // Must be exactly 11 digits
    return cleanBVN.length == 11 && RegExp(r'^\d{11}$').hasMatch(cleanBVN);
  }

  /// Validates BVN and throws exception if invalid
  static void validateBVN(String? bvn, {bool required = false}) {
    if (required && (bvn == null || bvn.isEmpty)) {
      throw ArgumentError('BVN is required for individual taxpayers');
    }
    if (bvn != null && bvn.isNotEmpty && !isValidBVN(bvn)) {
      throw ArgumentError(
        'Invalid BVN format. Must be exactly 11 digits',
      );
    }
  }

  /// Validates Nigerian phone number
  /// Format: 080XXXXXXXX, 234XXXXXXXXXX, or +234XXXXXXXXXX
  static bool isValidNigerianPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Remove spaces, hyphens, and parentheses
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Valid formats:
    // 080XXXXXXXX (11 digits starting with 0)
    // 234XXXXXXXXXX (13 digits starting with 234)
    // +234XXXXXXXXXX (13 digits starting with +234)
    return RegExp(r'^(0[789][01]\d{8}|234[789][01]\d{8}|\+234[789][01]\d{8})$')
        .hasMatch(cleanPhone);
  }

  /// Validates phone number and throws exception if invalid
  static void validatePhone(String? phone, {bool required = false}) {
    if (required && (phone == null || phone.isEmpty)) {
      throw ArgumentError('Phone number is required');
    }
    if (phone != null && phone.isNotEmpty && !isValidNigerianPhone(phone)) {
      throw ArgumentError(
        'Invalid phone number. Must be Nigerian format (e.g., 08012345678, 2348012345678, or +2348012345678)',
      );
    }
  }

  /// Validates VAT Registration Number
  /// Similar to TIN but specifically for VAT
  static bool isValidVATNumber(String? vat) {
    if (vat == null || vat.isEmpty) return false;

    // Remove spaces and hyphens
    final cleanVAT = vat.replaceAll(RegExp(r'[\s\-]'), '');

    // Must be 8-14 digits
    return cleanVAT.length >= 8 &&
        cleanVAT.length <= 14 &&
        RegExp(r'^\d+$').hasMatch(cleanVAT);
  }

  /// Validates VAT number and throws exception if invalid
  static void validateVATNumber(String? vat, {bool required = false}) {
    if (required && (vat == null || vat.isEmpty)) {
      throw ArgumentError(
          'VAT Registration Number is required for VAT-registered businesses');
    }
    if (vat != null && vat.isNotEmpty && !isValidVATNumber(vat)) {
      throw ArgumentError(
        'Invalid VAT number format. Must be 8-14 digits',
      );
    }
  }

  /// Validates PAYE Reference Number
  /// Format varies by state but generally alphanumeric
  static bool isValidPAYERef(String? paye) {
    if (paye == null || paye.isEmpty) return false;

    // Must be at least 5 characters, alphanumeric with possible hyphens/slashes
    return paye.length >= 5 &&
        RegExp(r'^[A-Z0-9\-\/]+$', caseSensitive: false).hasMatch(paye);
  }

  /// Validates PAYE reference and throws exception if invalid
  static void validatePAYERef(String? paye, {bool required = false}) {
    if (required && (paye == null || paye.isEmpty)) {
      throw ArgumentError('PAYE Reference Number is required for employers');
    }
    if (paye != null && paye.isNotEmpty && !isValidPAYERef(paye)) {
      throw ArgumentError(
        'Invalid PAYE reference format. Must be at least 5 alphanumeric characters',
      );
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
