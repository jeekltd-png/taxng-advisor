import 'package:hive/hive.dart';

/// Offline storage for WHT records
class WhtStorageService {
  static const String boxName = 'wht_records';

  /// Initialize the storage box
  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
  }

  /// Save a WHT calculation record
  static Future<void> saveRecord(Map<String, dynamic> whtRecord) async {
    final box = Hive.box(boxName);
    whtRecord['timestamp'] = DateTime.now().toIso8601String();
    whtRecord['type'] = 'WHT';
    await box.add(whtRecord);
  }

  /// Get recent WHT records
  ///
  /// Parameters:
  /// - [limit]: Number of recent records to fetch (default 5)
  ///
  /// Returns: List of recent WHT calculations, newest first
  static List<Map<String, dynamic>> getRecent({int limit = 5}) {
    final box = Hive.box(boxName);
    final values = box.values.cast<Map<String, dynamic>>().toList();
    values.sort((a, b) =>
        (b['timestamp'] as String).compareTo(a['timestamp'] as String));
    return values.take(limit).toList();
  }

  /// Get all stored WHT records
  static List<Map<String, dynamic>> getAllRecords() {
    final box = Hive.box(boxName);
    final values = box.values.cast<Map<String, dynamic>>().toList();
    values.sort((a, b) =>
        (b['timestamp'] as String).compareTo(a['timestamp'] as String));
    return values;
  }

  /// Get WHT records for a specific period
  static List<Map<String, dynamic>> getRecordsByPeriod({
    required DateTime from,
    required DateTime to,
  }) {
    final allRecords = getAllRecords();
    return allRecords.where((record) {
      final timestampStr = record['timestamp'] as String?;
      if (timestampStr == null) return false;
      final timestamp = DateTime.parse(timestampStr);
      return timestamp.isAfter(from) && timestamp.isBefore(to);
    }).toList();
  }

  /// Get WHT records by payment type
  static List<Map<String, dynamic>> getRecordsByType(String type) {
    final allRecords = getAllRecords();
    return allRecords.where((record) => record['type'] == type).toList();
  }

  /// Delete a WHT record by index
  static Future<void> deleteRecord(int index) async {
    final box = Hive.box(boxName);
    await box.deleteAt(index);
  }

  /// Clear all WHT records
  static Future<void> clearAll() async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  /// Calculate total WHT for a period
  static double calculateTotalWht({
    DateTime? from,
    DateTime? to,
  }) {
    final now = DateTime.now();
    final fromDate = from ?? DateTime(now.year);
    final toDate = to ?? now;

    final records = getRecordsByPeriod(from: fromDate, to: toDate);
    double total = 0.0;

    for (final record in records) {
      final wht = record['wht'] as double?;
      if (wht != null) {
        total += wht;
      }
    }
    return total;
  }

  /// Calculate total WHT by payment type for a period
  static double calculateWhtByType(
    String type, {
    DateTime? from,
    DateTime? to,
  }) {
    final now = DateTime.now();
    final fromDate = from ?? DateTime(now.year);
    final toDate = to ?? now;

    final records = getRecordsByPeriod(from: fromDate, to: toDate)
        .where((record) => record['type'] == type)
        .toList();

    double total = 0.0;
    for (final record in records) {
      final wht = record['wht'] as double?;
      if (wht != null) {
        total += wht;
      }
    }
    return total;
  }

  /// Calculate total gross amount subjected to WHT
  static double calculateTotalGrossAmount({
    DateTime? from,
    DateTime? to,
  }) {
    final now = DateTime.now();
    final fromDate = from ?? DateTime(now.year);
    final toDate = to ?? now;

    final records = getRecordsByPeriod(from: fromDate, to: toDate);
    double total = 0.0;

    for (final record in records) {
      final amount = record['amount'] as double?;
      if (amount != null) {
        total += amount;
      }
    }
    return total;
  }

  /// Get WHT record by timestamp
  static Map<String, dynamic>? getRecordByTimestamp(String timestamp) {
    final box = Hive.box(boxName);
    try {
      final values = box.values.cast<Map<String, dynamic>>().toList();
      return values.firstWhere(
        (record) => record['timestamp'] == timestamp,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get summary of WHT payments
  static Map<String, double> getSummaryByType() {
    final records = getAllRecords();
    final summary = <String, double>{};

    for (final record in records) {
      final type = record['type'] as String?;
      final wht = record['wht'] as double? ?? 0.0;

      if (type != null) {
        summary[type] = (summary[type] ?? 0.0) + wht;
      }
    }
    return summary;
  }
}
