import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Multi-User Management Screen for Business tier
class MultiUserManagementScreen extends StatefulWidget {
  const MultiUserManagementScreen({Key? key}) : super(key: key);

  @override
  State<MultiUserManagementScreen> createState() =>
      _MultiUserManagementScreenState();
}

class _MultiUserManagementScreenState extends State<MultiUserManagementScreen> {
  List<Map<String, dynamic>> _teamMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService.currentUser();
    // Allow access for Business tier OR admin users
    if (user == null ||
        (user.subscriptionTier != 'business' && !user.isAdmin)) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business tier required for multi-user management'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      // TODO: Load team members from database
      _teamMembers = [
        {
          'email': user.email,
          'role': 'Owner',
          'status': 'Active',
          'joinedDate': DateTime.now().subtract(const Duration(days: 30)),
        },
      ];
      _isLoading = false;
    });
  }

  void _showAddUserDialog() {
    final emailController = TextEditingController();
    final roleController = TextEditingController(text: 'Member');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_add, color: Colors.green[700]),
            const SizedBox(width: 12),
            const Text('Add Team Member'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: roleController.text,
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Member', child: Text('Member')),
                DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null) roleController.text = value;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Business plan allows up to 5 users',
                      style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
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
              if (emailController.text.isNotEmpty) {
                _addTeamMember(emailController.text, roleController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTeamMember(String email, String role) async {
    if (_teamMembers.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 users reached for Business plan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Send invitation email and create user account
    setState(() {
      _teamMembers.add({
        'email': email,
        'role': role,
        'status': 'Pending',
        'joinedDate': DateTime.now(),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to $email'),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  void _removeTeamMember(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Team Member'),
        content: Text(
          'Are you sure you want to remove ${_teamMembers[index]['email']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _teamMembers.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team member removed'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Management'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.group, color: Colors.green[700], size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Team Members',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_teamMembers.length} / 5 users',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _teamMembers.length / 5,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green[700]!,
                        ),
                      ),
                    ],
                  ),
                ),
                // Team members list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _teamMembers.length,
                    itemBuilder: (context, index) {
                      final member = _teamMembers[index];
                      final isOwner = member['role'] == 'Owner';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            child: Text(
                              member['email'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            member['email'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      member['role'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: member['status'] == 'Active'
                                          ? Colors.green[100]
                                          : Colors.orange[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      member['status'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: member['status'] == 'Active'
                                            ? Colors.green[900]
                                            : Colors.orange[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Joined ${_formatDate(member['joinedDate'])}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: isOwner
                              ? null
                              : PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Change Role'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Remove',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'remove') {
                                      _removeTeamMember(index);
                                    }
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _teamMembers.length < 5
          ? FloatingActionButton.extended(
              onPressed: _showAddUserDialog,
              backgroundColor: Colors.green[700],
              icon: const Icon(Icons.person_add),
              label: const Text('Add User'),
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
