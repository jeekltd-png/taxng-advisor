import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxng_advisor/models/share_token.dart';
import 'package:taxng_advisor/models/user.dart';
import 'package:taxng_advisor/services/sharing_service.dart';
import 'package:taxng_advisor/services/hive_service.dart';

class ShareWithAccountantScreen extends StatefulWidget {
  const ShareWithAccountantScreen({super.key});

  @override
  State<ShareWithAccountantScreen> createState() =>
      _ShareWithAccountantScreenState();
}

class _ShareWithAccountantScreenState extends State<ShareWithAccountantScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? _currentUser;
  List<ShareToken> _tokens = [];
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

    try {
      final usersBox = HiveService.getUsersBox();
      final currentUserId = usersBox.get('current_user_id');

      if (currentUserId != null) {
        final userData = usersBox.get(currentUserId);
        if (userData != null) {
          _currentUser =
              UserProfile.fromMap(Map<String, dynamic>.from(userData));
          _tokens = await SharingService.getUserShareTokens(_currentUser!.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share with Accountant'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Shares', icon: Icon(Icons.link)),
            Tab(text: 'Access Logs', icon: Icon(Icons.history)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create New Share',
            onPressed: () => _showCreateShareDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveSharesTab(),
                _buildAccessLogsTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildActiveSharesTab() {
    final activeTokens = _tokens.where((t) => t.isValid).toList();
    final expiredTokens = _tokens.where((t) => !t.isValid).toList();

    if (_tokens.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No shares yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a share link to give your accountant\naccess to your tax calculations',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateShareDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create Share Link'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeTokens.isNotEmpty) ...[
            _buildSectionHeader('Active Shares', Icons.link, Colors.green),
            const SizedBox(height: 8),
            ...activeTokens.map((t) => _buildTokenCard(t)),
            const SizedBox(height: 24),
          ],
          if (expiredTokens.isNotEmpty) ...[
            _buildSectionHeader('Expired/Revoked', Icons.link_off, Colors.grey),
            const SizedBox(height: 8),
            ...expiredTokens.map((t) => _buildTokenCard(t)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTokenCard(ShareToken token) {
    final isActive = token.isValid;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green[100] : Colors.grey[200],
          child: Icon(
            isActive ? Icons.link : Icons.link_off,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          token.recipientEmail ?? 'Anyone with link',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(token.statusLabel, isActive),
                const SizedBox(width: 8),
                Text(
                  token.permissionLabel,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                _buildDetailRow('Access Code', token.accessCode ?? 'N/A'),
                _buildDetailRow('Created', _formatDate(token.createdAt)),
                _buildDetailRow('Expires', _formatDate(token.expiresAt)),
                _buildDetailRow('Access Count', token.accessCount.toString()),
                if (token.lastAccessedAt != null)
                  _buildDetailRow(
                      'Last Access', _formatDate(token.lastAccessedAt!)),
                if (token.sharedTaxTypes != null)
                  _buildDetailRow('Tax Types', token.sharedTaxTypes!),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (isActive) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyShareLink(token),
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copy Link'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _revokeToken(token),
                          icon: const Icon(Icons.block, size: 18),
                          label: const Text('Revoke'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteToken(token),
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.green[700] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessLogsTab() {
    return FutureBuilder<List<ShareAccessLog>>(
      future: _currentUser != null
          ? SharingService.getUserAccessLogs(_currentUser!.id)
          : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No access logs yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'When someone accesses your shared data,\nit will appear here',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActionColor(log.action).withOpacity(0.1),
                  child: Icon(
                    _getActionIcon(log.action),
                    color: _getActionColor(log.action),
                    size: 20,
                  ),
                ),
                title: Text(log.accessorEmail),
                subtitle: Text(
                  '${_capitalizeFirst(log.action)} • ${_formatDateTime(log.accessedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Text(
                  log.accessorIp,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Default Share Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Default Permission'),
                  subtitle: const Text('View Only'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show permission picker
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Default Expiry'),
                  subtitle: const Text('7 days'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show expiry picker
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Require Email'),
                  subtitle: const Text('Recipient must provide email'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Save setting
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Access Alerts'),
                  subtitle: const Text('Notify when someone views your data'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Save setting
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Expiry Reminders'),
                  subtitle: const Text('Remind before links expire'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Save setting
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: _currentUser != null
                      ? SharingService.getSharingStatistics(_currentUser!.id)
                      : Future.value({}),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ?? {};
                    return Column(
                      children: [
                        _buildStatRow('Total Links Created',
                            '${stats['totalTokens'] ?? 0}'),
                        _buildStatRow(
                            'Active Links', '${stats['activeTokens'] ?? 0}'),
                        _buildStatRow(
                            'Total Access', '${stats['totalAccess'] ?? 0}'),
                        _buildStatRow(
                            'Last 7 Days', '${stats['last7DaysAccess'] ?? 0}'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showCreateShareDialog() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    SharePermission permission = SharePermission.viewOnly;
    int expiryDays = 7;
    final taxTypes = <String>{'VAT', 'CIT', 'PIT', 'WHT', 'PAYE', 'Stamp Duty'};
    final selectedTypes = <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.share, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Create Share Link',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Email (optional)',
                        hintText: 'accountant@example.com',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Name (optional)',
                        hintText: 'John Doe',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Permission Level',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<SharePermission>(
                      segments: const [
                        ButtonSegment(
                          value: SharePermission.viewOnly,
                          label: Text('View'),
                          icon: Icon(Icons.visibility),
                        ),
                        ButtonSegment(
                          value: SharePermission.comment,
                          label: Text('Comment'),
                          icon: Icon(Icons.comment),
                        ),
                        ButtonSegment(
                          value: SharePermission.edit,
                          label: Text('Edit'),
                          icon: Icon(Icons.edit),
                        ),
                      ],
                      selected: {permission},
                      onSelectionChanged: (Set<SharePermission> newSelection) {
                        setModalState(() {
                          permission = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Link Expiry',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('1 day')),
                        ButtonSegment(value: 7, label: Text('7 days')),
                        ButtonSegment(value: 30, label: Text('30 days')),
                        ButtonSegment(value: 90, label: Text('90 days')),
                      ],
                      selected: {expiryDays},
                      onSelectionChanged: (Set<int> newSelection) {
                        setModalState(() {
                          expiryDays = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tax Types to Share',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: taxTypes.map((type) {
                        final isSelected = selectedTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                selectedTypes.add(type);
                              } else {
                                selectedTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (_currentUser == null) return;

                          final token = await SharingService.createShareToken(
                            owner: _currentUser!,
                            recipientEmail: emailController.text.isEmpty
                                ? null
                                : emailController.text,
                            recipientName: nameController.text.isEmpty
                                ? null
                                : nameController.text,
                            permission: permission,
                            expiryDays: expiryDays,
                            taxTypes: selectedTypes.isEmpty
                                ? null
                                : selectedTypes.join(','),
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            _loadData();
                            _showShareLinkDialog(token);
                          }
                        },
                        icon: const Icon(Icons.link),
                        label: const Text('Create Share Link'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showShareLinkDialog(ShareToken token) {
    final link = SharingService.generateShareableLink(token);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text('Share Link Created!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share this link with your accountant:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  link,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.key, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Access Code: ${token.accessCode}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard!')),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Link'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyShareLink(ShareToken token) async {
    final link = SharingService.generateShareableLink(token);
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share link copied to clipboard!')),
      );
    }
  }

  Future<void> _revokeToken(ShareToken token) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Revoke Access?'),
          content: const Text(
            'This will immediately revoke access for anyone using this share link. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Revoke'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await SharingService.revokeShareToken(token.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access revoked successfully')),
        );
      }
    }
  }

  Future<void> _deleteToken(ShareToken token) async {
    await SharingService.deleteShareToken(token.id);
    _loadData();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'view':
        return Icons.visibility;
      case 'download':
        return Icons.download;
      case 'comment':
        return Icons.comment;
      case 'edit':
        return Icons.edit;
      default:
        return Icons.touch_app;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'view':
        return Colors.blue;
      case 'download':
        return Colors.green;
      case 'comment':
        return Colors.orange;
      case 'edit':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
