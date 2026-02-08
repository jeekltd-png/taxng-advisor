import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Admin-only screen for managing app version and updates
class AdminAppVersionScreen extends StatefulWidget {
  const AdminAppVersionScreen({super.key});

  @override
  State<AdminAppVersionScreen> createState() => _AdminAppVersionScreenState();
}

class _AdminAppVersionScreenState extends State<AdminAppVersionScreen> {
  String _currentVersion = 'Loading...';
  String _buildNumber = '';
  final String _latestPlayStoreVersion =
      '2.4.0'; // Update this manually after each release
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _loadVersionInfo();
  }

  Future<void> _checkAdminAccess() async {
    final user = await AuthService.currentUser();
    if (user == null || !user.isAdmin) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin access required'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _currentVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentVersion = 'Error loading version';
        _isLoading = false;
      });
    }
  }

  Future<void> _openPlayStoreConsole() async {
    final url = Uri.parse('https://play.google.com/console');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPlayStoreListing() async {
    final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.trykon.taxngadvisor');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  bool _isUpdateAvailable() {
    if (_currentVersion == 'Loading...' ||
        _currentVersion.startsWith('Error')) {
      return false;
    }
    return _compareVersions(_latestPlayStoreVersion, _currentVersion) > 0;
  }

  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    return 0;
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.system_update, color: Colors.green[700]),
            const SizedBox(width: 12),
            const Text('Update Available'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version of TaxPadi is available!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Current Version: $_currentVersion'),
            Text('Latest Version: $_latestPlayStoreVersion'),
            const SizedBox(height: 16),
            const Text(
              'Update now to get the latest features, bug fixes, and improvements.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openPlayStoreListing();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Version & Updates'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current Version Card
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline,
                            size: 48, color: Colors.green[700]),
                        const SizedBox(height: 12),
                        const Text(
                          'Current App Version',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'v$_currentVersion',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Build #$_buildNumber',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Update Status Card
                Card(
                  color: _isUpdateAvailable()
                      ? Colors.orange[50]
                      : Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isUpdateAvailable()
                                  ? Icons.update
                                  : Icons.check_circle,
                              color: _isUpdateAvailable()
                                  ? Colors.orange[700]
                                  : Colors.blue[700],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isUpdateAvailable()
                                    ? 'Update Available'
                                    : 'App is Up to Date',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Latest Play Store Version: $_latestPlayStoreVersion',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (_isUpdateAvailable()) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _showUpdateDialog,
                            icon: const Icon(Icons.preview),
                            label: const Text('Preview Update Dialog'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Admin Actions
                const Text(
                  'Admin Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                _buildActionCard(
                  icon: Icons.cloud_upload,
                  title: 'Open Play Console',
                  description: 'Manage app releases and upload new versions',
                  color: Colors.blue,
                  onTap: _openPlayStoreConsole,
                ),

                _buildActionCard(
                  icon: Icons.store,
                  title: 'View Play Store Listing',
                  description: 'See how the app appears to users',
                  color: Colors.green,
                  onTap: _openPlayStoreListing,
                ),

                _buildActionCard(
                  icon: Icons.build,
                  title: 'Build Release AAB',
                  description: 'Command: flutter build appbundle --release',
                  color: Colors.orange,
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(
                          text: 'flutter build appbundle --release'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Command copied to clipboard'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Release Checklist
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Release Checklist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildChecklistItem('Update version in pubspec.yaml'),
                        _buildChecklistItem('Test all calculators thoroughly'),
                        _buildChecklistItem('Run: flutter clean'),
                        _buildChecklistItem(
                            'Build AAB: flutter build appbundle --release'),
                        _buildChecklistItem('Upload to Play Console'),
                        _buildChecklistItem('Write release notes'),
                        _buildChecklistItem(
                            'Update _latestPlayStoreVersion in this file'),
                        _buildChecklistItem('Submit for review'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Version History
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Versions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildVersionHistoryItem(
                          '2.6.0 (36)',
                          'Feb 3, 2026',
                          'Animated Welcome Screen, UI Enhancements',
                        ),
                        _buildVersionHistoryItem(
                          '2.5.0 (33)',
                          'Jan 18, 2026',
                          'Internal Testing Release (Play Store)',
                        ),
                        _buildVersionHistoryItem(
                          '2.4.0 (32)',
                          'Jan 14, 2026',
                          'Activity Logging, Analytics Dashboard, Email Notifications',
                        ),
                        _buildVersionHistoryItem(
                          '2.3.0 (31)',
                          'Jan 13, 2026',
                          'Multi-level Admin System, Enhanced Security',
                        ),
                        _buildVersionHistoryItem(
                          '2.1.0 (28)',
                          'Jan 13, 2026',
                          'Tax Calendar, Feedback System, Enhanced UI',
                        ),
                        _buildVersionHistoryItem(
                          '2.0.0 (27)',
                          'Jan 12, 2026',
                          'Complete TaxPadi rebrand, Terms of Service',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 12),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_box_outline_blank,
              size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionHistoryItem(String version, String date, String changes) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              version,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  changes,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
