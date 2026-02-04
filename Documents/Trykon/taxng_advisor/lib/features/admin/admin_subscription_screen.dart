import 'package:flutter/material.dart';
import 'dart:io';
import 'package:taxng_advisor/services/subscription_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/models/user.dart';
import 'package:intl/intl.dart';

/// Admin screen to manage subscription upgrades and user tiers
class AdminSubscriptionScreen extends StatefulWidget {
  const AdminSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<AdminSubscriptionScreen> createState() =>
      _AdminSubscriptionScreenState();
}

class _AdminSubscriptionScreenState extends State<AdminSubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _processedRequests = [];
  List<UserProfile> _allUsers = [];
  bool _isLoading = true;

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

    final pending = await SubscriptionService.getUpgradeRequests(
      status: SubscriptionService.statusPending,
    );

    final allRequests = await SubscriptionService.getUpgradeRequests();
    final processed = allRequests
        .where((r) => r['status'] != SubscriptionService.statusPending)
        .toList();

    final users = await AuthService.listUsers();

    setState(() {
      _pendingRequests = pending;
      _processedRequests = processed;
      _allUsers = users;
      _isLoading = false;
    });
  }

  Future<void> _approveRequest(String requestId) async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    // Show confirmation dialog with notes option
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final notesController = TextEditingController();
        return AlertDialog(
          title: const Text('Approve Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Confirm that payment has been verified and subscription should be activated?'),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Admin Notes (Optional)',
                  hintText: 'e.g., Verified with bank',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, {'notes': notesController.text}),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Approve & Activate'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    await SubscriptionService.approveUpgradeRequest(
      requestId,
      user.id,
      adminNotes: result['notes'],
    );
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Payment verified! User subscription activated.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    // Show dialog to get rejection reason
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final reasonController = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason *',
                  hintText: 'e.g., Invalid payment proof, amount mismatch',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason')),
                  );
                  return;
                }
                Navigator.pop(context, {'reason': reasonController.text});
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    await SubscriptionService.rejectUpgradeRequest(
      requestId,
      user.id,
      rejectionReason: result['reason'],
    );
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected and user notified'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _markUnderReview(String requestId) async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    await SubscriptionService.markUnderReview(requestId, user.id);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as under review'),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  Future<void> _viewPaymentProof(Map<String, dynamic> request) async {
    final proofPath = request['paymentProofPath'] as String?;

    if (proofPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No payment proof uploaded')),
      );
      return;
    }

    // Show payment proof dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Proof'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (request['amountPaid'] != null) ...[
                Text('Amount: ₦${request['amountPaid']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
              ],
              if (request['bankName'] != null) ...[
                Text('Bank: ${request['bankName']}'),
                const SizedBox(height: 4),
              ],
              if (request['accountNumber'] != null) ...[
                Text('Account: ${request['accountNumber']}'),
                const SizedBox(height: 4),
              ],
              if (request['notes'] != null) ...[
                const SizedBox(height: 8),
                Text('Notes: ${request['notes']}',
                    style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
              ],
              const Divider(),
              const SizedBox(height: 8),
              // Try to display image if it's an image file
              if (proofPath.toLowerCase().endsWith('.jpg') ||
                  proofPath.toLowerCase().endsWith('.jpeg') ||
                  proofPath.toLowerCase().endsWith('.png'))
                File(proofPath).existsSync()
                    ? Image.file(File(proofPath), fit: BoxFit.contain)
                    : const Text('Image file not accessible',
                        style: TextStyle(color: Colors.red))
              else
                Text('File: ${proofPath.split('/').last}'),
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

  Future<void> _changeTier(UserProfile user, String newTier) async {
    await SubscriptionService.updateUserTier(user.id, newTier);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${user.username}\'s tier changed to $newTier'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'free':
        return Colors.grey;
      case 'individual':
        return Colors.blue;
      case 'business':
        return Colors.orange;
      case 'enterprise':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Management'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Pending (${_pendingRequests.length})',
              icon: const Icon(Icons.pending_actions),
            ),
            const Tab(
              text: 'History',
              icon: Icon(Icons.history),
            ),
            Tab(
              text: 'All Users (${_allUsers.length})',
              icon: const Icon(Icons.people),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(),
                _buildHistoryTab(),
                _buildUsersTab(),
              ],
            ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          return _buildRequestCard(request, isPending: true);
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_processedRequests.isEmpty) {
      return const Center(
        child:
            Text('No processed requests', style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _processedRequests.length,
        itemBuilder: (context, index) {
          final request = _processedRequests[index];
          return _buildRequestCard(request, isPending: false);
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request,
      {required bool isPending}) {
    final currentTier = request['currentTier'] as String;
    final requestedTier = request['requestedTier'] as String;
    final requestedAt = DateTime.parse(request['requestedAt'] as String);
    final status = request['status'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: _getTierColor(requestedTier),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request['email'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isPending)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == SubscriptionService.statusApproved
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTierBadge(currentTier, 'Current'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 8),
                _buildTierBadge(requestedTier, 'Requested'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Requested: ${DateFormat('MMM d, y h:mm a').format(requestedAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            // Show payment proof details if available
            if (request['paymentProofPath'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long,
                            color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Payment Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (request['amountPaid'] != null)
                      Text('Amount: ₦${request['amountPaid']}',
                          style: const TextStyle(fontSize: 13)),
                    if (request['bankName'] != null)
                      Text('Bank: ${request['bankName']}',
                          style: const TextStyle(fontSize: 13)),
                    if (request['accountNumber'] != null)
                      Text('Account: ${request['accountNumber']}',
                          style: const TextStyle(fontSize: 13)),
                    if (request['proofSubmittedAt'] != null)
                      Text(
                        'Proof submitted: ${DateFormat('MMM d, h:mm a').format(DateTime.parse(request['proofSubmittedAt'] as String))}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _viewPaymentProof(request),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Payment Proof'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Show payment method for old requests
            if (request['paymentReference'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Paid via Paystack: ${request['paymentReference']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Show admin notes if any
            if (request['adminNotes'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.admin_panel_settings,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Admin: ${request['adminNotes']}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Show rejection reason if any
            if (request['rejectionReason'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, size: 16, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Reason: ${request['rejectionReason']}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (request['processedAt'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Processed: ${DateFormat('MMM d, y h:mm a').format(DateTime.parse(request['processedAt'] as String))}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],

            // Show status for pending requests
            if (isPending) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  SubscriptionService.getStatusDisplayName(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            if (isPending && request['paymentProofPath'] != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (status != SubscriptionService.statusUnderReview)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _markUnderReview(request['id'] as String),
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('Mark Reviewing',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                        ),
                      ),
                    ),
                  if (status == SubscriptionService.statusUnderReview)
                    const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(request['id'] as String),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Verify & Approve',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRequest(request['id'] as String),
                      icon: const Icon(Icons.close, size: 16),
                      label:
                          const Text('Reject', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (SubscriptionService.getStatusColor(status)) {
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTierBadge(String tier, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getTierColor(tier).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getTierColor(tier)),
          ),
          child: Text(
            SubscriptionService.getTierDisplayName(tier),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getTierColor(tier),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allUsers.length,
        itemBuilder: (context, index) {
          final user = _allUsers[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTierColor(user.subscriptionTier),
          child: Text(
            user.username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.username),
        subtitle: Text(user.email),
        trailing: PopupMenuButton<String>(
          child: Chip(
            label: Text(
                SubscriptionService.getTierDisplayName(user.subscriptionTier)),
            backgroundColor:
                _getTierColor(user.subscriptionTier).withValues(alpha: 0.2),
            labelStyle: TextStyle(color: _getTierColor(user.subscriptionTier)),
          ),
          onSelected: (newTier) => _changeTier(user, newTier),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'free', child: Text('Free')),
            const PopupMenuItem(value: 'individual', child: Text('Individual')),
            const PopupMenuItem(value: 'business', child: Text('Business')),
            const PopupMenuItem(value: 'enterprise', child: Text('Enterprise')),
          ],
        ),
      ),
    );
  }
}
