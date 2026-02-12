import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/hive_service.dart';
import 'package:taxng_advisor/models/user.dart';
import 'package:taxng_advisor/features/help/privacy_policy_screen.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';
import 'package:taxng_advisor/theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _user;
  String? _logoBase64;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadLogo();
  }

  Future<void> _loadUser() async {
    final u = await AuthService.currentUser();
    if (!mounted) return;
    setState(() => _user = u);
  }

  Future<void> _loadLogo() async {
    try {
      final box = HiveService.getProfileBox();
      final logo = box.get('company_logo') as String?;
      if (!mounted) return;
      setState(() => _logoBase64 = logo);
    } catch (_) {}
  }

  Future<void> _pickLogoFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (res == null || !mounted) return;
    final bytes = res.files.first.bytes;
    if (bytes == null) return;

    // Convert to base64 for storage
    final base64Logo = base64Encode(bytes);
    try {
      final box = HiveService.getProfileBox();
      await box.put('company_logo', base64Logo);
      if (!mounted) return;
      setState(() => _logoBase64 = base64Logo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save logo. Please try again.')),
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
        const SnackBar(
            content: Text('Failed to remove logo. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
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
                Text(
                    'BVN: ${'*' * (_user!.bvn!.length - 4)}${_user!.bvn!.substring(_user!.bvn!.length - 4)}',
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
                          ? Theme.of(context).colorScheme.error
                          : TaxNGColors.success,
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
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logoBase64 != null
                  ? Image.memory(
                      base64Decode(_logoBase64!),
                      fit: BoxFit.contain,
                    )
                  : Center(
                      child: Text('No logo uploaded',
                          style: TextStyle(color: Theme.of(context).hintColor)),
                    ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickLogoFile,
                  icon: const Icon(Icons.image),
                  label: const Text('Upload Logo'),
                ),
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
            // Import Data section — styled to match the Import Data screen
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TaxNGColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TaxNGColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.upload_file_rounded,
                            color: TaxNGColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Import Data',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: TaxNGColors.textDark,
                              ),
                            ),
                            Text(
                              'CSV, JSON & Excel (.xlsx) • Bank statements, invoices, etc.',
                              style: TextStyle(
                                fontSize: 12,
                                color: TaxNGColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/import-data'),
                          icon: const Icon(Icons.folder_open_rounded, size: 18),
                          label: const Text('Choose File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TaxNGColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/import-data'),
                          icon:
                              const Icon(Icons.cloud_upload_rounded, size: 18),
                          label: const Text('Import'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TaxNGColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // View import history link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/import-history'),
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text('View Import History'),
                        style: TextButton.styleFrom(
                          foregroundColor: TaxNGColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
              leading: Icon(Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Delete Account',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
            const SnackBar(
              content: Text('Failed to delete account. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
