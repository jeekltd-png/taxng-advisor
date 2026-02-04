import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user.dart';
import '../../models/support_ticket.dart';
import '../../services/auth_service.dart';
import '../../services/activity_log_service.dart';
import '../../services/email_notification_service.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String _filterPriority = 'all';
  String _filterStatus = 'open';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (user == null || !(user.isAnyAdmin)) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Access denied. Admin privileges required.')),
        );
      }
      return;
    }
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _respondToTicket(SupportTicket ticket) async {
    if (_currentUser == null) return;

    final messageController = TextEditingController();
    bool isInternalNote = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Respond to Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Response Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Internal Note (not visible to user)'),
                value: isInternalNote,
                onChanged: (value) {
                  setState(() {
                    isInternalNote = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Send Response'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || messageController.text.isEmpty) return;

    final box = await Hive.openBox<SupportTicket>('support_tickets');

    final message = TicketMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUser!.id,
      senderName: _currentUser!.username,
      message: messageController.text,
      timestamp: DateTime.now(),
      isAdminResponse: true,
      isInternalNote: isInternalNote,
    );

    ticket.messages.add(message);
    ticket.lastUpdated = DateTime.now();

    if (ticket.status == 'open') {
      ticket.status = 'in_progress';
      ticket.assignedTo = _currentUser!.id;
    }

    await box.put(ticket.id, ticket);

    // Log activity
    await ActivityLogService.logAction(
      admin: _currentUser!,
      action: 'ticket_responded',
      targetUserId: ticket.userId,
      targetUsername: ticket.username,
      details: {
        'ticket_id': ticket.id,
        'is_internal_note': isInternalNote,
      },
    );

    // Send email notification (only if not internal note)
    if (!isInternalNote) {
      final userBox = await Hive.openBox<User>('users');
      final user = userBox.get(ticket.userId);
      if (user != null) {
        await EmailNotificationService.sendTicketUpdateNotification(
          user: user,
          ticketId: ticket.id,
          subject: ticket.subject,
          updateType: 'response',
          message: messageController.text,
        );
      }
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Response sent successfully')),
    );
  }

  Future<void> _updateTicketStatus(
      SupportTicket ticket, String newStatus) async {
    if (_currentUser == null) return;

    final box = await Hive.openBox<SupportTicket>('support_tickets');
    ticket.status = newStatus;
    ticket.lastUpdated = DateTime.now();

    await box.put(ticket.id, ticket);

    // Log activity
    await ActivityLogService.logAction(
      admin: _currentUser!,
      action: newStatus == 'closed' ? 'ticket_closed' : 'ticket_status_updated',
      targetUserId: ticket.userId,
      targetUsername: ticket.username,
      details: {
        'ticket_id': ticket.id,
        'new_status': newStatus,
      },
    );

    // Send email notification
    final userBox = await Hive.openBox<User>('users');
    final user = userBox.get(ticket.userId);
    if (user != null) {
      await EmailNotificationService.sendTicketUpdateNotification(
        user: user,
        ticketId: ticket.id,
        subject: ticket.subject,
        updateType: 'status_change',
        message: 'Your ticket status has been changed to: $newStatus',
      );
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket status updated to: $newStatus')),
    );
  }

  Future<void> _escalateTicket(SupportTicket ticket) async {
    if (_currentUser == null) return;

    final box = await Hive.openBox<SupportTicket>('support_tickets');
    ticket.priority = 'high';
    ticket.escalatedTo =
        _currentUser!.createdBy; // Escalate to creator's supervisor
    ticket.lastUpdated = DateTime.now();

    await box.put(ticket.id, ticket);

    // Log activity
    await ActivityLogService.logAction(
      admin: _currentUser!,
      action: 'ticket_escalated',
      targetUserId: ticket.userId,
      targetUsername: ticket.username,
      details: {
        'ticket_id': ticket.id,
        'priority': 'high',
      },
    );

    // Send email notification
    final userBox = await Hive.openBox<User>('users');
    final user = userBox.get(ticket.userId);
    if (user != null) {
      await EmailNotificationService.sendTicketUpdateNotification(
        user: user,
        ticketId: ticket.id,
        subject: ticket.subject,
        updateType: 'escalated',
        message:
            'Your ticket has been escalated to a senior administrator for priority handling.',
      );
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket escalated to higher admin')),
    );
  }

  Future<void> _assignTicket(SupportTicket ticket) async {
    if (_currentUser == null) return;

    final box = await Hive.openBox<SupportTicket>('support_tickets');
    ticket.assignedTo = _currentUser!.id;
    ticket.lastUpdated = DateTime.now();

    if (ticket.status == 'open') {
      ticket.status = 'in_progress';
    }

    await box.put(ticket.id, ticket);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket assigned to you')),
    );
  }

  Future<void> _showTicketDetailsDialog(SupportTicket ticket) async {
    final userBox = await Hive.openBox<User>('users');
    final user = userBox.get(ticket.userId);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              AppBar(
                title: Text('Ticket #${ticket.id.substring(0, 8)}'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ticket Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('User', ticket.username),
                              _buildDetailRow(
                                  'Email', user?.email ?? 'Unknown'),
                              _buildDetailRow('Category', ticket.category),
                              _buildDetailRow(
                                  'Priority', ticket.priority.toUpperCase()),
                              _buildDetailRow(
                                  'Status', ticket.status.toUpperCase()),
                              _buildDetailRow('Created',
                                  ticket.createdAt.toString().split('.')[0]),
                              if (ticket.assignedTo != null)
                                _buildDetailRow(
                                    'Assigned To', ticket.assignedTo!),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subject & Description
                      const Text(
                        'Subject:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(ticket.subject,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),

                      const Text(
                        'Description:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(ticket.description),

                      const SizedBox(height: 24),

                      // Message Thread
                      const Text(
                        'Message Thread:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),

                      ...ticket.messages.map((msg) => Card(
                            color: msg.isAdminResponse
                                ? (msg.isInternalNote
                                    ? Colors.yellow[50]
                                    : Colors.blue[50])
                                : Colors.grey[100],
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        msg.isAdminResponse
                                            ? Icons.admin_panel_settings
                                            : Icons.person,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        msg.senderName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      if (msg.isInternalNote)
                                        const Chip(
                                          label: Text('Internal',
                                              style: TextStyle(fontSize: 10)),
                                          padding: EdgeInsets.zero,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        msg.timestamp.toString().split('.')[0],
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(msg.message),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _respondToTicket(ticket);
                      },
                      icon: const Icon(Icons.reply),
                      label: const Text('Respond'),
                    ),
                    if (ticket.assignedTo != _currentUser!.id)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _assignTicket(ticket);
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Assign to Me'),
                      ),
                    if (ticket.priority != 'high')
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _escalateTicket(ticket);
                        },
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text('Escalate'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                      ),
                    if (ticket.status != 'resolved')
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateTicketStatus(ticket, 'resolved');
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Resolve'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                    if (ticket.status == 'resolved')
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateTicketStatus(ticket, 'closed');
                        },
                        icon: const Icon(Icons.done_all),
                        label: const Text('Close'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getPriorityEmoji(String priority) {
    switch (priority) {
      case 'high':
        return '🔴';
      case 'medium':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
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
        title: const Text('Support Tickets'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
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
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(
                          value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(
                          value: 'resolved', child: Text('Resolved')),
                      DropdownMenuItem(value: 'closed', child: Text('Closed')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Priority')),
                      DropdownMenuItem(value: 'high', child: Text('🔴 High')),
                      DropdownMenuItem(
                          value: 'medium', child: Text('🟡 Medium')),
                      DropdownMenuItem(value: 'low', child: Text('🟢 Low')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterPriority = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Ticket List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<SupportTicket>('support_tickets').listenable(),
              builder: (context, Box<SupportTicket> box, _) {
                var tickets = box.values.toList();

                // Apply filters
                if (_filterStatus != 'all') {
                  tickets =
                      tickets.where((t) => t.status == _filterStatus).toList();
                }
                if (_filterPriority != 'all') {
                  tickets = tickets
                      .where((t) => t.priority == _filterPriority)
                      .toList();
                }

                // Sort by priority and date
                tickets.sort((a, b) {
                  final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
                  final aPriority = priorityOrder[a.priority] ?? 3;
                  final bPriority = priorityOrder[b.priority] ?? 3;

                  if (aPriority != bPriority) {
                    return aPriority.compareTo(bPriority);
                  }
                  return b.createdAt.compareTo(a.createdAt);
                });

                if (tickets.isEmpty) {
                  return const Center(
                    child: Text('No support tickets found'),
                  );
                }

                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    final isAssignedToMe =
                        ticket.assignedTo == _currentUser!.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      color: isAssignedToMe ? Colors.blue[50] : null,
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getPriorityEmoji(ticket.priority),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                        title: Text(
                          ticket.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From: ${ticket.username}'),
                            Text(
                              'Status: ${ticket.status.toUpperCase()} • ${ticket.category}',
                              style: TextStyle(
                                fontSize: 12,
                                color: ticket.status == 'open'
                                    ? Colors.orange
                                    : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isAssignedToMe)
                              const Text(
                                '👤 Assigned to you',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              ticket.createdAt.toString().split(' ')[0],
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${ticket.messages.length} msgs',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        onTap: () => _showTicketDetailsDialog(ticket),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Stats Footer
          ValueListenableBuilder(
            valueListenable:
                Hive.box<SupportTicket>('support_tickets').listenable(),
            builder: (context, Box<SupportTicket> box, _) {
              final allTickets = box.values.toList();
              final open = allTickets.where((t) => t.status == 'open').length;
              final inProgress =
                  allTickets.where((t) => t.status == 'in_progress').length;
              final resolved =
                  allTickets.where((t) => t.status == 'resolved').length;
              final high = allTickets.where((t) => t.priority == 'high').length;

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
                        'Open', open.toString(), Icons.mail, Colors.orange),
                    _buildStatItem('In Progress', inProgress.toString(),
                        Icons.work, Colors.blue),
                    _buildStatItem('Resolved', resolved.toString(),
                        Icons.check_circle, Colors.green),
                    _buildStatItem('High Priority', high.toString(),
                        Icons.priority_high, Colors.red),
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
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
