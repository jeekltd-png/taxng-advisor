import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/admin_activity_log.dart';
import '../models/user.dart';

/// Service for logging admin activities
class ActivityLogService {
  static const String _boxName = 'admin_activity_logs';

  /// Log an admin action
  static Future<void> logAction({
    required User admin,
    required String action,
    required String targetUserId,
    String? targetUsername,
    Map<String, dynamic>? details,
  }) async {
    try {
      final box = await Hive.openBox<AdminActivityLog>(_boxName);

      final log = AdminActivityLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        adminId: admin.id,
        adminUsername: admin.username,
        action: action,
        targetUserId: targetUserId,
        targetUsername: targetUsername,
        details: details ?? {},
        ipAddress: 'local', // In web/mobile, this would be actual IP
        timestamp: DateTime.now(),
      );

      await box.add(log);
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }

  /// Get all activity logs
  static Future<List<AdminActivityLog>> getAllLogs() async {
    final box = await Hive.openBox<AdminActivityLog>(_boxName);
    return box.values.toList();
  }

  /// Get logs for a specific admin
  static Future<List<AdminActivityLog>> getLogsByAdmin(String adminId) async {
    final box = await Hive.openBox<AdminActivityLog>(_boxName);
    return box.values.where((log) => log.adminId == adminId).toList();
  }

  /// Get logs for a specific action type
  static Future<List<AdminActivityLog>> getLogsByAction(String action) async {
    final box = await Hive.openBox<AdminActivityLog>(_boxName);
    return box.values.where((log) => log.action == action).toList();
  }

  /// Get logs for a specific target user
  static Future<List<AdminActivityLog>> getLogsByTargetUser(
      String userId) async {
    final box = await Hive.openBox<AdminActivityLog>(_boxName);
    return box.values.where((log) => log.targetUserId == userId).toList();
  }

  /// Get logs within a date range
  static Future<List<AdminActivityLog>> getLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final box = await Hive.openBox<AdminActivityLog>(_boxName);
    return box.values.where((log) {
      return log.timestamp.isAfter(start) && log.timestamp.isBefore(end);
    }).toList();
  }

  /// Delete old logs (keep last N days)
  static Future<void> cleanupOldLogs({int keepDays = 90}) async {
    final box = await Hive.openBox<AdminActivityLog>(_boxName);
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));

    final logsToDelete =
        box.values.where((log) => log.timestamp.isBefore(cutoffDate)).toList();

    for (final log in logsToDelete) {
      final key = box.keys.firstWhere(
        (k) => (box.get(k) as AdminActivityLog).id == log.id,
      );
      await box.delete(key);
    }
  }

  /// Export logs to CSV format
  static String exportToCSV(List<AdminActivityLog> logs) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
        '"Timestamp","Admin","Action","Target User","Details","IP Address"');

    // CSV Rows
    for (final log in logs) {
      final timestamp = log.timestamp.toString().split('.')[0];
      final details =
          log.details.entries.map((e) => '${e.key}: ${e.value}').join('; ');

      buffer.writeln(
          '"$timestamp","${log.adminUsername}","${log.getActionDescription()}",'
          '"${log.targetUsername ?? log.targetUserId}","$details","${log.ipAddress}"');
    }

    return buffer.toString();
  }

  /// Get activity statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final box = await Hive.openBox<AdminActivityLog>(_boxName);
    final logs = box.values.toList();

    // Count by action type
    final actionCounts = <String, int>{};
    for (final log in logs) {
      actionCounts[log.action] = (actionCounts[log.action] ?? 0) + 1;
    }

    // Count by admin
    final adminCounts = <String, int>{};
    for (final log in logs) {
      adminCounts[log.adminUsername] =
          (adminCounts[log.adminUsername] ?? 0) + 1;
    }

    // Recent activity (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentLogs =
        logs.where((log) => log.timestamp.isAfter(sevenDaysAgo)).length;

    return {
      'totalLogs': logs.length,
      'actionCounts': actionCounts,
      'adminCounts': adminCounts,
      'recentActivity': recentLogs,
      'oldestLog': logs.isEmpty
          ? null
          : logs
              .map((l) => l.timestamp)
              .reduce((a, b) => a.isBefore(b) ? a : b),
      'newestLog': logs.isEmpty
          ? null
          : logs.map((l) => l.timestamp).reduce((a, b) => a.isAfter(b) ? a : b),
    };
  }
}
