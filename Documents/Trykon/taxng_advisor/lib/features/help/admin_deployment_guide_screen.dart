import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/theme/colors.dart';

/// Admin-only screen for app deployment and testing information
class AdminDeploymentGuideScreen extends StatefulWidget {
  const AdminDeploymentGuideScreen({super.key});

  @override
  State<AdminDeploymentGuideScreen> createState() =>
      _AdminDeploymentGuideScreenState();
}

class _AdminDeploymentGuideScreenState
    extends State<AdminDeploymentGuideScreen> {
  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final currentUser = await AuthService.currentUser();
    if (currentUser == null || !currentUser.isAdmin) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deployment & Testing Guide'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TaxNGColors.primaryDark, TaxNGColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('TaxNG Advisor - Launch & Testing Guide'),
            const SizedBox(height: 8),
            _buildText(
              'Complete guide for launching the TaxNG Advisor app for user testing and deployment.',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('🚀 Recommended for Nigerian Users'),
            const SizedBox(height: 12),
            _buildBulletList([
              'Android APK (Direct Distribution) - Most Nigerians use Android, no Play Store fees initially, instant testing, WhatsApp distribution works well',
              'Web Version (Firebase Hosting) - No installation needed, works on all devices, easy to update, share link',
              'Google Play Internal Testing - Professional distribution when ready for wider testing',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('⚡ Quick Command (Start Now)'),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Build Android APK',
              'flutter build apk --release',
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildText(
              'File location: build\\app\\outputs\\flutter-apk\\app-release.apk',
            ),
            const SizedBox(height: 8),
            _buildBulletList([
              'Send to testers via WhatsApp',
              'Share via Email or Google Drive link',
              'Testers tap to install',
              'Estimated build time: 2-5 minutes',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('📱 Testing & Deployment Options'),
            const SizedBox(height: 12),
            _buildOptionCard(
              '1. Android APK (Direct Distribution)',
              'flutter build apk --release',
              [
                'No cost',
                'Instant distribution',
                'Works on all Android devices'
              ],
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              '2. Web Testing (Firebase Hosting)',
              'flutter build web --release\nfirebase deploy --only hosting',
              [
                'Free hosting',
                'Accessible from any device',
                'No installation needed',
                'Easy to update'
              ],
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              '3. Google Play Internal Testing',
              'flutter build appbundle --release',
              [
                'Professional distribution',
                'Automatic updates',
                'Up to 100 testers initially',
                'Better credibility'
              ],
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              '4. Windows Testing',
              'flutter build windows --release',
              [
                'For local testing',
                'Output: build\\windows\\x64\\runner\\Release\\',
                'Share as zip file'
              ],
              Colors.teal,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('🎯 Recommended Testing Strategy'),
            const SizedBox(height: 12),
            _buildNumberedList([
              'Phase 1 (Today) - Build Android APK and share directly with testers',
              'Phase 2 (This Week) - Deploy web version to Firebase for broader testing',
              'Phase 3 (Next Month) - Submit to Google Play Internal Testing → Open Testing → Production',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('📋 Pre-Launch Checklist'),
            const SizedBox(height: 12),
            _buildBulletList([
              'Update version in pubspec.yaml (currently 1.0.0+1)',
              'Test locally: flutter run --release',
              'Run unit tests: flutter test',
              'Build for target platform',
              'Test the built APK on real device',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('💡 Distribution Methods'),
            const SizedBox(height: 12),
            _buildBulletList([
              'WhatsApp - Best for quick sharing in Nigeria',
              'Email - Professional approach',
              'Google Drive - Easy link sharing',
              'Telegram/Messenger - Fast distribution',
              'Your own website - Professional image',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('🔧 Detailed Setup Instructions'),
            const SizedBox(height: 12),
            _buildText(
              'Firebase Hosting Setup:',
              isBold: true,
            ),
            const SizedBox(height: 8),
            _buildNumberedList([
              'Install Firebase CLI: npm install -g firebase-tools',
              'Login: firebase login',
              'Initialize: firebase init hosting',
              'Build: flutter build web --release',
              'Deploy: firebase deploy --only hosting',
              'Share URL: https://your-app.web.app',
            ]),
            const SizedBox(height: 24),
            _buildText(
              'Google Play Internal Testing Setup:',
              isBold: true,
            ),
            const SizedBox(height: 8),
            _buildNumberedList([
              'Create Google Play Console account (₦25 one-time fee)',
              'Build App Bundle: flutter build appbundle --release',
              'Upload to Internal Testing track',
              'Add testers by email (up to 100)',
              'Testers install via Play Store link',
              'Updates pushed automatically',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('📊 File Locations After Build'),
            const SizedBox(height: 12),
            _buildCodeBlock(
              'Android APK:\n'
              'build\\app\\outputs\\flutter-apk\\app-release.apk\n\n'
              'App Bundle:\n'
              'build\\app\\outputs\\bundle\\release\\app-release.aab\n\n'
              'Web:\n'
              'build\\web\\\n\n'
              'Windows:\n'
              'build\\windows\\x64\\runner\\Release\\',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('✅ Testing Verification'),
            const SizedBox(height: 12),
            _buildBulletList([
              'Test admin login (admin / Admin@123)',
              'Test regular user login (testuser / Test@1234)',
              'Verify all 6 tax calculators work',
              'Test pricing display',
              'Verify admin can edit pricing',
              'Test sample data import',
              'Check currency conversion display',
              'Verify admin documentation access',
              'Test reminder notifications',
              'Confirm data persistence across sessions',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('🌍 Nigerian Context Notes'),
            const SizedBox(height: 12),
            _buildBulletList([
              'Most users will be on Android - prioritize APK distribution',
              'Data connections may be intermittent - offline-first is important',
              'App functions without cloud sync - all data stored locally',
              'Support WhatsApp distribution for wider reach',
              'Consider SMS-based testing updates for low-bandwidth users',
            ]),
            const SizedBox(height: 24),
            _buildInfoCard(
              'Ready to Launch!',
              'Your app is production-ready. Start with Phase 1 (Android APK) for immediate testing.',
              Colors.green,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildText(String text, {bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(item, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(items[index], style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    String title,
    String command,
    List<String> benefits,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            _buildCodeBlock(command),
            const SizedBox(height: 8),
            ...benefits.map((benefit) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          Text(benefit, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
