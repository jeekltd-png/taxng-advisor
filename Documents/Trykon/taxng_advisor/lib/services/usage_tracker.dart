import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Tracks how many times a free-tier user has used real (custom) data
/// in each calculator. After [maxFreeUses] the user is blocked until upgrade.
class UsageTracker {
  static const String _boxName = 'usage_tracker';
  static const int maxFreeUses = 2;

  static Box get _box => Hive.box(_boxName);

  /// Ensure box is open (called once at app start via HiveService).
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  /// Key per user+calculator, e.g. "uid123_CIT"
  static String _key(String userId, String calculatorType) =>
      '${userId}_$calculatorType';

  /// How many real-data uses this user has consumed for [calculatorType].
  static int getUsageCount(String userId, String calculatorType) {
    return _box.get(_key(userId, calculatorType), defaultValue: 0) as int;
  }

  /// Increment the counter. Returns the new count.
  static Future<int> recordUsage(String userId, String calculatorType) async {
    final key = _key(userId, calculatorType);
    final current = _box.get(key, defaultValue: 0) as int;
    final next = current + 1;
    await _box.put(key, next);
    debugPrint('UsageTracker: $key → $next / $maxFreeUses');
    return next;
  }

  /// Whether the user has remaining real-data uses.
  static bool hasRemainingUses(String userId, String calculatorType) {
    return getUsageCount(userId, calculatorType) < maxFreeUses;
  }

  /// How many uses are left.
  static int remainingUses(String userId, String calculatorType) {
    final used = getUsageCount(userId, calculatorType);
    return (maxFreeUses - used).clamp(0, maxFreeUses);
  }
}
