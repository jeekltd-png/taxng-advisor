import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/user_activity_tracker.dart';
import '../../models/user_activity.dart';

/// Admin-Only User Activity Tracker Screen
///
/// Displays comprehensive user activity metrics including:
/// - App downloads
/// - Calculator usage statistics
/// - Login/Logout tracking
/// - Feedback submissions
/// - App ratings
class AdminUserActivityScreen extends StatefulWidget {
  const AdminUserActivityScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserActivityScreen> createState() =>
      _AdminUserActivityScreenState();
}

class _AdminUserActivityScreenState extends State<AdminUserActivityScreen> {
  User? _currentUser;
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  List<UserActivity> _recentActivities = [];

  String _selectedFilter = 'all'; // all, today, week, month
  String _selectedActivityType = 'all';

  @override
  void initState() {
    super.initState();
    _checkAccessAndLoad();
  }

  Future<void> _checkAccessAndLoad() async {
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

    setState(() {
      _currentUser = user;
    });

    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    DateTime? startDate;
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        break;
    }

    final statistics = await UserActivityTracker.getActivityStatistics(
      startDate: startDate,
    );

    final activities = await UserActivityTracker.getAllActivities(
      activityType:
          _selectedActivityType != 'all' ? _selectedActivityType : null,
      startDate: startDate,
    );

    setState(() {
      _statistics = statistics;
      _recentActivities = activities.take(50).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Activity Tracker'),
        backgroundColor: Colors.deepPurple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Info Banner
                    _buildAdminBanner(),
                    const SizedBox(height: 16),

                    // Filters
                    _buildFilters(),
                    const SizedBox(height: 24),

                    // Overview Cards
                    _buildOverviewCards(),
                    const SizedBox(height: 24),

                    // Calculator Usage
                    _buildCalculatorUsageSection(),
                    const SizedBox(height: 24),

                    // Ratings Section
                    _buildRatingsSection(),
                    const SizedBox(height: 24),

                    // Device Distribution
                    _buildDeviceSection(),
                    const SizedBox(height: 24),

                    // Recent Activities
                    _buildRecentActivitiesSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAdminBanner() {
    return Card(
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.deepPurple[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin User Activity Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                    ),
                  ),
                  Text(
                    'Logged in as: ${_currentUser!.username}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.deepPurple[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedFilter,
                    decoration: const InputDecoration(
                      labelText: 'Time Period',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Time')),
                      DropdownMenuItem(value: 'today', child: Text('Today')),
                      DropdownMenuItem(
                          value: 'week', child: Text('Last 7 Days')),
                      DropdownMenuItem(
                          value: 'month', child: Text('Last 30 Days')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedFilter = value!);
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedActivityType,
                    decoration: const InputDecoration(
                      labelText: 'Activity Type',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Activities')),
                      DropdownMenuItem(
                          value: 'download', child: Text('Downloads')),
                      DropdownMenuItem(value: 'login', child: Text('Logins')),
                      DropdownMenuItem(value: 'logout', child: Text('Logouts')),
                      DropdownMenuItem(
                          value: 'calculator_use',
                          child: Text('Calculator Use')),
                      DropdownMenuItem(
                          value: 'feedback', child: Text('Feedback')),
                      DropdownMenuItem(value: 'rating', child: Text('Ratings')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedActivityType = value!);
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final downloads = _statistics['downloads'] ?? 0;
    final logins = _statistics['logins'] ?? 0;
    final logouts = _statistics['logouts'] ?? 0;
    final feedback = _statistics['feedback_submissions'] ?? 0;
    final ratings = _statistics['ratings_submitted'] ?? 0;
    final uniqueUsers = _statistics['unique_users'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Downloads', downloads, Icons.download, Colors.blue),
        _buildMetricCard(
            'Unique Users', uniqueUsers, Icons.people, Colors.green),
        _buildMetricCard('Logins', logins, Icons.login, Colors.orange),
        _buildMetricCard('Logouts', logouts, Icons.logout, Colors.red),
        _buildMetricCard('Feedback', feedback, Icons.feedback, Colors.purple),
        _buildMetricCard('Ratings', ratings, Icons.star, Colors.amber),
      ],
    );
  }

  Widget _buildMetricCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorUsageSection() {
    final calculatorCounts = _statistics['calculator_counts'] as Map? ?? {};
    final totalUses = _statistics['total_calculator_uses'] ?? 0;

    final calculators = [
      {'key': 'vat', 'name': 'VAT', 'icon': Icons.receipt_long},
      {'key': 'pit', 'name': 'PIT', 'icon': Icons.person},
      {'key': 'cit', 'name': 'CIT', 'icon': Icons.business},
      {'key': 'wht', 'name': 'WHT', 'icon': Icons.account_balance},
      {'key': 'payroll', 'name': 'Payroll', 'icon': Icons.payment},
      {'key': 'stamp_duty', 'name': 'Stamp Duty', 'icon': Icons.gavel},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Calculator Usage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total: $totalUses',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...calculators.map((calc) {
              final count = calculatorCounts[calc['key']] ?? 0;
              final percentage =
                  totalUses > 0 ? (count / totalUses) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(calc['icon'] as IconData, size: 20),
                        const SizedBox(width: 8),
                        Text(calc['name'] as String,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text('$count uses (${percentage.toStringAsFixed(1)}%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: totalUses > 0 ? count / totalUses : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsSection() {
    final averageRating = _statistics['average_rating'] ?? 0.0;
    final ratingCounts = _statistics['rating_counts'] as Map? ?? {};
    final totalRatings = _statistics['ratings_submitted'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Ratings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < averageRating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalRatings ratings',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      for (int i = 5; i >= 1; i--)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text('$i⭐'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: totalRatings > 0
                                      ? (ratingCounts[i] ?? 0) / totalRatings
                                      : 0,
                                  backgroundColor: Colors.grey[200],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.amber),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${ratingCounts[i] ?? 0}'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSection() {
    final deviceCounts = _statistics['device_counts'] as Map? ?? {};

    if (deviceCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...deviceCounts.entries.map((entry) {
              final total = deviceCounts.values
                  .fold<int>(0, (sum, count) => sum + (count as int));
              final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: total > 0 ? entry.value / total : 0,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Showing ${_recentActivities.length} most recent activities',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            if (_recentActivities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No activities found'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentActivities.length,
                itemBuilder: (context, index) {
                  final activity = _recentActivities[index];
                  return _buildActivityTile(activity);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(UserActivity activity) {
    IconData icon;
    Color color;

    switch (activity.activityType) {
      case 'download':
        icon = Icons.download;
        color = Colors.blue;
        break;
      case 'login':
        icon = Icons.login;
        color = Colors.green;
        break;
      case 'logout':
        icon = Icons.logout;
        color = Colors.orange;
        break;
      case 'calculator_use':
        icon = Icons.calculate;
        color = Colors.purple;
        break;
      case 'feedback':
        icon = Icons.feedback;
        color = Colors.teal;
        break;
      case 'rating':
        icon = Icons.star;
        color = Colors.amber;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        activity.username,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _getActivityDescription(activity),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        DateFormat('MMM d, h:mm a').format(activity.timestamp),
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
    );
  }

  String _getActivityDescription(UserActivity activity) {
    switch (activity.activityType) {
      case 'download':
        return 'Downloaded app on ${activity.deviceInfo}';
      case 'login':
        return 'Logged in';
      case 'logout':
        return 'Logged out';
      case 'calculator_use':
        return 'Used ${activity.calculatorType?.toUpperCase()} calculator';
      case 'feedback':
        return 'Submitted feedback';
      case 'rating':
        return 'Rated app ${activity.rating}⭐';
      default:
        return activity.activityType;
    }
  }
}
