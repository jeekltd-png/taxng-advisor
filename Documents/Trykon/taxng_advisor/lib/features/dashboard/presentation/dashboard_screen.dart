import 'package:flutter/material.dart';
import 'package:taxng_advisor/widgets/sync_status_indicator.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';
import 'package:taxng_advisor/theme/colors.dart';

/// Dashboard Screen - Main entry point
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaxNGColors.bgLight,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: TaxNGColors.heroGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calculate_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'TaxNG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Smart Tax Made Simple',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                  context, Icons.person_outline_rounded, 'Profile', '/profile'),
              _buildDrawerItem(context, Icons.dashboard_outlined,
                  'Tax Overview', '/tax-overview'),
              _buildDrawerItem(context, Icons.history_rounded,
                  'Calculation History', '/history'),
              _buildDrawerItem(
                  context, Icons.folder_outlined, 'My Templates', '/templates'),
              _buildDrawerItem(context, Icons.notifications_outlined,
                  'Reminders', '/reminders'),
              _buildDrawerItem(context, Icons.receipt_long_outlined,
                  'Payment History', '/payment/history'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              _buildDrawerItem(context, Icons.category_outlined,
                  'Expense Categories', '/expenses'),
              _buildDrawerItem(context, Icons.share_outlined,
                  'Share with Accountant', '/share'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              _buildDrawerItem(context, Icons.calendar_today_outlined,
                  'Tax Calendar', '/calendar'),
              _buildDrawerItem(context, Icons.help_outline_rounded,
                  'Help & FAQ', '/help/faq'),
              _buildDrawerItem(context, Icons.article_outlined, 'Help Articles',
                  '/help/articles'),
              _buildDrawerItem(context, Icons.feedback_outlined,
                  'Send Feedback', '/help/feedback'),
              _buildDrawerItem(context, Icons.support_agent_outlined,
                  'Contact Support', '/help/contact'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: const Icon(Icons.logout_rounded,
                    color: TaxNGColors.error, size: 22),
                title: const Text('Logout',
                    style: TextStyle(
                        color: TaxNGColors.error, fontWeight: FontWeight.w600)),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SyncStatusIndicator(),
            const SizedBox(height: 20),

            // Welcome card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: TaxNGColors.heroGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👋 Welcome to TaxNG',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your Padi for Nigerian Tax Matters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Tax Calculators',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TaxNGColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: const [
                _TaxTile(
                    title: 'VAT',
                    subtitle: 'Value Added Tax',
                    route: '/vat',
                    icon: Icons.receipt_rounded,
                    color: Color(0xFF16A34A)),
                _TaxTile(
                    title: 'PIT',
                    subtitle: 'Personal Income',
                    route: '/pit',
                    icon: Icons.person_rounded,
                    color: Color(0xFF0D9488)),
                _TaxTile(
                    title: 'CIT',
                    subtitle: 'Corporate Income',
                    route: '/cit',
                    icon: Icons.business_rounded,
                    color: Color(0xFF6366F1)),
                _TaxTile(
                    title: 'WHT',
                    subtitle: 'Withholding Tax',
                    route: '/wht',
                    icon: Icons.attach_money_rounded,
                    color: Color(0xFFEC4899)),
                _TaxTile(
                    title: 'Payroll',
                    subtitle: 'Employee Taxes',
                    route: '/payroll',
                    icon: Icons.payments_rounded,
                    color: Color(0xFF8B5CF6)),
                _TaxTile(
                    title: 'Stamp Duty',
                    subtitle: 'Instruments & Docs',
                    route: '/stamp_duty',
                    icon: Icons.description_rounded,
                    color: Color(0xFFF59E0B)),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TaxNGColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            _QuickActionButton(
              icon: Icons.notifications_active_rounded,
              label: 'Tax Reminders',
              onTap: () => Navigator.pushNamed(context, '/reminders'),
            ),
            const SizedBox(height: 10),
            _QuickActionButton(
              icon: Icons.help_center_rounded,
              label: 'Help & FAQ',
              onTap: () => Navigator.pushNamed(context, '/help/faq'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: TaxNGColors.primary, size: 22),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      onTap: () => Navigator.pushNamed(context, route),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TaxNGColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TaxNGColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: TaxNGColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TaxNGColors.textDark,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: TaxNGColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaxTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;

  const _TaxTile({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TaxNGColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TaxNGColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: TaxNGColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
