import 'package:intl/intl.dart';

/// Utility class for formatting currency values
class CurrencyFormatter {
  /// Format amount as Nigerian Naira
  static String formatNaira(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format amount as Nigerian Naira without decimals
  static String formatNairaShort(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format amount with commas (no currency symbol)
  static String formatWithCommas(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_NG');
    return formatter.format(amount);
  }

  /// Format amount with commas and no decimals
  static String formatWithCommasShort(double amount) {
    final formatter = NumberFormat('#,##0', 'en_NG');
    return formatter.format(amount);
  }

  /// Format amount as US Dollars
  static String formatUSD(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Parse currency string back to double
  static double? parseNaira(String value) {
    try {
      // Remove currency symbol and commas
      final cleaned = value
          .replaceAll('₦', '')
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .trim();
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Format percentage
  static String formatPercent(double value, {int decimalDigits = 1}) {
    return '${value.toStringAsFixed(decimalDigits)}%';
  }

  /// Format compact number (e.g., 1.2M, 500K)
  static String formatCompact(double amount) {
    final formatter = NumberFormat.compact(locale: 'en_NG');
    return formatter.format(amount);
  }

  /// Format amount based on currency code
  static String formatByCurrency(double amount, String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN':
        return formatNaira(amount);
      case 'USD':
        return formatUSD(amount);
      default:
        return formatNaira(amount);
    }
  }
}
