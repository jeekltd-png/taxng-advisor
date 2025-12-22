import 'package:hive/hive.dart';

/// Offline storage for PIT estimates
class PitStorageService {
  static const String boxName = 'pit_estimates';

  /// Initialize the storage box
  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
  }

  /// Save a PIT estimate
  static Future<void> saveEstimate(Map<String, dynamic> estimate) async {
    final box = Hive.box(boxName);
    estimate['timestamp'] = DateTime.now().toIso8601String();
    estimate['type'] = 'PIT';
    await box.add(estimate);
  }

  /// Get recent PIT estimates
  ///
  /// Parameters:
  /// - [limit]: Number of recent estimates to fetch (default 5)
  ///
  /// Returns: List of recent PIT calculations, newest first
  static List<Map<String, dynamic>> getRecent({int limit = 5}) {
    final box = Hive.box(boxName);
    final values = box.values.cast<Map<String, dynamic>>().toList();
    values.sort((a, b) =>
        (b['timestamp'] as String).compareTo(a['timestamp'] as String));
    return values.take(limit).toList();
  }

  /// Get all stored PIT estimates
  static List<Map<String, dynamic>> getAllEstimates() {
    final box = Hive.box(boxName);
    final values = box.values.cast<Map<String, dynamic>>().toList();
    values.sort((a, b) =>
        (b['timestamp'] as String).compareTo(a['timestamp'] as String));
    return values;
  }

  /// Delete a PIT estimate by index
  static Future<void> deleteEstimate(int index) async {
    final box = Hive.box(boxName);
    await box.deleteAt(index);
  }

  /// Clear all estimates
  static Future<void> clearAll() async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  /// Get estimate by timestamp
  static Map<String, dynamic>? getEstimateByTimestamp(String timestamp) {
    final box = Hive.box(boxName);
    try {
      final values = box.values.cast<Map<String, dynamic>>().toList();
      return values.firstWhere(
        (estimate) => estimate['timestamp'] == timestamp,
      );
    } catch (e) {
      return null;
    }
  }

  /// Calculate total tax liability for a period
  static double calculateTotalLiability({
    DateTime? from,
    DateTime? to,
  }) {
    final estimates = getAllEstimates();
    final now = DateTime.now();
    final fromDate = from ?? DateTime(now.year);
    final toDate = to ?? now;

    double total = 0.0;
    for (final estimate in estimates) {
      final timestampStr = estimate['timestamp'] as String?;
      if (timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        if (timestamp.isAfter(fromDate) && timestamp.isBefore(toDate)) {
          final totalTax = estimate['totalTax'] as double?;
          if (totalTax != null) {
            total += totalTax;
          }
        }
      }
    }
    return total;
  }

  /// Calculate average tax rate from stored estimates
  static double calculateAverageTaxRate() {
    final estimates = getAllEstimates();
    if (estimates.isEmpty) return 0.0;

    double totalTax = 0.0;
    double totalIncome = 0.0;

    for (final estimate in estimates) {
      final totalTax_ = estimate['totalTax'] as double?;
      final grossIncome = estimate['grossIncome'] as double?;

      if (totalTax_ != null && grossIncome != null) {
        totalTax += totalTax_;
        totalIncome += grossIncome;
      }
    }

    return totalIncome > 0 ? totalTax / totalIncome : 0.0;
  }
}
