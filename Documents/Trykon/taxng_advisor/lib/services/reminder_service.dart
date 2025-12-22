import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Tax reminder deadlines
enum TaxReminder {
  vatMonthly,
  pitAnnual,
  citAnnual,
  whtMonthly,
  payrollMonthly,
  stampDutyQuarterly,
  provisionalTax,
  finalComputation,
  citQuarterly,
  pitEstimate,
  whtAnnual,
  stampDutySixMonthly,
}

/// Reminder Service
///
/// Manages tax deadline reminders and notifications for users.
/// Schedules notifications for key tax compliance dates.
class ReminderService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// Initialize the notifications plugin
  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings),
    );
  }

  /// Schedule all default tax reminders
  static Future<void> scheduleAllDefaultReminders() async {
    await _scheduleVatReminders();
    await _schedulePitReminders();
    await _scheduleCitReminders();
    await _scheduleWhtReminders();
    await _schedulePayrollReminders();
    await _scheduleStampDutyReminders();
    await _scheduleCitQuarterlyReminders();
    await _schedulePitEstimateReminders();
    await _scheduleWhtAnnualReminders();
    await _scheduleStampDutySixMonthlyReminders();
  }

  /// Schedule monthly VAT reminder (21st of each month)
  static Future<void> _scheduleVatReminders() async {
    final now = DateTime.now();
    final scheduledDate = DateTime(now.year, now.month, 21, 9, 0);

    // If already passed this month, schedule for next month
    final dateToSchedule = scheduledDate.isBefore(now)
        ? DateTime(now.year, now.month + 1, 21, 9, 0)
        : scheduledDate;

    await _scheduleNotification(
      id: 1,
      title: 'VAT Return Due',
      body: 'Submit your monthly VAT return to FIRS',
      scheduledDate: dateToSchedule,
    );
  }

  /// Schedule annual PIT reminder (31st of May)
  static Future<void> _schedulePitReminders() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, 5, 31, 9, 0);

    // If already passed this year, schedule for next year
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(now.year + 1, 5, 31, 9, 0);
    }

    await _scheduleNotification(
      id: 2,
      title: 'PIT Annual Return Due',
      body: 'File your Personal Income Tax annual return with FIRS',
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule annual CIT reminder (31st of May)
  static Future<void> _scheduleCitReminders() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, 5, 31, 10, 0);

    // If already passed this year, schedule for next year
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(now.year + 1, 5, 31, 10, 0);
    }

    await _scheduleNotification(
      id: 3,
      title: 'CIT Annual Return Due',
      body: 'File your Corporate Income Tax annual return',
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule monthly WHT reminder (15th of each month)
  static Future<void> _scheduleWhtReminders() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, 15, 10, 0);

    // If already passed this month, schedule for next month
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(now.year, now.month + 1, 15, 10, 0);
    }

    await _scheduleNotification(
      id: 4,
      title: 'WHT Remittance Due',
      body: 'Remit Withholding Tax deducted to FIRS',
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule monthly payroll reminder (last business day of month)
  static Future<void> _schedulePayrollReminders() async {
    final now = DateTime.now();
    final lastDay = _getLastBusinessDayOfMonth(now.year, now.month);
    var scheduledDate = DateTime(now.year, now.month, lastDay, 17, 0);

    // If already passed this month, schedule for next month
    if (scheduledDate.isBefore(now)) {
      final nextMonth = now.month == 12
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);
      final lastDayNext =
          _getLastBusinessDayOfMonth(nextMonth.year, nextMonth.month);
      scheduledDate =
          DateTime(nextMonth.year, nextMonth.month, lastDayNext, 17, 0);
    }

    await _scheduleNotification(
      id: 5,
      title: 'Payroll Payment Due',
      body: 'Process and pay employee salaries',
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule quarterly stamp duty reminder
  static Future<void> _scheduleStampDutyReminders() async {
    final now = DateTime.now();
    final quarter = (now.month - 1) ~/ 3 + 1;
    final dueDates = [3, 6, 9, 12]; // March, June, September, December
    var dueMonth = dueDates[quarter - 1];
    var dueYear = now.year;

    if (now.month > dueMonth) {
      dueYear = now.year + 1;
      dueMonth = dueDates[0]; // January reminder for next year
    }

    final scheduledDate = DateTime(dueYear, dueMonth, 30, 11, 0);

    await _scheduleNotification(
      id: 6,
      title: 'Quarterly Stamp Duty Return Due',
      body: 'Submit quarterly stamp duty statement to FIRS',
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule quarterly CIT reminder (in addition to annual)
  static Future<void> _scheduleCitQuarterlyReminders() async {
    final now = DateTime.now();
    final quarter = (now.month - 1) ~/ 3 + 1;
    final dueDates = [
      4,
      7,
      10,
      1
    ]; // Apr, Jul, Oct, Jan (days vary by regulation)
    var dueMonth = dueDates[quarter - 1];
    var dueYear = now.year;

    if (now.month > dueMonth) {
      dueYear = now.year + 1;
    }

    final scheduledDate = DateTime(dueYear, dueMonth, 15, 10, 0);

    await _scheduleNotification(
      id: 7,
      title: 'CIT Quarterly Provisional Return',
      body: 'File your quarterly CIT provisional return with FIRS',
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule PIT estimate reminder
  static Future<void> _schedulePitEstimateReminders() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, 1, 31, 9, 0);

    // If already passed this year, schedule for next year
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(now.year + 1, 1, 31, 9, 0);
    }

    await _scheduleNotification(
      id: 8,
      title: 'PIT Estimate Submission',
      body: 'File your estimated Personal Income Tax for the year',
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule annual WHT summary reminder
  static Future<void> _scheduleWhtAnnualReminders() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, 2, 28, 10, 0);

    // If already passed this year, schedule for next year
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(now.year + 1, 2, 28, 10, 0);
    }

    await _scheduleNotification(
      id: 9,
      title: 'Annual WHT Summary Due',
      body: 'File annual Withholding Tax summary statement to FIRS',
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule six-monthly stamp duty review reminder
  static Future<void> _scheduleStampDutySixMonthlyReminders() async {
    final now = DateTime.now();
    // Reminders on June 30 and December 31
    final firstReminder = DateTime(now.year, 6, 30, 14, 0);
    final secondReminder = DateTime(now.year, 12, 31, 14, 0);

    DateTime scheduledDate = firstReminder;
    if (now.isAfter(firstReminder) && now.isBefore(secondReminder)) {
      scheduledDate = secondReminder;
    } else if (now.isAfter(secondReminder)) {
      scheduledDate = DateTime(now.year + 1, 6, 30, 14, 0);
    }

    await _scheduleNotification(
      id: 10,
      title: 'Stamp Duty Six-Monthly Review',
      body: 'Review and reconcile your stamp duty records',
      scheduledDate: scheduledDate,
    );
  }

  /// Get the last business day of a given month (excluding weekends)
  static int _getLastBusinessDayOfMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    for (int day = lastDay; day >= 1; day--) {
      final date = DateTime(year, month, day);
      // 6 = Saturday, 7 = Sunday in Dart
      if (date.weekday != 6 && date.weekday != 7) {
        return day;
      }
    }
    return lastDay;
  }

  /// Schedule a single notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tax_reminders',
            'Tax Reminders',
            channelDescription: 'Reminders for tax deadlines',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Cancel a specific reminder
  static Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all reminders
  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  /// Schedule a custom reminder
  static Future<void> scheduleCustomReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: dateTime,
    );
  }

  /// Get reminder description
  static String getReminderDescription(TaxReminder reminder) {
    switch (reminder) {
      case TaxReminder.vatMonthly:
        return 'Monthly VAT return - Due 21st of each month';
      case TaxReminder.pitAnnual:
        return 'Annual PIT return - Due 31st May';
      case TaxReminder.citAnnual:
        return 'Annual CIT return - Due 31st May';
      case TaxReminder.whtMonthly:
        return 'Monthly WHT remittance - Due 15th of each month';
      case TaxReminder.payrollMonthly:
        return 'Monthly payroll payment - Last business day of month';
      case TaxReminder.stampDutyQuarterly:
        return 'Quarterly stamp duty return - End of each quarter';
      case TaxReminder.provisionalTax:
        return 'Provisional tax payment - Varies by type';
      case TaxReminder.finalComputation:
        return 'Final tax computation - Year-end assessment';
      case TaxReminder.citQuarterly:
        return 'Quarterly CIT provisional return - 15th of Apr, Jul, Oct, Jan';
      case TaxReminder.pitEstimate:
        return 'PIT estimate submission - 31st January';
      case TaxReminder.whtAnnual:
        return 'Annual WHT summary - Due 28th February';
      case TaxReminder.stampDutySixMonthly:
        return 'Stamp duty six-monthly review - June 30 & December 31';
    }
  }
}
