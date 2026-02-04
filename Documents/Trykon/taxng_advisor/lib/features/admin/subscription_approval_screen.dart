import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user.dart';
import '../../models/subscription_request.dart';
import '../../services/auth_service.dart';
import '../../services/activity_log_service.dart';
import '../../services/email_notification_service.dart';

class SubscriptionApprovalScreen extends StatefulWidget {
  const SubscriptionApprovalScreen({super.key});

  @override
  State<SubscriptionApprovalScreen> createState() =>
      _SubscriptionApprovalScreenState();
}

class _SubscriptionApprovalScreenState
    extends State<SubscriptionApprovalScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String _filterStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (user == null || !(user.isMainAdmin || user.isSubAdmin2)) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Access denied. Sub Admin 2 or Admin privileges required.')),
        );
      }
      return;
    }
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _reviewRequest(
      SubscriptionRequest request, bool recommend) async {
    if (_currentUser == null) return;

    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recommend ? 'Recommend Approval' : 'Recommend Rejection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${request.username}'),
            Text('Tier: ${request.requestedTier}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Review Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
            child: Text(recommend ? 'Recommend' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final box =
        await Hive.openBox<SubscriptionRequest>('subscription_requests');
    request.status = recommend ? 'recommended' : 'rejected';
    request.reviewedBy = _currentUser!.id;
    request.subAdmin1Notes = notesController.text;
    request.reviewedAt = DateTime.now();

    await box.put(request.id, request);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Request ${recommend ? "recommended" : "rejected"}')),
    );
  }

  Future<void> _approveRequest(
      SubscriptionRequest request, bool approve) async {
    if (_currentUser == null) return;
    if (!(_currentUser!.isMainAdmin || _currentUser!.isSubAdmin2)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Only Sub Admin 2 or Admin can approve requests')),
      );
      return;
    }

    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve Request' : 'Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${request.username}'),
            Text('Tier: ${request.requestedTier}'),
            if (request.subAdmin1Notes != null) ...[
              const SizedBox(height: 8),
              Text('Sub Admin 1 Notes: ${request.subAdmin1Notes}'),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Approval Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.green : Colors.red,
            ),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final box =
        await Hive.openBox<SubscriptionRequest>('subscription_requests');
    final userBox = await Hive.openBox<User>('users');

    request.status = approve ? 'approved' : 'rejected';
    request.approvedBy = _currentUser!.id;
    request.subAdmin2Notes = notesController.text;
    request.approvedAt = DateTime.now();

    // Get user for both notifications and subscription update
    final user = userBox.get(request.userId);

    // If approved, upgrade user subscription
    if (approve && user != null) {
      final updatedUser =
          user.copyWith(subscriptionTier: request.requestedTier);
      await userBox.put(user.id, updatedUser);
    }

    await box.put(request.id, request);

    // Log activity
    await ActivityLogService.logAction(
      admin: _currentUser!,
      action: approve ? 'subscription_approved' : 'subscription_rejected',
      targetUserId: request.userId,
      targetUsername: request.username,
      details: {
        'subscription_tier': request.requestedTier,
        'notes': notesController.text,
      },
    );

    // Send email notification
    if (user != null) {
      if (approve) {
        await EmailNotificationService.sendSubscriptionApprovalNotification(
          user: user,
          tier: request.requestedTier,
        );
      } else {
        await EmailNotificationService.sendSubscriptionRejectionNotification(
          user: user,
          tier: request.requestedTier,
          reason: notesController.text.isEmpty ? null : notesController.text,
        );
      }
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Request ${approve ? "approved" : "rejected"} and user updated')),
    );
  }

  Future<void> _showRequestDetailsDialog(SubscriptionRequest request) async {
    final userBox = await Hive.openBox<User>('users');
    final user = userBox.get(request.userId);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User', request.username),
              _buildDetailRow('Email', request.email),
              _buildDetailRow(
                  'Current Tier', user?.subscriptionTier ?? 'Unknown'),
              _buildDetailRow('Requested Tier', request.requestedTier),
              _buildDetailRow('Status', request.status.toUpperCase()),
              _buildDetailRow(
                  'Submitted', request.createdAt.toString().split(' ')[0]),
              const Divider(),
              const Text('Payment Information:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildDetailRow('Payment Method',
                  _getPaymentMethodDisplay(request.paymentMethod)),
              if (request.paymentReference != null)
                _buildDetailRow('Payment Ref', request.paymentReference!),
              if (request.paymentMethod == PaymentMethod.bankTransfer) ...[
                if (request.bankName != null)
                  _buildDetailRow('Bank Name', request.bankName!),
                if (request.accountNumber != null)
                  _buildDetailRow('Account Number', request.accountNumber!),
              ],
              _buildDetailRow(
                  'Amount', '₦${request.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              if (request.subAdmin1Notes != null) ...[
                const Text('Sub Admin 1 Review:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(request.subAdmin1Notes!),
                const SizedBox(height: 8),
              ],
              if (request.subAdmin2Notes != null) ...[
                const Text('Sub Admin 2 Approval:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(request.subAdmin2Notes!),
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
            width: 120,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getPaymentMethodDisplay(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.paystack:
        return '💳 Paystack (Online)';
      case PaymentMethod.bankTransfer:
        return '🏦 Bank Transfer (Manual)';
      case PaymentMethod.unknown:
        return '❓ Unknown';
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
        title: const Text('Subscription Approvals'),
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
                  'Logged in as: ${_currentUser!.username} (${_currentUser!.adminRole.toUpperCase()})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Status Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _filterStatus,
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Requests')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(
                    value: 'under_review', child: Text('Under Review')),
                DropdownMenuItem(
                    value: 'recommended', child: Text('Recommended')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (value) {
                setState(() {
                  _filterStatus = value!;
                });
              },
            ),
          ),

          // Request List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<SubscriptionRequest>('subscription_requests')
                      .listenable(),
              builder: (context, Box<SubscriptionRequest> box, _) {
                var requests = box.values.toList();

                // Apply filter
                if (_filterStatus != 'all') {
                  requests =
                      requests.where((r) => r.status == _filterStatus).toList();
                }

                // Sort by date (newest first)
                requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (requests.isEmpty) {
                  return const Center(
                    child: Text('No subscription requests found'),
                  );
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];

                    Color statusColor;
                    IconData statusIcon;

                    switch (request.status) {
                      case 'pending':
                        statusColor = Colors.orange;
                        statusIcon = Icons.hourglass_empty;
                        break;
                      case 'under_review':
                        statusColor = Colors.blue;
                        statusIcon = Icons.rate_review;
                        break;
                      case 'recommended':
                        statusColor = Colors.purple;
                        statusIcon = Icons.thumb_up;
                        break;
                      case 'approved':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case 'rejected':
                        statusColor = Colors.red;
                        statusIcon = Icons.cancel;
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusIcon = Icons.help;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor,
                          child: Icon(statusIcon, color: Colors.white),
                        ),
                        title: Text(
                          request.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Upgrade to: ${request.requestedTier.toUpperCase()}'),
                            Text(
                              'Status: ${request.status.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
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
                                Text('Email: ${request.email}'),
                                Text(
                                    'Submitted: ${request.createdAt.toString().split(' ')[0]}'),
                                if (request.paymentReference != null)
                                  Text(
                                      'Payment Ref: ${request.paymentReference}'),
                                const SizedBox(height: 16),

                                // Action Buttons
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _showRequestDetailsDialog(request),
                                      icon: const Icon(Icons.info),
                                      label: const Text('View Details'),
                                    ),
                                    if (_currentUser!.isSubAdmin1 &&
                                        request.status == 'pending')
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _reviewRequest(request, true),
                                        icon: const Icon(Icons.thumb_up),
                                        label: const Text('Recommend'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    if (_currentUser!.isSubAdmin1 &&
                                        request.status == 'pending')
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _reviewRequest(request, false),
                                        icon: const Icon(Icons.thumb_down),
                                        label: const Text('Reject'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    if ((_currentUser!.isMainAdmin ||
                                            _currentUser!.isSubAdmin2) &&
                                        (request.status == 'recommended' ||
                                            request.status == 'pending'))
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _approveRequest(request, true),
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    if ((_currentUser!.isMainAdmin ||
                                            _currentUser!.isSubAdmin2) &&
                                        request.status != 'rejected' &&
                                        request.status != 'approved')
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _approveRequest(request, false),
                                        icon: const Icon(Icons.cancel),
                                        label: const Text('Final Reject'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                  ],
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
          ValueListenableBuilder(
            valueListenable:
                Hive.box<SubscriptionRequest>('subscription_requests')
                    .listenable(),
            builder: (context, Box<SubscriptionRequest> box, _) {
              final allRequests = box.values.toList();
              final pending =
                  allRequests.where((r) => r.status == 'pending').length;
              final recommended =
                  allRequests.where((r) => r.status == 'recommended').length;
              final approved =
                  allRequests.where((r) => r.status == 'approved').length;
              final rejected =
                  allRequests.where((r) => r.status == 'rejected').length;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Pending', pending.toString(),
                        Icons.hourglass_empty, Colors.orange),
                    _buildStatItem('Recommended', recommended.toString(),
                        Icons.thumb_up, Colors.purple),
                    _buildStatItem('Approved', approved.toString(),
                        Icons.check_circle, Colors.green),
                    _buildStatItem('Rejected', rejected.toString(),
                        Icons.cancel, Colors.red),
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
