import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../widgets/common/taxng_app_bar.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  Map<String, dynamic> _userGrowth = {};
  Map<String, dynamic> _subscriptions = {};
  Map<String, dynamic> _tickets = {};
  Map<String, dynamic> _adminActivity = {};
  Map<String, dynamic> _systemHealth = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUser();
    if (user == null || !user.isMainAdmin) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Access denied. Main Admin privileges required.')),
        );
      }
      return;
    }

    setState(() {
      _currentUser = user;
    });

    // Load all analytics data
    final userGrowth = await AnalyticsService.getUserGrowthStats();
    final subscriptions = await AnalyticsService.getSubscriptionStats();
    final tickets = await AnalyticsService.getSupportTicketStats();
    final adminActivity = await AnalyticsService.getAdminActivityStats();
    final systemHealth = await AnalyticsService.getSystemHealthMetrics();

    setState(() {
      _userGrowth = userGrowth;
      _subscriptions = subscriptions;
      _tickets = tickets;
      _adminActivity = adminActivity;
      _systemHealth = systemHealth;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null || _isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: TaxNGAppBar(
        title: 'Analytics Dashboard',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadData();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Health Banner
              _buildSystemHealthBanner(),
              const SizedBox(height: 24),

              // Key Metrics Cards
              _buildKeyMetrics(),
              const SizedBox(height: 24),

              // User Growth Chart
              _buildSectionHeader(
                  'User Growth (Last 30 Days)', Icons.trending_up),
              const SizedBox(height: 16),
              _buildUserGrowthChart(),
              const SizedBox(height: 32),

              // Subscription Distribution
              _buildSectionHeader('Subscription Distribution', Icons.pie_chart),
              const SizedBox(height: 16),
              _buildSubscriptionPieChart(),
              const SizedBox(height: 32),

              // Support Tickets Overview
              _buildSectionHeader('Support Tickets', Icons.support),
              const SizedBox(height: 16),
              _buildTicketStatusChart(),
              const SizedBox(height: 32),

              // Admin Activity
              _buildSectionHeader(
                  'Admin Activity (Last 7 Days)', Icons.admin_panel_settings),
              const SizedBox(height: 16),
              _buildAdminActivityChart(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemHealthBanner() {
    final status = _systemHealth['health_status'] as String? ?? 'Unknown';
    Color color;
    IconData icon;

    switch (status) {
      case 'Good':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Needs Attention':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'Critical':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Health: $status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_systemHealth['total_users']} users • ${_systemHealth['high_priority_tickets']} high priority tickets',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Users Today',
            value: '${_userGrowth['today'] ?? 0}',
            icon: Icons.person_add,
            color: Colors.blue,
            subtitle: '${_userGrowth['last_7_days'] ?? 0} this week',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Conversion Rate',
            value:
                '${(_subscriptions['conversion_rate'] ?? 0.0).toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: Colors.green,
            subtitle: 'Free to Paid',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Avg Response',
            value:
                '${(_tickets['avg_response_time_hours'] ?? 0.0).toStringAsFixed(1)}h',
            icon: Icons.timer,
            color: Colors.orange,
            subtitle: 'Ticket response',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    final dailyGrowth =
        _userGrowth['daily_growth'] as Map<DateTime, int>? ?? {};

    if (dailyGrowth.isEmpty) {
      return _buildEmptyState('No user growth data available');
    }

    final spots = <FlSpot>[];
    final sortedDates = dailyGrowth.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final count = dailyGrowth[date]!;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 ||
                      value.toInt() >= sortedDates.length) {
                    return const Text('');
                  }
                  final date = sortedDates[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
          minY: 0,
        ),
      ),
    );
  }

  Widget _buildSubscriptionPieChart() {
    final tierCounts = _subscriptions['tier_counts'] as Map<String, int>? ?? {};

    if (tierCounts.isEmpty || tierCounts.values.every((c) => c == 0)) {
      return _buildEmptyState('No subscription data available');
    }

    final sections = <PieChartSectionData>[];
    final colors = [Colors.grey, Colors.blue, Colors.purple];
    final tiers = ['free', 'business', 'pro'];

    for (int i = 0; i < tiers.length; i++) {
      final tier = tiers[i];
      final count = tierCounts[tier] ?? 0;
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i],
            value: count.toDouble(),
            title: '$count\n${tier.toUpperCase()}',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  Widget _buildTicketStatusChart() {
    final statusCounts = _tickets['status_counts'] as Map<String, int>? ?? {};

    if (statusCounts.isEmpty || statusCounts.values.every((c) => c == 0)) {
      return _buildEmptyState('No ticket data available');
    }

    final statuses = ['open', 'in_progress', 'resolved', 'closed'];
    final colors = [Colors.red, Colors.orange, Colors.blue, Colors.green];

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < statuses.length; i++) {
      final count = statusCounts[statuses[i]] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: colors[i],
              width: 30,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= statuses.length) {
                    return const Text('');
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      statuses[value.toInt()].toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildAdminActivityChart() {
    final actionCounts =
        _adminActivity['action_counts'] as Map<String, int>? ?? {};

    if (actionCounts.isEmpty) {
      return _buildEmptyState('No admin activity data available');
    }

    // Sort by count descending and take top 5
    final sortedActions = actionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topActions = sortedActions.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Most Active Admin: ${_adminActivity['most_active_admin']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_adminActivity['most_active_admin_count']} actions',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const Divider(height: 24),
          const Text(
            'Top 5 Actions',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...topActions.map((entry) {
            final action = entry.key;
            final count = entry.value;
            final total = _adminActivity['total_actions_7_days'] as int;
            final percentage = total > 0 ? (count / total) * 100 : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        action.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '$count (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    color: Colors.purple[700],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
