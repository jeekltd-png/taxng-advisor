import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../models/admin_activity_log.dart';
import '../../services/auth_service.dart';
import '../../services/activity_log_service.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String _filterAction = 'all';
  String _filterAdmin = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
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
  }

  Future<void> _exportLogs() async {
    final logs = await ActivityLogService.getAllLogs();
    final csv = ActivityLogService.exportToCSV(logs);

    // In a real app, this would save to file or share
    // For now, just show a dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Logs'),
          content: SingleChildScrollView(
            child: SelectableText(csv),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  List<AdminActivityLog> _filterLogs(List<AdminActivityLog> logs) {
    return logs.where((log) {
      // Action filter
      if (_filterAction != 'all' && log.action != _filterAction) {
        return false;
      }

      // Admin filter
      if (_filterAdmin != 'all' && log.adminUsername != _filterAdmin) {
        return false;
      }

      // Date range filter
      if (_startDate != null && log.timestamp.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null &&
          log.timestamp.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }

      return true;
    }).toList();
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
        title: const Text('Activity Logs'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportLogs,
            tooltip: 'Export to CSV',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clean Up Old Logs'),
                  content: const Text('Delete logs older than 90 days?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ActivityLogService.cleanupOldLogs();
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Old logs deleted successfully')),
                  );
                }
              }
            },
            tooltip: 'Clean Up Old Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red[50],
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Logged in as: ${_currentUser!.username} (${(_currentUser!.adminRole ?? 'ADMIN').toUpperCase()})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterAction,
                        decoration: const InputDecoration(
                          labelText: 'Action Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('All Actions')),
                          DropdownMenuItem(
                              value: 'user_suspended',
                              child: Text('User Suspended')),
                          DropdownMenuItem(
                              value: 'user_activated',
                              child: Text('User Activated')),
                          DropdownMenuItem(
                              value: 'subscription_approved',
                              child: Text('Subscription Approved')),
                          DropdownMenuItem(
                              value: 'subscription_rejected',
                              child: Text('Subscription Rejected')),
                          DropdownMenuItem(
                              value: 'subscription_reviewed',
                              child: Text('Subscription Reviewed')),
                          DropdownMenuItem(
                              value: 'ticket_responded',
                              child: Text('Ticket Responded')),
                          DropdownMenuItem(
                              value: 'ticket_assigned',
                              child: Text('Ticket Assigned')),
                          DropdownMenuItem(
                              value: 'ticket_escalated',
                              child: Text('Ticket Escalated')),
                          DropdownMenuItem(
                              value: 'ticket_closed',
                              child: Text('Ticket Closed')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterAction = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterAdmin,
                        decoration: const InputDecoration(
                          labelText: 'Admin',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('All Admins')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('admin')),
                          DropdownMenuItem(
                              value: 'subadmin1', child: Text('subadmin1')),
                          DropdownMenuItem(
                              value: 'subadmin2', child: Text('subadmin2')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterAdmin = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, y').format(_endDate!)}'
                              : 'Select Date Range',
                        ),
                      ),
                    ),
                    if (_startDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Activity Log List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<AdminActivityLog>('admin_activity_logs')
                  .listenable(),
              builder: (context, Box<AdminActivityLog> box, _) {
                var logs = box.values.toList();
                logs = _filterLogs(logs);

                // Sort by timestamp (newest first)
                logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                if (logs.isEmpty) {
                  return const Center(
                    child: Text('No activity logs found'),
                  );
                }

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final dateStr =
                        DateFormat('MMM d, y h:mm a').format(log.timestamp);

                    IconData actionIcon;
                    Color actionColor;

                    if (log.action.contains('suspended')) {
                      actionIcon = Icons.block;
                      actionColor = Colors.red;
                    } else if (log.action.contains('activated')) {
                      actionIcon = Icons.check_circle;
                      actionColor = Colors.green;
                    } else if (log.action.contains('approved')) {
                      actionIcon = Icons.approval;
                      actionColor = Colors.green;
                    } else if (log.action.contains('rejected')) {
                      actionIcon = Icons.cancel;
                      actionColor = Colors.red;
                    } else if (log.action.contains('ticket')) {
                      actionIcon = Icons.support;
                      actionColor = Colors.blue;
                    } else {
                      actionIcon = Icons.info;
                      actionColor = Colors.grey;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: actionColor.withOpacity(0.2),
                          child: Icon(actionIcon, color: actionColor),
                        ),
                        title: Text(
                          log.getActionDescription(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('By: ${log.adminUsername}'),
                            Text(
                                'Target: ${log.targetUsername ?? log.targetUserId}'),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Details:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...log.details.entries.map((entry) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child:
                                          Text('${entry.key}: ${entry.value}'),
                                    )),
                                const SizedBox(height: 8),
                                Text(
                                  'IP Address: ${log.ipAddress}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Log ID: ${log.id}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Stats Footer
          FutureBuilder<Map<String, dynamic>>(
            future: ActivityLogService.getStatistics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final stats = snapshot.data!;
              final totalLogs = stats['totalLogs'] as int;
              final recentActivity = stats['recentActivity'] as int;
              final actionCounts = stats['actionCounts'] as Map<String, int>;

              final topAction = actionCounts.entries.isEmpty
                  ? 'N/A'
                  : actionCounts.entries
                      .reduce((a, b) => a.value > b.value ? a : b)
                      .key;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Logs', totalLogs.toString(),
                        Icons.history, Colors.blue),
                    _buildStatItem('Last 7 Days', recentActivity.toString(),
                        Icons.trending_up, Colors.green),
                    _buildStatItem('Top Action', topAction.split('_').join(' '),
                        Icons.star, Colors.orange),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
