import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/hive_service.dart';
import 'package:taxng_advisor/models/user.dart';
import 'package:taxng_advisor/features/help/privacy_policy_screen.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _user;
  final _importController = TextEditingController();
  String? _logoBase64;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadLogo();
  }

  Future<void> _loadUser() async {
    final u = await AuthService.currentUser();
    setState(() => _user = u);
  }

  Future<void> _loadLogo() async {
    try {
      final box = HiveService.getProfileBox();
      final logo = box.get('company_logo') as String?;
      setState(() => _logoBase64 = logo);
    } catch (_) {}
  }

  Future<void> _pickLogoFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (res == null) return;
    final bytes = res.files.first.bytes;
    if (bytes == null) return;

    // Convert to base64 for storage
    final base64Logo = base64Encode(bytes);
    try {
      final box = HiveService.getProfileBox();
      await box.put('company_logo', base64Logo);
      setState(() => _logoBase64 = base64Logo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save logo: $e')),
      );
    }
  }

  Future<void> _removeLogo() async {
    try {
      final box = HiveService.getProfileBox();
      await box.delete('company_logo');
      setState(() => _logoBase64 = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo removed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove logo: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    // Show dialog with clear cancel option first
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Import File'),
        content: const Text(
          'Select a JSON or CSV file from your device.\n\nYou can cancel anytime by:\n• Tapping "Cancel" below\n• Using your device back button\n• Tapping outside this dialog',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.folder_open),
            label: const Text('Choose File'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
      withData: true,
    );

    if (res == null) return;
    final bytes = res.files.first.bytes;
    if (bytes == null) return;
    final text = utf8.decode(bytes);
    _importController.text = text;
  }

  /// Parse CSV format: expects header row with field names
  List<Map<String, dynamic>> _parseCSV(String csvText) {
    final lines = csvText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return [];

    final headers = lines[0].split(',').map((h) => h.trim()).toList();
    final records = <Map<String, dynamic>>[];

    for (int i = 1; i < lines.length; i++) {
      final values = lines[i].split(',').map((v) => v.trim()).toList();
      if (values.length != headers.length) continue;

      final record = <String, dynamic>{};
      for (int j = 0; j < headers.length; j++) {
        final value = values[j];
        // Try to parse as number
        final numValue = num.tryParse(value);
        record[headers[j]] = numValue ?? value;
      }
      records.add(record);
    }

    return records;
  }

  Future<void> _importJson() async {
    final text = _importController.text.trim();
    if (text.isEmpty) return;

    try {
      // Try to detect format (JSON or CSV)
      final isCSV =
          text.contains(',') && !text.startsWith('{') && !text.startsWith('[');

      if (isCSV) {
        _importCSV(text);
      } else {
        _importJSONFormat(text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import error: $e')),
      );
    }
  }

  Future<void> _importCSV(String csvText) async {
    final records = _parseCSV(csvText);
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid records found in CSV')),
      );
      return;
    }

    // Process first record
    final firstRecord = records[0];
    final recordType = firstRecord['type'] as String?;

    if (recordType == 'CIT') {
      final turnover = (firstRecord['turnover'] as num?)?.toDouble();
      final profit = (firstRecord['profit'] as num?)?.toDouble();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Imported ${records.length} CIT record(s) — opening calculator')),
      );

      Navigator.pushNamed(context, '/cit', arguments: {
        'turnover': turnover,
        'profit': profit,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('CSV type "$recordType" import ready for implementation')),
      );
    }
  }

  Future<void> _importJSONFormat(String jsonText) async {
    final Map<String, dynamic> data = jsonDecode(jsonText);
    // For demo: if CIT data present, save to local storage (legacy service)
    if (data['type'] == 'CIT') {
      // If data contains turnover/profit, navigate to CIT calculator with args
      final payload = data['data'] as Map<String, dynamic>?;
      final turnover = payload != null && payload['turnover'] != null
          ? (payload['turnover'] as num).toDouble()
          : null;
      final profit = payload != null && payload['profit'] != null
          ? (payload['profit'] as num).toDouble()
          : null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imported CIT data — opening calculator')),
      );

      // Pass arguments to CIT screen so it can prefill and calculate
      Navigator.pushNamed(context, '/cit', arguments: {
        'turnover': turnover,
        'profit': profit,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON type not recognized')),
      );
    }
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TaxNGAppBar(title: 'Profile', showUserProfile: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_user != null) ...[
              Text('Username: ${_user!.username}'),
              Text('Email: ${_user!.email}'),
              if (_user!.phoneNumber != null && _user!.phoneNumber!.isNotEmpty)
                Text('Phone: ${_user!.phoneNumber}'),
              if (_user!.address != null && _user!.address!.isNotEmpty)
                Text('Address: ${_user!.address}'),
              Text(
                  'Business: ${_user!.isBusiness ? _user!.businessName ?? 'Yes' : 'No'}'),
              const Divider(height: 24),
              const Text('Tax Compliance Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (_user!.tin != null && _user!.tin!.isNotEmpty)
                Text('TIN: ${_user!.tin}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              if (_user!.cacNumber != null && _user!.cacNumber!.isNotEmpty)
                Text('CAC Reg. No: ${_user!.cacNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              if (_user!.bvn != null && _user!.bvn!.isNotEmpty)
                Text('BVN: ${_user!.bvn}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              if (_user!.vatNumber != null && _user!.vatNumber!.isNotEmpty)
                Text('VAT Reg. No: ${_user!.vatNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              if (_user!.payeRef != null && _user!.payeRef!.isNotEmpty)
                Text('PAYE Ref: ${_user!.payeRef}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              if (_user!.taxOffice != null && _user!.taxOffice!.isNotEmpty)
                Text('Tax Office: ${_user!.taxOffice}'),
              if (_user!.tccExpiryDate != null)
                Text(
                    'TCC Expires: ${_user!.tccExpiryDate!.toString().substring(0, 10)}',
                    style: TextStyle(
                      color: _user!.tccExpiryDate!.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.w500,
                    )),
              const SizedBox(height: 16),
            ],
            // Company Logo Customization
            const Text('Company Logo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logoBase64 != null
                  ? Image.memory(
                      base64Decode(_logoBase64!),
                      fit: BoxFit.contain,
                    )
                  : const Center(
                      child: Text('No logo uploaded',
                          style: TextStyle(color: Colors.grey)),
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickLogoFile,
                  icon: const Icon(Icons.image),
                  label: const Text('Upload Logo'),
                ),
                const SizedBox(width: 8),
                if (_logoBase64 != null)
                  ElevatedButton.icon(
                    onPressed: _removeLogo,
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Import Data (JSON or CSV)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Text(
              'Paste JSON/CSV data or choose a file. CSV headers must match field names.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _importController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste JSON or CSV data here',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/help/sample-data'),
                  icon: const Icon(Icons.data_object),
                  label: const Text('View Samples'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose file'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _importJson,
                  child: const Text('Import'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Help & Support',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Phase 3 Settings
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('Choose your preferred language'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/settings/language'),
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.green[600]),
              title: const Text('WhatsApp Notifications'),
              subtitle: const Text('Manage WhatsApp alerts & bot'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/settings/whatsapp'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('FAQ'),
              subtitle: const Text('Frequently asked questions'),
              onTap: () => Navigator.pushNamed(context, '/help/faq'),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Help Articles'),
              subtitle: const Text('Step-by-step guides and how-tos'),
              onTap: () => Navigator.pushNamed(context, '/help/articles'),
            ),
            ListTile(
              leading: const Icon(Icons.contact_support_outlined),
              title: const Text('Contact Support'),
              subtitle: const Text('Email our support team'),
              onTap: () => Navigator.pushNamed(context, '/help/contact'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              subtitle: const Text('How we collect and use data'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('Permanently delete your account and data'),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('This will permanently delete:'),
            SizedBox(height: 8),
            Text('• Your profile and settings'),
            Text('• All tax calculations and data'),
            Text('• Payment history and records'),
            Text('• Subscription information'),
            SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Delete all user data
        await HiveService.clearAllData();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to login
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
