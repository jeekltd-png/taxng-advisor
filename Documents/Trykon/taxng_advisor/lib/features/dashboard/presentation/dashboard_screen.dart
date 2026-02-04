import 'package:flutter/material.dart';
import 'package:taxng_advisor/widgets/sync_status_indicator.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';

/// Dashboard Screen - Main entry point
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF1B5E20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TaxNG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Smart Tax Made Simple',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading:
                    const Icon(Icons.person_outline, color: Color(0xFF1B5E20)),
                title: const Text('Profile'),
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined,
                    color: Color(0xFF1B5E20)),
                title: const Text('Tax Overview'),
                onTap: () => Navigator.pushNamed(context, '/tax-overview'),
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF1B5E20)),
                title: const Text('Calculation History'),
                onTap: () => Navigator.pushNamed(context, '/history'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.folder_outlined, color: Color(0xFF1B5E20)),
                title: const Text('My Templates'),
                onTap: () => Navigator.pushNamed(context, '/templates'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF1B5E20)),
                title: const Text('Reminders'),
                onTap: () => Navigator.pushNamed(context, '/reminders'),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined,
                    color: Color(0xFF1B5E20)),
                title: const Text('Payment History'),
                onTap: () => Navigator.pushNamed(context, '/payment/history'),
              ),
              const Divider(),
              // Phase 3 Features
              ListTile(
                leading: const Icon(Icons.category_outlined,
                    color: Color(0xFF1B5E20)),
                title: const Text('Expense Categories'),
                onTap: () => Navigator.pushNamed(context, '/expenses'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.share_outlined, color: Color(0xFF1B5E20)),
                title: const Text('Share with Accountant'),
                onTap: () => Navigator.pushNamed(context, '/share'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF1B5E20)),
                title: const Text('Tax Calendar'),
                onTap: () => Navigator.pushNamed(context, '/calendar'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.help_outline, color: Color(0xFF1B5E20)),
                title: const Text('Help & FAQ'),
                onTap: () => Navigator.pushNamed(context, '/help/faq'),
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined,
                    color: Color(0xFF1B5E20)),
                title: const Text('Help Articles'),
                onTap: () => Navigator.pushNamed(context, '/help/articles'),
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined,
                    color: Color(0xFF1B5E20)),
                title: const Text('Send Feedback'),
                onTap: () => Navigator.pushNamed(context, '/help/feedback'),
              ),
              ListTile(
                leading: const Icon(Icons.support_agent_outlined,
                    color: Color(0xFF1B5E20)),
                title: const Text('Contact Support'),
                onTap: () => Navigator.pushNamed(context, '/help/contact'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      appBar: const TaxNGAppBar(title: 'TaxNG'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync Status Indicator
            const SyncStatusIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Tax Calculators',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2, // Adjust tile height for better visibility
              children: [
                _TaxTile(
                  title: 'VAT',
                  route: '/vat',
                  context: context,
                ),
                _TaxTile(
                  title: 'PIT',
                  route: '/pit',
                  context: context,
                ),
                _TaxTile(
                  title: 'CIT',
                  route: '/cit',
                  context: context,
                ),
                _TaxTile(
                  title: 'WHT',
                  route: '/wht',
                  context: context,
                ),
                _TaxTile(
                  title: 'Payroll',
                  route: '/payroll',
                  context: context,
                ),
                _TaxTile(
                  title: 'Stamp Duty',
                  route: '/stamp_duty',
                  context: context,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'More Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications),
              label: const Text('Tax Reminders'),
              onPressed: () => Navigator.pushNamed(context, '/reminders'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.help_outline),
              label: const Text('Help & FAQ'),
              onPressed: () => Navigator.pushNamed(context, '/help/faq'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaxTile extends StatelessWidget {
  final String title;
  final String route;
  final BuildContext context;

  const _TaxTile({
    required this.title,
    required this.route,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForTax(title),
                size: 40,
                color: const Color(0xFF0066FF), // TaxNG Primary Blue
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTax(String title) {
    switch (title) {
      case 'VAT':
        return Icons.receipt;
      case 'PIT':
        return Icons.person;
      case 'CIT':
        return Icons.business;
      case 'WHT':
        return Icons.attach_money;
      case 'Payroll':
        return Icons.payments;
      case 'Stamp Duty':
        return Icons.description;
      default:
        return Icons.calculate;
    }
  }
}
