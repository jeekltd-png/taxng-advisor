import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../models/email_notification.dart';
import '../../services/auth_service.dart';
import '../../services/email_notification_service.dart';
import '../../widgets/common/taxng_app_bar.dart';
import '../../theme/colors.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String _filterType = 'all';
  String _filterStatus = 'all';

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

  List<EmailNotification> _filterNotifications(
      List<EmailNotification> notifications) {
    return notifications.where((notification) {
      // Type filter
      if (_filterType != 'all' &&
          notification.notificationType != _filterType) {
        return false;
      }

      // Status filter
      if (_filterStatus == 'sent' && !notification.sent) {
        return false;
      } else if (_filterStatus == 'failed' && notification.sent) {
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
      appBar: const TaxNGAppBar(
        title: 'Notification History',
      ),
      body: Column(
        children: [
          // Admin Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: TaxNGColors.primaryLight.withOpacity(0.15),
            child: Row(
              children: [
                Icon(Icons.email, color: TaxNGColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Email Notification History (Simulated)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Info Message
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Email notifications are currently simulated. Integrate with SendGrid, AWS SES, or your preferred provider for production.',
                    style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Types')),
                      DropdownMenuItem(
                          value: 'subscription_approved',
                          child: Text('Subscription Approved')),
                      DropdownMenuItem(
                          value: 'subscription_rejected',
                          child: Text('Subscription Rejected')),
                      DropdownMenuItem(
                          value: 'ticket_update', child: Text('Ticket Update')),
                      DropdownMenuItem(
                          value: 'admin_subscription_request',
                          child: Text('Admin: New Request')),
                      DropdownMenuItem(
                          value: 'admin_ticket_notification',
                          child: Text('Admin: New Ticket')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'sent', child: Text('Sent')),
                      DropdownMenuItem(value: 'failed', child: Text('Failed')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Notification List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<EmailNotification>('email_notifications')
                      .listenable(),
              builder: (context, Box<EmailNotification> box, _) {
                var notifications = box.values.toList();
                notifications = _filterNotifications(notifications);

                // Sort by date (newest first)
                notifications.sort((a, b) => b.sentAt.compareTo(a.sentAt));

                if (notifications.isEmpty) {
                  return const Center(
                    child: Text('No notifications found'),
                  );
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final dateStr = DateFormat('MMM d, y h:mm a')
                        .format(notification.sentAt);

                    IconData icon;
                    Color color;

                    if (notification.notificationType.contains('approved')) {
                      icon = Icons.check_circle;
                      color = Colors.green;
                    } else if (notification.notificationType
                        .contains('rejected')) {
                      icon = Icons.cancel;
                      color = Colors.red;
                    } else if (notification.notificationType
                        .contains('ticket')) {
                      icon = Icons.support;
                      color = Colors.blue;
                    } else if (notification.notificationType
                        .contains('admin')) {
                      icon = Icons.admin_panel_settings;
                      color = Colors.purple;
                    } else {
                      icon = Icons.email;
                      color = Colors.grey;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: notification.sent
                              ? color.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          child: Icon(
                            notification.sent ? icon : Icons.error,
                            color: notification.sent ? color : Colors.red,
                          ),
                        ),
                        title: Text(
                          notification.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'To: ${notification.recipientName} (${notification.recipientEmail})'),
                            Row(
                              children: [
                                Icon(
                                  notification.sent ? Icons.check : Icons.error,
                                  size: 14,
                                  color: notification.sent
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  notification.sent ? 'Sent' : 'Failed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: notification.sent
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
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
                                  'Email Body:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    notification.body,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                if (!notification.sent &&
                                    notification.errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Error:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
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
            future: EmailNotificationService.getStatistics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final stats = snapshot.data!;
              final total = stats['total'] as int;
              final sent = stats['sent'] as int;
              final failed = stats['failed'] as int;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        'Total', total.toString(), Icons.email, Colors.blue),
                    _buildStatItem('Sent', sent.toString(), Icons.check_circle,
                        Colors.green),
                    _buildStatItem(
                        'Failed', failed.toString(), Icons.error, Colors.red),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
