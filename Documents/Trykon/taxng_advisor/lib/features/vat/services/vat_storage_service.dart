import 'package:hive/hive.dart';

/// Offline storage for VAT returns
class VatStorageService {
  static const String boxName = 'vat_returns';

  /// Initialize the storage box
  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
  }

  /// Save a VAT calculation/return
  static Future<void> saveReturn(Map<String, dynamic> vatReturn) async {
    final box = Hive.box(boxName);
    vatReturn['timestamp'] = DateTime.now().toIso8601String();
    vatReturn['type'] = 'VAT';
    await box.add(vatReturn);
  }

  /// Get recent VAT returns
  ///
  /// Parameters:
  /// - [limit]: Number of recent returns to fetch (default 5)
  ///
  /// Returns: List of recent VAT calculations, newest first
  static List<Map<String, dynamic>> getRecent({int limit = 5}) {
    final box = Hive.box(boxName);
    final values = box.values.cast<Map<String, dynamic>>().toList();
    values.sort((a, b) =>
        (b['timestamp'] as String).compareTo(a['timestamp'] as String));
    return values.take(limit).toList();
  }

  /// Get all stored VAT returns
  static List<Map<String, dynamic>> getAllReturns() {
    final box = Hive.box(boxName);
    final values = box.values.cast<Map<String, dynamic>>().toList();
    values.sort((a, b) =>
        (b['timestamp'] as String).compareTo(a['timestamp'] as String));
    return values;
  }

  /// Get VAT returns for a specific period
  static List<Map<String, dynamic>> getReturnsByPeriod({
    required DateTime from,
    required DateTime to,
  }) {
    final allReturns = getAllReturns();
    return allReturns.where((return_) {
      final timestampStr = return_['timestamp'] as String?;
      if (timestampStr == null) return false;
      final timestamp = DateTime.parse(timestampStr);
      return timestamp.isAfter(from) && timestamp.isBefore(to);
    }).toList();
  }

  /// Delete a VAT return by index
  static Future<void> deleteReturn(int index) async {
    final box = Hive.box(boxName);
    await box.deleteAt(index);
  }

  /// Clear all VAT returns
  static Future<void> clearAll() async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  /// Calculate total VAT payable for a period
  static double calculateTotalVatPayable({
    DateTime? from,
    DateTime? to,
  }) {
    final now = DateTime.now();
    final fromDate = from ?? DateTime(now.year);
    final toDate = to ?? now;

    final returns = getReturnsByPeriod(from: fromDate, to: toDate);
    double total = 0.0;
    for (final return_ in returns) {
      final netPayable = return_['netPayable'] as double?;
      if (netPayable != null) {
        total += netPayable;
      }
    }
    return total;
  }

  /// Calculate total VAT refund due for a period
  static double calculateTotalRefundDue({
    DateTime? from,
    DateTime? to,
  }) {
    final now = DateTime.now();
    final fromDate = from ?? DateTime(now.year);
    final toDate = to ?? now;

    final returns = getReturnsByPeriod(from: fromDate, to: toDate);
    double total = 0.0;
    for (final return_ in returns) {
      final refundEligible = return_['refundEligible'] as double?;
      if (refundEligible != null) {
        total += refundEligible;
      }
    }
    return total;
  }

  /// Calculate total sales for a period
  static double calculateTotalSales({
    DateTime? from,
    DateTime? to,
  }) {
    final now = DateTime.now();
    final fromDate = from ?? DateTime(now.year);
    final toDate = to ?? now;

    final returns = getReturnsByPeriod(from: fromDate, to: toDate);
    double totalSales = 0.0;

    for (final return_ in returns) {
      final vatableSales = return_['vatableSales'] as double?;
      final zeroRatedSales = return_['zeroRatedSales'] as double?;
      final exemptSales = return_['exemptSales'] as double?;

      if (vatableSales != null) totalSales += vatableSales;
      if (zeroRatedSales != null) totalSales += zeroRatedSales;
      if (exemptSales != null) totalSales += exemptSales;
    }
    return totalSales;
  }

  /// Get VAT return by timestamp
  static Map<String, dynamic>? getReturnByTimestamp(String timestamp) {
    final box = Hive.box(boxName);
    try {
      final values = box.values.cast<Map<String, dynamic>>().toList();
      return values.firstWhere(
        (return_) => return_['timestamp'] == timestamp,
      );
    } catch (e) {
      return null;
    }
  }
}
