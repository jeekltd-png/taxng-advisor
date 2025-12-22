import 'package:hive/hive.dart';
import 'package:taxng_advisor/models/tax_result.dart';

/// Offline storage for CIT estimates
class CitStorageService {
  static const String boxName = 'cit_estimates';

  /// Initialize the storage box
  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
  }

  /// Save a CIT calculation estimate
  static Future<void> saveEstimate(CitResult result) async {
    final box = Hive.box(boxName);
    await box.add(result.toMap());
  }

  /// Get recent CIT estimates
  ///
  /// Parameters:
  /// - [limit]: Number of recent estimates to return (default 5)
  ///
  /// Returns: List of recent CIT calculation estimates, newest first
  static List<CitResult> getRecent({int limit = 5}) {
    final box = Hive.box(boxName);
    final values = box.values.cast<Map<String, dynamic>>().toList();
    values.sort((a, b) =>
        (b['calculatedAt'] as String).compareTo(a['calculatedAt'] as String));
    return values.take(limit).map((map) => CitResult.fromMap(map)).toList();
  }

  /// Get all stored estimates
  static List<CitResult> getAllEstimates() {
    final box = Hive.box(boxName);
    final values = box.values.cast<Map<String, dynamic>>().toList();
    values.sort((a, b) =>
        (b['calculatedAt'] as String).compareTo(a['calculatedAt'] as String));
    return values.map((map) => CitResult.fromMap(map)).toList();
  }

  /// Delete an estimate by index
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
  static CitResult? getEstimateByTimestamp(String timestamp) {
    final box = Hive.box(boxName);
    try {
      final values = box.values.cast<Map<String, dynamic>>().toList();
      final map = values.firstWhere(
        (estimate) => estimate['calculatedAt'] == timestamp,
      );
      return CitResult.fromMap(map);
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
      final timestamp = estimate.calculatedAt;
      if (timestamp.isAfter(fromDate) && timestamp.isBefore(toDate)) {
        total += estimate.taxPayable;
      }
    }
    return total;
  }
}
