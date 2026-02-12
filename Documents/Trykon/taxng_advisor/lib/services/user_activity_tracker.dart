import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import '../models/user_activity.dart';
import '../services/auth_service.dart';

/// User Activity Tracker Service
///
/// Tracks user activities including:
/// - App downloads/installations
/// - Calculator usage
/// - Login/Logout events
/// - Feedback submissions
/// - App ratings
class UserActivityTracker {
  static const String _boxName = 'user_activities';

  /// Initialize the activity tracking box
  static Future<void> initialize() async {
    await Hive.openBox<Map>(_boxName);
  }

  /// Get the activity box
  static Box<Map> _getBox() {
    return Hive.box<Map>(_boxName);
  }

  /// Get device info string
  static Future<String> _getDeviceInfo() async {
    try {
      if (kIsWeb) return 'Web';
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'Android';
        case TargetPlatform.iOS:
          return 'iOS';
        case TargetPlatform.windows:
          return 'Windows';
        case TargetPlatform.macOS:
          return 'macOS';
        case TargetPlatform.linux:
          return 'Linux';
        default:
          return 'Unknown';
      }
    } catch (e) {
      return 'Web'; // Default to web if platform detection fails
    }
  }

  /// Get app version
  static Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '1.0.0'; // Default version
    }
  }

  /// Track app download/installation (first launch)
  static Future<void> trackAppDownload() async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    final activity = UserActivity(
      id: 'download_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      username: user.username,
      email: user.email,
      activityType: 'download',
      timestamp: DateTime.now(),
      deviceInfo: deviceInfo,
      appVersion: appVersion,
      details: 'User downloaded and installed the app',
    );

    final box = _getBox();
    await box.add(activity.toMap());
  }

  /// Track login event
  static Future<void> trackLogin(
      String userId, String username, String email) async {
    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    final activity = UserActivity(
      id: 'login_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      username: username,
      email: email,
      activityType: 'login',
      timestamp: DateTime.now(),
      deviceInfo: deviceInfo,
      appVersion: appVersion,
    );

    final box = _getBox();
    await box.add(activity.toMap());
  }

  /// Track logout event
  static Future<void> trackLogout() async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    final activity = UserActivity(
      id: 'logout_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      username: user.username,
      email: user.email,
      activityType: 'logout',
      timestamp: DateTime.now(),
      deviceInfo: deviceInfo,
      appVersion: appVersion,
    );

    final box = _getBox();
    await box.add(activity.toMap());
  }

  /// Track calculator usage
  ///
  /// [calculatorType] - 'vat', 'pit', 'cit', 'wht', 'payroll', 'stamp_duty'
  static Future<void> trackCalculatorUse(String calculatorType,
      {String? details}) async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    final activity = UserActivity(
      id: 'calc_${calculatorType}_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      username: user.username,
      email: user.email,
      activityType: 'calculator_use',
      calculatorType: calculatorType,
      timestamp: DateTime.now(),
      deviceInfo: deviceInfo,
      appVersion: appVersion,
      details: details,
    );

    final box = _getBox();
    await box.add(activity.toMap());
  }

  /// Track data import usage
  ///
  /// [fileName] - name of the imported file
  /// [taxType] - tax type the import was for (e.g. 'VAT', 'PIT')
  static Future<void> trackDataImport(String fileName,
      {String? taxType}) async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    final activity = UserActivity(
      id: 'import_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      username: user.username,
      email: user.email,
      activityType: 'data_import',
      calculatorType: taxType?.toLowerCase(),
      timestamp: DateTime.now(),
      deviceInfo: deviceInfo,
      appVersion: appVersion,
      details:
          'Imported file: $fileName${taxType != null ? ' for $taxType' : ''}',
    );

    final box = _getBox();
    await box.add(activity.toMap());
  }

  /// Track page/screen view
  ///
  /// [pageName] - the name of the page/screen visited
  static Future<void> trackPageView(String pageName) async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    final activity = UserActivity(
      id: 'page_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      username: user.username,
      email: user.email,
      activityType: 'page_view',
      timestamp: DateTime.now(),
      deviceInfo: deviceInfo,
      appVersion: appVersion,
      details: pageName,
    );

    final box = _getBox();
    await box.add(activity.toMap());
  }

  /// Track feedback submission
  static Future<void> trackFeedback(String feedbackMessage,
      {String? category}) async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    final activity = UserActivity(
      id: 'feedback_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      username: user.username,
      email: user.email,
      activityType: 'feedback',
      timestamp: DateTime.now(),
      deviceInfo: deviceInfo,
      appVersion: appVersion,
      details: category != null
          ? '$category: ${feedbackMessage.substring(0, feedbackMessage.length > 100 ? 100 : feedbackMessage.length)}'
          : feedbackMessage.substring(
              0, feedbackMessage.length > 100 ? 100 : feedbackMessage.length),
    );

    final box = _getBox();
    await box.add(activity.toMap());
  }

  /// Track app rating
  ///
  /// [rating] - 1 to 5 stars
  static Future<void> trackRating(int rating, {String? comment}) async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5');
    }

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    final activity = UserActivity(
      id: 'rating_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      username: user.username,
      email: user.email,
      activityType: 'rating',
      rating: rating,
      timestamp: DateTime.now(),
      deviceInfo: deviceInfo,
      appVersion: appVersion,
      details: comment,
    );

    final box = _getBox();
    await box.add(activity.toMap());
  }

  /// Get all user activities (admin only)
  static Future<List<UserActivity>> getAllActivities({
    String? activityType,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final box = _getBox();
    var activities = box.values
        .map((map) => UserActivity.fromMap(Map<String, dynamic>.from(map)))
        .toList();

    // Apply filters
    if (activityType != null) {
      activities =
          activities.where((a) => a.activityType == activityType).toList();
    }

    if (userId != null) {
      activities = activities.where((a) => a.userId == userId).toList();
    }

    if (startDate != null) {
      activities =
          activities.where((a) => a.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      activities =
          activities.where((a) => a.timestamp.isBefore(endDate)).toList();
    }

    // Sort by timestamp (newest first)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities;
  }

  /// Get activity statistics (admin only)
  static Future<Map<String, dynamic>> getActivityStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final activities = await getAllActivities(
      startDate: startDate,
      endDate: endDate,
    );

    // Count by activity type
    final activityCounts = <String, int>{};
    final calculatorCounts = <String, int>{};
    final ratingCounts = <int, int>{};
    final deviceCounts = <String, int>{};

    double totalRatingSum = 0;
    int ratingCount = 0;

    // Count unique users
    final uniqueUsers = <String>{};

    for (var activity in activities) {
      // Count activity types
      activityCounts[activity.activityType] =
          (activityCounts[activity.activityType] ?? 0) + 1;

      // Count calculator usage
      if (activity.calculatorType != null) {
        calculatorCounts[activity.calculatorType!] =
            (calculatorCounts[activity.calculatorType!] ?? 0) + 1;
      }

      // Count ratings
      if (activity.rating != null) {
        ratingCounts[activity.rating!] =
            (ratingCounts[activity.rating!] ?? 0) + 1;
        totalRatingSum += activity.rating!.toDouble();
        ratingCount++;
      }

      // Count devices
      if (activity.deviceInfo != null) {
        deviceCounts[activity.deviceInfo!] =
            (deviceCounts[activity.deviceInfo!] ?? 0) + 1;
      }

      // Track unique users
      uniqueUsers.add(activity.userId);
    }

    final averageRating = ratingCount > 0 ? totalRatingSum / ratingCount : 0.0;

    return {
      'total_activities': activities.length,
      'unique_users': uniqueUsers.length,
      'activity_counts': activityCounts,
      'calculator_counts': calculatorCounts,
      'rating_counts': ratingCounts,
      'average_rating': averageRating,
      'device_counts': deviceCounts,
      'downloads': activityCounts['download'] ?? 0,
      'logins': activityCounts['login'] ?? 0,
      'logouts': activityCounts['logout'] ?? 0,
      'feedback_submissions': activityCounts['feedback'] ?? 0,
      'ratings_submitted': ratingCount,
      'data_imports': activityCounts['data_import'] ?? 0,
      'page_views': activityCounts['page_view'] ?? 0,
      'total_calculator_uses':
          calculatorCounts.values.fold(0, (sum, count) => sum + count),
    };
  }

  /// Get user activity summary for a specific user
  static Future<Map<String, dynamic>> getUserActivitySummary(
      String userId) async {
    final activities = await getAllActivities(userId: userId);

    final activityCounts = <String, int>{};
    final calculatorCounts = <String, int>{};

    int? latestRating;
    DateTime? lastLogin;
    DateTime? lastLogout;

    for (var activity in activities) {
      activityCounts[activity.activityType] =
          (activityCounts[activity.activityType] ?? 0) + 1;

      if (activity.calculatorType != null) {
        calculatorCounts[activity.calculatorType!] =
            (calculatorCounts[activity.calculatorType!] ?? 0) + 1;
      }

      if (activity.rating != null) {
        latestRating = activity.rating;
      }

      if (activity.activityType == 'login' &&
          (lastLogin == null || activity.timestamp.isAfter(lastLogin))) {
        lastLogin = activity.timestamp;
      }

      if (activity.activityType == 'logout' &&
          (lastLogout == null || activity.timestamp.isAfter(lastLogout))) {
        lastLogout = activity.timestamp;
      }
    }

    return {
      'total_activities': activities.length,
      'activity_counts': activityCounts,
      'calculator_counts': calculatorCounts,
      'latest_rating': latestRating,
      'last_login': lastLogin?.toIso8601String(),
      'last_logout': lastLogout?.toIso8601String(),
      'most_used_calculator': calculatorCounts.entries.isNotEmpty
          ? calculatorCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : null,
    };
  }
}
