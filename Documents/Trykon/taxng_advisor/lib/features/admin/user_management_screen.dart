import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/activity_log_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String _searchQuery = '';
  String _filterTier = 'all';
  String _filterStatus = 'all';
  String _filterRole = 'all';

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

  List<User> _filterUsers(List<User> users) {
    return users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!user.username.toLowerCase().contains(query) &&
            !user.email.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Tier filter
      if (_filterTier != 'all' && user.subscriptionTier != _filterTier) {
        return false;
      }

      // Status filter
      if (_filterStatus == 'active' && !user.isActive) {
        return false;
      } else if (_filterStatus == 'suspended' && user.isActive) {
        return false;
      }

      // Role filter
      if (_filterRole != 'all' && user.adminRole != _filterRole) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _toggleUserStatus(User user) async {
    if (_currentUser == null) return;

    // Check permissions
    if (_currentUser!.adminHierarchyLevel >= user.adminHierarchyLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('You cannot modify users of equal or higher authority')),
      );
      return;
    }

    final box = await Hive.openBox<User>('users');
    final newStatus = !user.isActive;

    final updatedUser = user.copyWith(
      isActive: newStatus,
      suspensionReason: newStatus ? null : 'Suspended by admin',
    );

    await box.put(user.id, updatedUser);

    // Log activity
    await ActivityLogService.logAction(
      admin: _currentUser!,
      action: newStatus ? 'user_activated' : 'user_suspended',
      targetUserId: user.id,
      targetUsername: user.username,
      details: {
        'previous_status': !newStatus ? 'active' : 'suspended',
        'new_status': newStatus ? 'active' : 'suspended',
      },
    );

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(newStatus ? 'User activated' : 'User suspended')),
    );
  }

  Future<void> _showUserDetailsDialog(User user) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user.username}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Username', user.username),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Subscription Tier', user.subscriptionTier),
              _buildDetailRow('Admin Role', user.adminRole ?? 'User'),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Suspended'),
              _buildDetailRow(
                  'Join Date', user.createdAt.toString().split(' ')[0]),
              if (!user.isActive) ...[
                const SizedBox(height: 16),
                const Text('Suspension Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildDetailRow('Reason', user.suspensionReason ?? 'N/A'),
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

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
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

          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search users',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _filterTier,
                        decoration: const InputDecoration(
                          labelText: 'Tier',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('All Tiers')),
                          DropdownMenuItem(value: 'free', child: Text('Free')),
                          DropdownMenuItem(
                              value: 'business', child: Text('Business')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterTier = value!;
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
                          DropdownMenuItem(
                              value: 'all', child: Text('All Status')),
                          DropdownMenuItem(
                              value: 'active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'suspended', child: Text('Suspended')),
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
                        initialValue: _filterRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('All Roles')),
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(
                              value: 'subadmin1', child: Text('Sub Admin 1')),
                          DropdownMenuItem(
                              value: 'subadmin2', child: Text('Sub Admin 2')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterRole = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<User>('users').listenable(),
              builder: (context, Box<User> box, _) {
                final allUsers = box.values.toList();
                final filteredUsers = _filterUsers(allUsers);

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text('No users found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isOwnAccount = user.id == _currentUser!.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              user.isActive ? Colors.green : Colors.red,
                          child: Icon(
                            user.isAnyAdmin
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          user.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: user.isActive
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Text(
                              '${user.subscriptionTier.toUpperCase()} • ${(user.adminRole ?? 'USER').toUpperCase()}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    user.isAnyAdmin ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () => _showUserDetailsDialog(user),
                              tooltip: 'View Details',
                            ),
                            if (!isOwnAccount &&
                                (_currentUser!.isMainAdmin ||
                                    (_currentUser!.isSubAdmin2 &&
                                        !user.isMainAdmin)))
                              IconButton(
                                icon: Icon(
                                  user.isActive
                                      ? Icons.block
                                      : Icons.check_circle,
                                  color:
                                      user.isActive ? Colors.red : Colors.green,
                                ),
                                onPressed: () => _toggleUserStatus(user),
                                tooltip: user.isActive ? 'Suspend' : 'Activate',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Stats Footer
          ValueListenableBuilder(
            valueListenable: Hive.box<User>('users').listenable(),
            builder: (context, Box<User> box, _) {
              final allUsers = box.values.toList();
              final totalUsers = allUsers.length;
              final activeUsers = allUsers.where((u) => u.isActive).length;
              final businessUsers = allUsers
                  .where((u) => u.subscriptionTier == 'business')
                  .length;
              final suspendedUsers = allUsers.where((u) => !u.isActive).length;

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
                        'Total', totalUsers.toString(), Icons.people),
                    _buildStatItem(
                        'Active', activeUsers.toString(), Icons.check_circle),
                    _buildStatItem(
                        'Business', businessUsers.toString(), Icons.business),
                    _buildStatItem(
                        'Suspended', suspendedUsers.toString(), Icons.block),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.red[700]),
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
