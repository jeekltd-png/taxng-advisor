import 'package:flutter/material.dart';
import 'package:taxng_advisor/models/user.dart';
import 'package:taxng_advisor/services/whatsapp_service.dart';
import 'package:taxng_advisor/services/hive_service.dart';

class WhatsAppSettingsScreen extends StatefulWidget {
  const WhatsAppSettingsScreen({super.key});

  @override
  State<WhatsAppSettingsScreen> createState() => _WhatsAppSettingsScreenState();
}

class _WhatsAppSettingsScreenState extends State<WhatsAppSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? _currentUser;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  Map<WhatsAppMessageType, bool> _preferences = {};
  List<WhatsAppNotification> _history = [];
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final usersBox = HiveService.getUsersBox();
      final currentUserId = usersBox.get('current_user_id');

      if (currentUserId != null) {
        final userData = usersBox.get(currentUserId);
        if (userData != null) {
          _currentUser =
              UserProfile.fromMap(Map<String, dynamic>.from(userData));
          _notificationsEnabled =
              await WhatsAppService.areNotificationsEnabled(_currentUser!.id);
          _preferences = await WhatsAppService.getNotificationPreferences(
              _currentUser!.id);
          _history =
              await WhatsAppService.getNotificationHistory(_currentUser!.id);
        }
      }

      _statistics = await WhatsAppService.getStatistics();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Integration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
            Tab(text: 'History', icon: Icon(Icons.history)),
            Tab(text: 'Bot', icon: Icon(Icons.smart_toy)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSettingsTab(),
                _buildHistoryTab(),
                _buildBotTab(),
              ],
            ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Connection Status Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/icons/whatsapp.png',
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => Icon(Icons.message,
                            size: 32, color: Colors.green[700]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WhatsApp Business',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<bool>(
                            future: WhatsAppService.isWhatsAppAvailable(),
                            builder: (context, snapshot) {
                              final available = snapshot.data ?? false;
                              return Row(
                                children: [
                                  Icon(
                                    available
                                        ? Icons.check_circle
                                        : Icons.error,
                                    size: 16,
                                    color: available
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    available
                                        ? 'WhatsApp Available'
                                        : 'WhatsApp Not Detected',
                                    style: TextStyle(
                                      color: available
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable WhatsApp Notifications'),
                  subtitle: const Text(
                      'Receive tax reminders and updates via WhatsApp'),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    if (_currentUser != null) {
                      await WhatsAppService.setNotificationsEnabled(
                        _currentUser!.id,
                        value,
                      );
                      setState(() => _notificationsEnabled = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Phone Number Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Phone Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _currentUser?.phoneNumber ?? 'Not set',
                        style: TextStyle(
                          fontSize: 16,
                          color: _currentUser?.phoneNumber != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
                if (_currentUser?.phoneNumber == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Add your phone number in Profile to receive WhatsApp notifications',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Notification Types Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification Types',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...WhatsAppMessageType.values.map((type) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_getTypeName(type)),
                    subtitle: Text(
                      _getTypeDescription(type),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _preferences[type] ?? true,
                    onChanged: _notificationsEnabled
                        ? (value) async {
                            if (_currentUser != null) {
                              _preferences[type] = value;
                              await WhatsAppService.setNotificationPreferences(
                                _currentUser!.id,
                                _preferences,
                              );
                              setState(() {});
                            }
                          }
                        : null,
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Test Notification
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Notification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Send a test message to verify your WhatsApp integration',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _currentUser?.phoneNumber != null
                        ? () => _sendTestNotification()
                        : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Test Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Your WhatsApp notification history\nwill appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Statistics Summary
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${_statistics['total'] ?? 0}',
                  Icons.notifications,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Sent',
                  '${_statistics['sent'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Last 7 Days',
                  '${_statistics['last7Days'] ?? 0}',
                  Icons.date_range,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ),
        // History List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final notification = _history[index];
                return _buildNotificationCard(notification);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(WhatsAppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(notification.type).withOpacity(0.1),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
            size: 20,
          ),
        ),
        title: Text(
          _getTypeName(notification.type),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Icon(
              notification.sent ? Icons.check : Icons.error,
              size: 14,
              color: notification.sent ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              notification.sent ? 'Sent' : 'Failed',
              style: TextStyle(
                fontSize: 12,
                color: notification.sent ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDateTime(notification.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: const TextStyle(fontSize: 13),
                ),
                if (notification.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, size: 16, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification.errorMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bot Info Card
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.smart_toy, size: 32, color: Colors.green[700]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TaxNG Bot',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get quick answers to your tax questions via WhatsApp',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Available Commands
        const Text(
          'Available Commands',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...WhatsAppService.botCommands
            .map((command) => _buildCommandCard(command)),

        const SizedBox(height: 24),

        // Start Chat Button
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Start a conversation with TaxNG Bot',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => WhatsAppService.openWhatsAppSupport(),
                    icon: const Icon(Icons.chat),
                    label: const Text('Open WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommandCard(WhatsAppBotCommand command) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Text(
            command.command[0].toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ),
        title: Text(
          command.command,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(
          command.description,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showCommandPreview(command),
      ),
    );
  }

  void _showCommandPreview(WhatsAppBotCommand command) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(command.command),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(command.description),
                const SizedBox(height: 16),
                const Text(
                  'Response Preview:',
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
                    command.response.replaceAll(RegExp(r'\{[^}]+\}'), '...'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (command.aliases.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Also works with:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: command.aliases.map((alias) {
                      return Chip(
                        label:
                            Text(alias, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey[200],
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendTestNotification() async {
    if (_currentUser == null) return;

    final success = await WhatsAppService.sendWhatsAppMessage(
      phoneNumber: _currentUser!.phoneNumber!,
      message: '''
🧪 *TaxNG Test Message*

Hello ${_currentUser!.username}! 👋

This is a test message from TaxNG app.

If you received this, your WhatsApp integration is working correctly! ✅

_Sent from TaxNG_
''',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Test message sent! Check WhatsApp.'
                : 'Could not open WhatsApp',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String _getTypeName(WhatsAppMessageType type) {
    switch (type) {
      case WhatsAppMessageType.deadlineReminder:
        return 'Deadline Reminders';
      case WhatsAppMessageType.paymentConfirmation:
        return 'Payment Confirmations';
      case WhatsAppMessageType.documentRequest:
        return 'Document Requests';
      case WhatsAppMessageType.supportResponse:
        return 'Support Responses';
      case WhatsAppMessageType.calculationSummary:
        return 'Calculation Summaries';
      case WhatsAppMessageType.generalNotification:
        return 'General Notifications';
    }
  }

  String _getTypeDescription(WhatsAppMessageType type) {
    switch (type) {
      case WhatsAppMessageType.deadlineReminder:
        return 'Get reminded about upcoming tax deadlines';
      case WhatsAppMessageType.paymentConfirmation:
        return 'Receive payment receipts and confirmations';
      case WhatsAppMessageType.documentRequest:
        return 'Be notified when documents are needed';
      case WhatsAppMessageType.supportResponse:
        return 'Get support ticket updates';
      case WhatsAppMessageType.calculationSummary:
        return 'Receive calculation results via WhatsApp';
      case WhatsAppMessageType.generalNotification:
        return 'Other important notifications';
    }
  }

  IconData _getTypeIcon(WhatsAppMessageType type) {
    switch (type) {
      case WhatsAppMessageType.deadlineReminder:
        return Icons.alarm;
      case WhatsAppMessageType.paymentConfirmation:
        return Icons.payment;
      case WhatsAppMessageType.documentRequest:
        return Icons.description;
      case WhatsAppMessageType.supportResponse:
        return Icons.support_agent;
      case WhatsAppMessageType.calculationSummary:
        return Icons.calculate;
      case WhatsAppMessageType.generalNotification:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(WhatsAppMessageType type) {
    switch (type) {
      case WhatsAppMessageType.deadlineReminder:
        return Colors.orange;
      case WhatsAppMessageType.paymentConfirmation:
        return Colors.green;
      case WhatsAppMessageType.documentRequest:
        return Colors.blue;
      case WhatsAppMessageType.supportResponse:
        return Colors.purple;
      case WhatsAppMessageType.calculationSummary:
        return Colors.teal;
      case WhatsAppMessageType.generalNotification:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
