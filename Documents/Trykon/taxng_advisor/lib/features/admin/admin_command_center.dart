import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../services/user_activity_tracker.dart';
import '../../models/user_activity.dart';
import '../../theme/colors.dart';

/// Admin Command Center — comprehensive dashboard for monitoring
/// user activities, ratings, end-to-end usage, and app health.
class AdminCommandCenter extends StatefulWidget {
  const AdminCommandCenter({super.key});

  @override
  State<AdminCommandCenter> createState() => _AdminCommandCenterState();
}

class _AdminCommandCenterState extends State<AdminCommandCenter>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  // Data
  Map<String, dynamic> _systemHealth = {};
  // ignore: unused_field
  Map<String, dynamic> _userGrowth = {};
  Map<String, dynamic> _activityStats = {};
  Map<String, dynamic> _subscriptionStats = {};
  List<UserActivity> _recentActivities = [];
  List<UserActivity> _recentRatings = [];
  Map<String, dynamic> _userJourneyStats = {};

  // Filters
  String _timeFilter = '7d';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Check admin access
      final user = await AuthService.currentUser();
      if (user == null || !user.isAdmin) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access denied. Admin privileges required.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Determine date range from filter
      final now = DateTime.now();
      DateTime? startDate;
      switch (_timeFilter) {
        case '24h':
          startDate = now.subtract(const Duration(hours: 24));
          break;
        case '7d':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case '30d':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case '90d':
          startDate = now.subtract(const Duration(days: 90));
          break;
        default:
          startDate = null; // All time
      }

      // Load all data concurrently
      final results = await Future.wait([
        AnalyticsService.getSystemHealthMetrics(),
        AnalyticsService.getUserGrowthStats(),
        UserActivityTracker.getActivityStatistics(startDate: startDate),
        AnalyticsService.getSubscriptionStats(),
        UserActivityTracker.getAllActivities(startDate: startDate),
        UserActivityTracker.getAllActivities(activityType: 'rating'),
        _computeUserJourneyStats(startDate),
      ]);

      if (mounted) {
        setState(() {
          _systemHealth = results[0] as Map<String, dynamic>;
          _userGrowth = results[1] as Map<String, dynamic>;
          _activityStats = results[2] as Map<String, dynamic>;
          _subscriptionStats = results[3] as Map<String, dynamic>;
          _recentActivities =
              (results[4] as List<UserActivity>).take(100).toList();
          _recentRatings = (results[5] as List<UserActivity>).take(50).toList();
          _userJourneyStats = results[6] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Compute user journey / end-to-end usage statistics
  static Future<Map<String, dynamic>> _computeUserJourneyStats(
      DateTime? startDate) async {
    try {
      final allActivities =
          await UserActivityTracker.getAllActivities(startDate: startDate);

      // Group activities by user
      final userActivities = <String, List<UserActivity>>{};
      for (final a in allActivities) {
        userActivities.putIfAbsent(a.userId, () => []).add(a);
      }

      int usersWhoCalculated = 0;
      int usersWhoImported = 0;
      int usersWhoRated = 0;
      int usersWithMultipleCalcTypes = 0;
      int totalSessionDurationMinutes = 0;
      int sessionCount = 0;

      final calcTypesPerUser = <String, Set<String>>{};

      for (final entry in userActivities.entries) {
        final activities = entry.value;
        final userId = entry.key;

        bool hasCalc = false;
        bool hasImport = false;
        bool hasRating = false;

        calcTypesPerUser.putIfAbsent(userId, () => {});

        // Track sessions (login→logout pairs)
        DateTime? lastLogin;
        for (final a in activities) {
          if (a.activityType == 'calculator_use') {
            hasCalc = true;
            if (a.calculatorType != null) {
              calcTypesPerUser[userId]!.add(a.calculatorType!);
            }
          }
          if (a.activityType == 'data_import') hasImport = true;
          if (a.activityType == 'rating') hasRating = true;

          if (a.activityType == 'login') {
            lastLogin = a.timestamp;
          }
          if (a.activityType == 'logout' && lastLogin != null) {
            totalSessionDurationMinutes +=
                a.timestamp.difference(lastLogin).inMinutes;
            sessionCount++;
            lastLogin = null;
          }
        }

        if (hasCalc) usersWhoCalculated++;
        if (hasImport) usersWhoImported++;
        if (hasRating) usersWhoRated++;
        if (calcTypesPerUser[userId]!.length > 1) {
          usersWithMultipleCalcTypes++;
        }
      }

      final totalUsers = userActivities.length;
      final avgSessionMinutes =
          sessionCount > 0 ? totalSessionDurationMinutes / sessionCount : 0;

      return {
        'total_active_users': totalUsers,
        'users_who_calculated': usersWhoCalculated,
        'users_who_imported': usersWhoImported,
        'users_who_rated': usersWhoRated,
        'users_multi_calc': usersWithMultipleCalcTypes,
        'calc_engagement_rate':
            totalUsers > 0 ? (usersWhoCalculated / totalUsers * 100) : 0.0,
        'import_engagement_rate':
            totalUsers > 0 ? (usersWhoImported / totalUsers * 100) : 0.0,
        'rating_rate':
            totalUsers > 0 ? (usersWhoRated / totalUsers * 100) : 0.0,
        'avg_session_minutes': avgSessionMinutes,
        'total_sessions': sessionCount,
      };
    } catch (e) {
      return {
        'total_active_users': 0,
        'users_who_calculated': 0,
        'calc_engagement_rate': 0.0,
        'avg_session_minutes': 0,
        'total_sessions': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
      appBar: AppBar(
        title: const Text('Admin Command Center'),
        backgroundColor: TaxNGColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TaxNGColors.accent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(
                icon: Icon(Icons.dashboard_rounded, size: 20),
                text: 'Overview'),
            Tab(icon: Icon(Icons.people_rounded, size: 20), text: 'Users'),
            Tab(icon: Icon(Icons.star_rounded, size: 20), text: 'Ratings'),
            Tab(icon: Icon(Icons.route_rounded, size: 20), text: 'Journeys'),
          ],
        ),
        actions: [
          // Time filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            tooltip: 'Filter by time',
            onSelected: (value) {
              setState(() => _timeFilter = value);
              _loadAllData();
            },
            itemBuilder: (_) => [
              _filterMenuItem('24h', 'Last 24 Hours'),
              _filterMenuItem('7d', 'Last 7 Days'),
              _filterMenuItem('30d', 'Last 30 Days'),
              _filterMenuItem('90d', 'Last 90 Days'),
              _filterMenuItem('all', 'All Time'),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh data',
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(isDark)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isDark),
                    _buildUsersTab(isDark),
                    _buildRatingsTab(isDark),
                    _buildJourneysTab(isDark),
                  ],
                ),
    );
  }

  PopupMenuItem<String> _filterMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (_timeFilter == value)
            const Icon(Icons.check, color: TaxNGColors.primary, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64,
                color: isDark ? Colors.white38 : TaxNGColors.textLight),
            const SizedBox(height: 16),
            Text('Failed to load analytics',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : TaxNGColors.textDark)),
            const SizedBox(height: 8),
            Text(_error ?? 'Unknown error',
                style: TextStyle(
                    color: isDark ? Colors.white54 : TaxNGColors.textLight)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TaxNGColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── OVERVIEW TAB ───────────────────────────────────────────────────

  Widget _buildOverviewTab(bool isDark) {
    final healthStatus = _systemHealth['health_status'] ?? 'Unknown';
    final totalUsers = _systemHealth['total_users'] ?? 0;
    final growthTrend =
        (_systemHealth['growth_trend_percent'] as num?)?.toDouble() ?? 0.0;
    final conversionRate =
        (_systemHealth['conversion_rate'] as num?)?.toDouble() ?? 0.0;

    final totalActivities = _activityStats['total_activities'] ?? 0;
    final totalCalcUses = _activityStats['total_calculator_uses'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Health Badge
            _buildHealthBanner(healthStatus, isDark),
            const SizedBox(height: 16),

            // KPI Grid
            _buildSectionTitle('Key Metrics', isDark),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _KPICard(
                  title: 'Total Users',
                  value: '$totalUsers',
                  trend: growthTrend,
                  icon: Icons.people_alt_rounded,
                  color: TaxNGColors.primary,
                  isDark: isDark,
                ),
                _KPICard(
                  title: 'Conversion Rate',
                  value: '${conversionRate.toStringAsFixed(1)}%',
                  icon: Icons.trending_up_rounded,
                  color: TaxNGColors.info,
                  isDark: isDark,
                ),
                _KPICard(
                  title: 'Total Activities',
                  value: _formatCount(totalActivities),
                  icon: Icons.touch_app_rounded,
                  color: TaxNGColors.secondary,
                  isDark: isDark,
                ),
                _KPICard(
                  title: 'Calculations',
                  value: _formatCount(totalCalcUses),
                  icon: Icons.calculate_rounded,
                  color: TaxNGColors.accent,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Calculator Usage Breakdown
            _buildSectionTitle('Calculator Usage', isDark),
            const SizedBox(height: 8),
            _buildCalculatorUsageChart(isDark),
            const SizedBox(height: 20),

            // Recent Activity Feed
            _buildSectionTitle('Recent Activity Feed', isDark),
            const SizedBox(height: 8),
            _buildActivityFeed(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBanner(String status, bool isDark) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String description;

    switch (status) {
      case 'Critical':
        bgColor = TaxNGColors.error.withValues(alpha: 0.1);
        textColor = TaxNGColors.error;
        icon = Icons.warning_rounded;
        description = 'System requires immediate attention';
        break;
      case 'Needs Attention':
        bgColor = TaxNGColors.warning.withValues(alpha: 0.1);
        textColor = TaxNGColors.warning;
        icon = Icons.info_rounded;
        description = 'Some metrics need review';
        break;
      default:
        bgColor = TaxNGColors.success.withValues(alpha: 0.1);
        textColor = TaxNGColors.success;
        icon = Icons.check_circle_rounded;
        description = 'All systems operating normally';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System Health: $status',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: textColor)),
                const SizedBox(height: 2),
                Text(description,
                    style: TextStyle(fontSize: 12, color: textColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: textColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_timeFilter.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorUsageChart(bool isDark) {
    final calcCounts =
        (_activityStats['calculator_counts'] as Map<String, int>?) ?? {};

    final calcData = <String, int>{
      'VAT': calcCounts['vat'] ?? 0,
      'PIT': calcCounts['pit'] ?? 0,
      'CIT': calcCounts['cit'] ?? 0,
      'WHT': calcCounts['wht'] ?? 0,
      'Payroll': calcCounts['payroll'] ?? 0,
      'Stamp': calcCounts['stamp_duty'] ?? 0,
    };

    final colors = [
      const Color(0xFF16A34A),
      const Color(0xFF0D9488),
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
    ];

    final totalCalc = calcData.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: totalCalc == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No calculator usage data yet',
                    style: TextStyle(
                        color:
                            isDark ? Colors.white54 : TaxNGColors.textLight)),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: List.generate(calcData.length, (i) {
                        final entry = calcData.entries.elementAt(i);
                        final pct = totalCalc > 0
                            ? (entry.value / totalCalc * 100)
                            : 0.0;
                        return PieChartSectionData(
                          color: colors[i],
                          value: entry.value.toDouble(),
                          title: pct > 5 ? '${pct.toStringAsFixed(0)}%' : '',
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                          radius: 50,
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: List.generate(calcData.length, (i) {
                    final entry = calcData.entries.elementAt(i);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: colors[i], shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text('${entry.key}: ${entry.value}',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white70
                                    : TaxNGColors.textMedium)),
                      ],
                    );
                  }),
                ),
              ],
            ),
    );
  }

  Widget _buildActivityFeed(bool isDark) {
    if (_recentActivities.isEmpty) {
      return _buildEmptyCard('No recent activities', isDark);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentActivities.take(20).length,
        separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark ? Colors.white12 : TaxNGColors.borderLight),
        itemBuilder: (_, i) {
          final a = _recentActivities[i];
          return _ActivityTile(activity: a, isDark: isDark);
        },
      ),
    );
  }

  // ─── USERS TAB ──────────────────────────────────────────────────────

  Widget _buildUsersTab(bool isDark) {
    final uniqueUsers = _activityStats['unique_users'] ?? 0;
    final logins = _activityStats['logins'] ?? 0;
    final logouts = _activityStats['logouts'] ?? 0;
    final downloads = _activityStats['downloads'] ?? 0;
    final pageViews = _activityStats['page_views'] ?? 0;
    final feedbackCount = _activityStats['feedback_submissions'] ?? 0;
    final deviceCounts =
        (_activityStats['device_counts'] as Map<String, int>?) ?? {};

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User engagement KPIs
            _buildSectionTitle('User Engagement', isDark),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _MiniKPI(
                    label: 'Active Users',
                    value: '$uniqueUsers',
                    icon: Icons.person_rounded,
                    color: TaxNGColors.primary,
                    isDark: isDark),
                _MiniKPI(
                    label: 'Logins',
                    value: '$logins',
                    icon: Icons.login_rounded,
                    color: TaxNGColors.info,
                    isDark: isDark),
                _MiniKPI(
                    label: 'Downloads',
                    value: '$downloads',
                    icon: Icons.download_rounded,
                    color: TaxNGColors.secondary,
                    isDark: isDark),
                _MiniKPI(
                    label: 'Page Views',
                    value: _formatCount(pageViews),
                    icon: Icons.visibility_rounded,
                    color: TaxNGColors.accent,
                    isDark: isDark),
                _MiniKPI(
                    label: 'Feedback',
                    value: '$feedbackCount',
                    icon: Icons.feedback_rounded,
                    color: TaxNGColors.warning,
                    isDark: isDark),
                _MiniKPI(
                    label: 'Logouts',
                    value: '$logouts',
                    icon: Icons.logout_rounded,
                    color: TaxNGColors.error,
                    isDark: isDark),
              ],
            ),
            const SizedBox(height: 20),

            // Subscription Distribution
            _buildSectionTitle('Subscription Distribution', isDark),
            const SizedBox(height: 8),
            _buildSubscriptionDistribution(isDark),
            const SizedBox(height: 20),

            // Device Breakdown
            _buildSectionTitle('Platform Distribution', isDark),
            const SizedBox(height: 8),
            _buildDeviceBreakdown(deviceCounts, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDistribution(bool isDark) {
    final tierCounts =
        (_subscriptionStats['tier_counts'] as Map<String, int>?) ?? {};
    final tierPercentages =
        (_subscriptionStats['tier_percentages'] as Map<String, double>?) ?? {};
    final requestCounts =
        (_subscriptionStats['request_counts'] as Map<String, int>?) ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: Column(
        children: [
          ...tierCounts.entries.map((e) {
            final pct = tierPercentages[e.key] ?? 0.0;
            final color = _getTierColor(e.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                      width: 12,
                      height: 12,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${e.key[0].toUpperCase()}${e.key.substring(1)} Plan',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : TaxNGColors.textDark),
                    ),
                  ),
                  Text('${e.value} (${pct.toStringAsFixed(1)}%)',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ],
              ),
            );
          }),
          if (requestCounts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.white12 : TaxNGColors.borderLight),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _RequestBadge(
                    label: 'Pending',
                    count: requestCounts['pending'] ?? 0,
                    color: TaxNGColors.warning),
                _RequestBadge(
                    label: 'Approved',
                    count: requestCounts['approved'] ?? 0,
                    color: TaxNGColors.success),
                _RequestBadge(
                    label: 'Rejected',
                    count: requestCounts['rejected'] ?? 0,
                    color: TaxNGColors.error),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceBreakdown(Map<String, int> deviceCounts, bool isDark) {
    if (deviceCounts.isEmpty) {
      return _buildEmptyCard('No device data yet', isDark);
    }

    final total = deviceCounts.values.fold(0, (a, b) => a + b);
    final deviceIcons = {
      'Web': Icons.language_rounded,
      'Android': Icons.phone_android_rounded,
      'iOS': Icons.phone_iphone_rounded,
      'Windows': Icons.desktop_windows_rounded,
      'macOS': Icons.laptop_mac_rounded,
      'Linux': Icons.computer_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: Column(
        children: deviceCounts.entries.map((e) {
          final pct = total > 0 ? (e.value / total) : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(deviceIcons[e.key] ?? Icons.devices_rounded,
                    size: 20,
                    color: isDark ? Colors.white54 : TaxNGColors.textMedium),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white
                                  : TaxNGColors.textDark)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor:
                              isDark ? Colors.white12 : TaxNGColors.borderLight,
                          valueColor:
                              const AlwaysStoppedAnimation(TaxNGColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text('${e.value} (${(pct * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.white54 : TaxNGColors.textLight)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── RATINGS TAB ────────────────────────────────────────────────────

  Widget _buildRatingsTab(bool isDark) {
    final avgRating =
        (_activityStats['average_rating'] as num?)?.toDouble() ?? 0.0;
    final ratingCounts =
        (_activityStats['rating_counts'] as Map<int, int>?) ?? {};
    final totalRatings = _activityStats['ratings_submitted'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Average Rating Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: TaxNGColors.heroGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Average Rating',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w800)),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < avgRating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 22,
                          );
                        }),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text('$totalRatings',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700)),
                      const Text('Total Ratings',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rating Distribution
            _buildSectionTitle('Rating Distribution', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF2A2A3E)
                        : TaxNGColors.borderLight),
              ),
              child: Column(
                children: List.generate(5, (i) {
                  final stars = 5 - i;
                  final count = ratingCounts[stars] ?? 0;
                  final pct = totalRatings > 0 ? (count / totalRatings) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text('$stars',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : TaxNGColors.textDark)),
                        ),
                        const Icon(Icons.star_rounded,
                            size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 10,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : TaxNGColors.borderLight,
                              valueColor:
                                  AlwaysStoppedAnimation(_getStarColor(stars)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 60,
                          child: Text(
                            '$count (${(pct * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : TaxNGColors.textLight),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Recent Ratings Feed
            _buildSectionTitle('Recent Ratings', isDark),
            const SizedBox(height: 8),
            if (_recentRatings.isEmpty)
              _buildEmptyCard('No ratings yet', isDark)
            else
              ..._recentRatings
                  .take(20)
                  .map((r) => _RatingTile(rating: r, isDark: isDark)),
          ],
        ),
      ),
    );
  }

  // ─── USER JOURNEYS TAB ──────────────────────────────────────────────

  Widget _buildJourneysTab(bool isDark) {
    final activeUsers = _userJourneyStats['total_active_users'] ?? 0;
    debugPrint('Active users for journey tab: $activeUsers');
    final calcEngagement =
        (_userJourneyStats['calc_engagement_rate'] as num?)?.toDouble() ?? 0.0;
    final importEngagement =
        (_userJourneyStats['import_engagement_rate'] as num?)?.toDouble() ??
            0.0;
    final ratingRate =
        (_userJourneyStats['rating_rate'] as num?)?.toDouble() ?? 0.0;
    final avgSession =
        (_userJourneyStats['avg_session_minutes'] as num?)?.toDouble() ?? 0.0;
    final totalSessions = _userJourneyStats['total_sessions'] ?? 0;
    final multiCalcUsers = _userJourneyStats['users_multi_calc'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('End-to-End Usage Funnel', isDark),
            const SizedBox(height: 8),
            _buildFunnelChart(isDark),
            const SizedBox(height: 20),

            _buildSectionTitle('Session Analytics', isDark),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _KPICard(
                  title: 'Avg Session',
                  value: '${avgSession.toStringAsFixed(0)} min',
                  icon: Icons.timer_rounded,
                  color: TaxNGColors.info,
                  isDark: isDark,
                ),
                _KPICard(
                  title: 'Total Sessions',
                  value: _formatCount(totalSessions),
                  icon: Icons.login_rounded,
                  color: TaxNGColors.secondary,
                  isDark: isDark,
                ),
                _KPICard(
                  title: 'Calc Engagement',
                  value: '${calcEngagement.toStringAsFixed(0)}%',
                  icon: Icons.calculate_rounded,
                  color: TaxNGColors.primary,
                  isDark: isDark,
                ),
                _KPICard(
                  title: 'Multi-Calc Users',
                  value: '$multiCalcUsers',
                  icon: Icons.stacked_bar_chart_rounded,
                  color: TaxNGColors.accent,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Engagement Insights
            _buildSectionTitle('Engagement Insights', isDark),
            const SizedBox(height: 8),
            _InsightCard(
              icon: Icons.calculate_rounded,
              title: 'Calculator Adoption',
              value: '${calcEngagement.toStringAsFixed(1)}% of users',
              description:
                  'Users who performed at least one calculation in this period',
              color: TaxNGColors.primary,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _InsightCard(
              icon: Icons.upload_file_rounded,
              title: 'Data Import Adoption',
              value: '${importEngagement.toStringAsFixed(1)}% of users',
              description:
                  'Users who imported data via CSV/Excel in this period',
              color: TaxNGColors.secondary,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _InsightCard(
              icon: Icons.star_rounded,
              title: 'Rating Participation',
              value: '${ratingRate.toStringAsFixed(1)}% of users',
              description: 'Users who submitted an app rating',
              color: TaxNGColors.warning,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelChart(bool isDark) {
    final activeUsers = _userJourneyStats['total_active_users'] ?? 0;
    final usersWhoCalc = _userJourneyStats['users_who_calculated'] ?? 0;
    final usersWhoImport = _userJourneyStats['users_who_imported'] ?? 0;
    final usersWhoRated = _userJourneyStats['users_who_rated'] ?? 0;

    final stages = [
      _FunnelStage('Registered & Active', activeUsers, TaxNGColors.primary),
      _FunnelStage('Used Calculator', usersWhoCalc, TaxNGColors.info),
      _FunnelStage('Imported Data', usersWhoImport, TaxNGColors.secondary),
      _FunnelStage('Submitted Rating', usersWhoRated, TaxNGColors.warning),
    ];

    final maxVal = activeUsers > 0 ? activeUsers : 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: Column(
        children: stages.map((stage) {
          final pct = maxVal > 0 ? (stage.count / maxVal) : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(stage.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? Colors.white : TaxNGColors.textDark)),
                    Text('${stage.count}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: stage.color)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 14,
                    backgroundColor:
                        isDark ? Colors.white12 : TaxNGColors.borderLight,
                    valueColor: AlwaysStoppedAnimation(stage.color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : TaxNGColors.textDark,
            letterSpacing: -0.3));
  }

  Widget _buildEmptyCard(String message, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: Text(message,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isDark ? Colors.white54 : TaxNGColors.textLight)),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'free':
        return TaxNGColors.textLight;
      case 'business':
        return TaxNGColors.info;
      case 'pro':
        return TaxNGColors.primary;
      case 'enterprise':
        return TaxNGColors.accent;
      default:
        return TaxNGColors.textMedium;
    }
  }

  Color _getStarColor(int stars) {
    if (stars >= 4) return TaxNGColors.success;
    if (stars == 3) return TaxNGColors.warning;
    return TaxNGColors.error;
  }
}

// ─── PRIVATE WIDGET CLASSES ──────────────────────────────────────────

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final double? trend;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _KPICard({
    required this.title,
    required this.value,
    this.trend,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              if (trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trend! >= 0
                        ? TaxNGColors.success.withValues(alpha: 0.1)
                        : TaxNGColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend! >= 0
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 12,
                        color: trend! >= 0
                            ? TaxNGColors.success
                            : TaxNGColors.error,
                      ),
                      Text(
                        '${trend!.abs().toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: trend! >= 0
                              ? TaxNGColors.success
                              : TaxNGColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : TaxNGColors.textDark)),
          Text(title,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : TaxNGColors.textLight)),
        ],
      ),
    );
  }
}

class _MiniKPI extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MiniKPI({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : TaxNGColors.textDark)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white54 : TaxNGColors.textLight),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final UserActivity activity;
  final bool isDark;

  const _ActivityTile({required this.activity, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final typeInfo = _getActivityTypeInfo(activity.activityType);
    final timeAgo = _formatTimeAgo(activity.timestamp);

    return ListTile(
      dense: true,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: typeInfo.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(typeInfo.icon, size: 18, color: typeInfo.color),
      ),
      title: Text(
        '${activity.username} • ${typeInfo.label}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : TaxNGColors.textDark,
        ),
      ),
      subtitle: Text(
        [
          if (activity.calculatorType != null)
            activity.calculatorType!.toUpperCase(),
          if (activity.details != null && activity.details!.length <= 50)
            activity.details!,
          timeAgo,
        ].join(' · '),
        style: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.white38 : TaxNGColors.textLight,
        ),
      ),
      trailing: activity.rating != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${activity.rating}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Icon(Icons.star_rounded,
                    size: 14, color: Color(0xFFF59E0B)),
              ],
            )
          : null,
    );
  }

  _ActivityTypeInfo _getActivityTypeInfo(String type) {
    switch (type) {
      case 'login':
        return _ActivityTypeInfo(
            'Login', Icons.login_rounded, TaxNGColors.info);
      case 'logout':
        return _ActivityTypeInfo(
            'Logout', Icons.logout_rounded, TaxNGColors.textMedium);
      case 'calculator_use':
        return _ActivityTypeInfo(
            'Calculation', Icons.calculate_rounded, TaxNGColors.primary);
      case 'rating':
        return _ActivityTypeInfo(
            'Rating', Icons.star_rounded, const Color(0xFFF59E0B));
      case 'feedback':
        return _ActivityTypeInfo(
            'Feedback', Icons.feedback_rounded, TaxNGColors.secondary);
      case 'download':
        return _ActivityTypeInfo(
            'Download', Icons.download_rounded, TaxNGColors.accent);
      case 'data_import':
        return _ActivityTypeInfo(
            'Import', Icons.upload_file_rounded, TaxNGColors.info);
      case 'page_view':
        return _ActivityTypeInfo(
            'Page View', Icons.visibility_rounded, TaxNGColors.textLight);
      default:
        return _ActivityTypeInfo(
            type, Icons.circle_rounded, TaxNGColors.textMedium);
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(timestamp);
  }
}

class _ActivityTypeInfo {
  final String label;
  final IconData icon;
  final Color color;
  _ActivityTypeInfo(this.label, this.icon, this.color);
}

class _RatingTile extends StatelessWidget {
  final UserActivity rating;
  final bool isDark;

  const _RatingTile({required this.rating, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < (rating.rating ?? 0)
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 18,
                    color: const Color(0xFFF59E0B),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rating.username,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : TaxNGColors.textDark)),
                if (rating.details != null && rating.details!.isNotEmpty)
                  Text(rating.details!,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.white54 : TaxNGColors.textMedium),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            DateFormat('dd/MM').format(rating.timestamp),
            style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : TaxNGColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _RequestBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _RequestBadge(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16, color: color)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String description;
  final Color color;
  final bool isDark;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : TaxNGColors.textDark)),
                Text(value,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color)),
                Text(description,
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            isDark ? Colors.white38 : TaxNGColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelStage {
  final String label;
  final int count;
  final Color color;
  _FunnelStage(this.label, this.count, this.color);
}
