import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/models/user.dart';

class DebugUsersScreen extends StatefulWidget {
  const DebugUsersScreen({super.key});

  @override
  State<DebugUsersScreen> createState() => _DebugUsersScreenState();
}

class _DebugUsersScreenState extends State<DebugUsersScreen> {
  List<UserProfile> _users = [];
  bool _loading = false;

  final Map<String, String> _knownPasswords = {
    'testuser': 'Test@1234',
    'business1': 'Biz@1234',
    'admin': 'Admin@123',
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final list = await AuthService.listUsers();
    setState(() {
      _users = list;
      _loading = false;
    });
  }

  Future<void> _seed() async {
    setState(() => _loading = true);
    await AuthService.seedTestUsers();
    await _loadUsers();
  }

  Future<void> _loginAs(String username) async {
    final pwd = _knownPasswords[username];
    if (pwd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No known password for this user')),
      );
      return;
    }

    final user = await AuthService.login(username, pwd);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged in as ${user.username}')),
    );
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug - Users')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                    onPressed: _seed, child: const Text('Seed Test Users')),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: _loadUsers, child: const Text('Refresh')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, i) {
                        final u = _users[i];
                        return ListTile(
                          title: Text(u.username),
                          subtitle: Text(
                              '${u.email}\n${u.isBusiness ? 'Business: ${u.businessName}' : 'Personal'}'),
                          isThreeLine: true,
                          trailing: ElevatedButton(
                            onPressed: () => _loginAs(u.username),
                            child: const Text('Login as'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
