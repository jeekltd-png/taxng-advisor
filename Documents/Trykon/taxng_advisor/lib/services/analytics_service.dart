import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/subscription_request.dart';
import '../models/support_ticket.dart';
import '../models/admin_activity_log.dart';

class AnalyticsService {
  /// Get user growth statistics
  static Future<Map<String, dynamic>> getUserGrowthStats() async {
    final userBox = await Hive.openBox<User>('users');
    final users = userBox.values.toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    int todayCount = 0;
    int yesterdayCount = 0;
    int last7DaysCount = 0;
    int last30DaysCount = 0;

    for (var user in users) {
      final createdDate = DateTime(
        user.createdAt.year,
        user.createdAt.month,
        user.createdAt.day,
      );

      if (createdDate.isAtSameMomentAs(today)) {
        todayCount++;
      } else if (createdDate.isAtSameMomentAs(yesterday)) {
        yesterdayCount++;
      }

      if (createdDate.isAfter(weekAgo.subtract(const Duration(days: 1)))) {
        last7DaysCount++;
      }

      if (createdDate.isAfter(monthAgo.subtract(const Duration(days: 1)))) {
        last30DaysCount++;
      }
    }

    // Calculate daily growth for last 30 days
    final dailyGrowth = <DateTime, int>{};
    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      dailyGrowth[date] = 0;
    }

    for (var user in users) {
      final createdDate = DateTime(
        user.createdAt.year,
        user.createdAt.month,
        user.createdAt.day,
      );

      if (createdDate.isAfter(monthAgo.subtract(const Duration(days: 1))) &&
          createdDate.isBefore(today.add(const Duration(days: 1)))) {
        dailyGrowth[createdDate] = (dailyGrowth[createdDate] ?? 0) + 1;
      }
    }

    return {
      'total_users': users.length,
      'today': todayCount,
      'yesterday': yesterdayCount,
      'last_7_days': last7DaysCount,
      'last_30_days': last30DaysCount,
      'daily_growth': dailyGrowth,
    };
  }

  /// Get subscription distribution statistics
  static Future<Map<String, dynamic>> getSubscriptionStats() async {
    final userBox = await Hive.openBox<User>('users');
    final users = userBox.values.toList();

    final tierCounts = <String, int>{
      'free': 0,
      'business': 0,
      'pro': 0,
    };

    for (var user in users) {
      tierCounts[user.subscriptionTier] =
          (tierCounts[user.subscriptionTier] ?? 0) + 1;
    }

    final total = users.length;
    final tierPercentages = <String, double>{};

    tierCounts.forEach((tier, count) {
      tierPercentages[tier] = total > 0 ? (count / total) * 100 : 0.0;
    });

    // Get pending, approved, rejected subscription requests
    final requestBox =
        await Hive.openBox<SubscriptionRequest>('subscription_requests');
    final requests = requestBox.values.toList();

    final requestCounts = <String, int>{
      'pending': 0,
      'approved': 0,
      'rejected': 0,
    };

    for (var request in requests) {
      requestCounts[request.status] = (requestCounts[request.status] ?? 0) + 1;
    }

    return {
      'tier_counts': tierCounts,
      'tier_percentages': tierPercentages,
      'request_counts': requestCounts,
      'conversion_rate': total > 0
          ? ((tierCounts['business']! + tierCounts['pro']!) / total) * 100
          : 0.0,
    };
  }

  /// Get support ticket statistics
  static Future<Map<String, dynamic>> getSupportTicketStats() async {
    final ticketBox = await Hive.openBox<SupportTicket>('support_tickets');
    final tickets = ticketBox.values.toList();

    final statusCounts = <String, int>{
      'open': 0,
      'in_progress': 0,
      'resolved': 0,
      'closed': 0,
    };

    final priorityCounts = <String, int>{
      'low': 0,
      'medium': 0,
      'high': 0,
    };

    int totalResponseTime = 0;
    int ticketsWithResponses = 0;

    for (var ticket in tickets) {
      // Count by status
      statusCounts[ticket.status] = (statusCounts[ticket.status] ?? 0) + 1;

      // Count by priority
      priorityCounts[ticket.priority] =
          (priorityCounts[ticket.priority] ?? 0) + 1;

      // Calculate average response time (for tickets with admin responses)
      final adminResponses = ticket.messages
          .where((msg) => msg.isAdminResponse && !msg.isInternalNote)
          .toList();

      if (adminResponses.isNotEmpty) {
        final firstResponse = adminResponses.first;
        final responseTime =
            firstResponse.timestamp.difference(ticket.createdAt);
        totalResponseTime += responseTime.inHours;
        ticketsWithResponses++;
      }
    }

    final avgResponseTime = ticketsWithResponses > 0
        ? totalResponseTime / ticketsWithResponses
        : 0.0;

    return {
      'total_tickets': tickets.length,
      'status_counts': statusCounts,
      'priority_counts': priorityCounts,
      'avg_response_time_hours': avgResponseTime,
      'high_priority_open': tickets
          .where((t) =>
              t.priority == 'high' &&
              (t.status == 'open' || t.status == 'in_progress'))
          .length,
    };
  }

  /// Get admin activity statistics
  static Future<Map<String, dynamic>> getAdminActivityStats() async {
    final logBox = await Hive.openBox<AdminActivityLog>('admin_activity_logs');
    final logs = logBox.values.toList();

    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final last30Days = now.subtract(const Duration(days: 30));

    final recentLogs =
        logs.where((log) => log.timestamp.isAfter(last7Days)).toList();
    final monthlyLogs =
        logs.where((log) => log.timestamp.isAfter(last30Days)).toList();

    // Count actions by type
    final actionCounts = <String, int>{};
    for (var log in recentLogs) {
      actionCounts[log.action] = (actionCounts[log.action] ?? 0) + 1;
    }

    // Count by admin
    final adminCounts = <String, int>{};
    for (var log in recentLogs) {
      adminCounts[log.adminUsername] =
          (adminCounts[log.adminUsername] ?? 0) + 1;
    }

    // Sort admins by activity
    final sortedAdmins = adminCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total_actions_7_days': recentLogs.length,
      'total_actions_30_days': monthlyLogs.length,
      'action_counts': actionCounts,
      'admin_counts': adminCounts,
      'most_active_admin':
          sortedAdmins.isNotEmpty ? sortedAdmins.first.key : 'N/A',
      'most_active_admin_count':
          sortedAdmins.isNotEmpty ? sortedAdmins.first.value : 0,
    };
  }

  /// Get calculator usage statistics (from activity logs)
  static Future<Map<String, dynamic>> getCalculatorUsageStats() async {
    // Since we don't have dedicated calculator usage tracking,
    // we'll return placeholder data for future implementation

    return {
      'vat_calculations': 0,
      'pit_calculations': 0,
      'cit_calculations': 0,
      'wht_calculations': 0,
      'payroll_calculations': 0,
      'stamp_duty_calculations': 0,
      'total_calculations': 0,
      'note':
          'Calculator usage tracking not yet implemented. Integrate with calculation screens to track usage.',
    };
  }

  /// Get overall system health metrics
  static Future<Map<String, dynamic>> getSystemHealthMetrics() async {
    final userGrowth = await getUserGrowthStats();
    final subscriptions = await getSubscriptionStats();
    final tickets = await getSupportTicketStats();
    final adminActivity = await getAdminActivityStats();

    final totalUsers = userGrowth['total_users'] as int;
    final usersToday = userGrowth['today'] as int;
    final usersYesterday = userGrowth['yesterday'] as int;

    final growthTrend = usersYesterday > 0
        ? ((usersToday - usersYesterday) / usersYesterday) * 100
        : (usersToday > 0 ? 100.0 : 0.0);

    final highPriorityTickets = tickets['high_priority_open'] as int;
    final avgResponseTime = tickets['avg_response_time_hours'] as double;

    String healthStatus = 'Good';
    if (highPriorityTickets > 5 || avgResponseTime > 48) {
      healthStatus = 'Needs Attention';
    } else if (highPriorityTickets > 10 || avgResponseTime > 72) {
      healthStatus = 'Critical';
    }

    return {
      'health_status': healthStatus,
      'total_users': totalUsers,
      'growth_trend_percent': growthTrend,
      'conversion_rate': subscriptions['conversion_rate'],
      'high_priority_tickets': highPriorityTickets,
      'avg_response_time_hours': avgResponseTime,
      'admin_actions_this_week': adminActivity['total_actions_7_days'],
    };
  }
}
