import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:taxng_advisor/widgets/sync_status_indicator.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/theme_service.dart';
import 'package:taxng_advisor/services/admin_access_control.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';
import 'package:taxng_advisor/widgets/logout_rating_dialog.dart';
import 'package:taxng_advisor/theme/colors.dart';

/// Dashboard Screen - Main entry point
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final isAdmin = await AdminAccessControl.isAdmin();
    if (mounted) setState(() => _isAdmin = isAdmin);
  }

  Future<void> _handleLogout() async {
    // Show rating dialog before logging out
    await showLogoutRatingDialog(context);

    // User dismissed the dialog or tapped skip — still logout
    await AuthService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
      drawer: _buildDrawer(context, isDark),
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

            Text(
              'Tax Calculators',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : TaxNGColors.textDark,
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
              children: [
                _TaxTile(
                    title: 'VAT',
                    subtitle: 'Value Added Tax',
                    route: '/vat',
                    icon: Icons.receipt_rounded,
                    color: const Color(0xFF16A34A),
                    isDark: isDark),
                _TaxTile(
                    title: 'PIT',
                    subtitle: 'Personal Income',
                    route: '/pit',
                    icon: Icons.person_rounded,
                    color: const Color(0xFF0D9488),
                    isDark: isDark),
                _TaxTile(
                    title: 'CIT',
                    subtitle: 'Corporate Income',
                    route: '/cit',
                    icon: Icons.business_rounded,
                    color: const Color(0xFF6366F1),
                    isDark: isDark),
                _TaxTile(
                    title: 'WHT',
                    subtitle: 'Withholding Tax',
                    route: '/wht',
                    icon: Icons.attach_money_rounded,
                    color: const Color(0xFFEC4899),
                    isDark: isDark),
                _TaxTile(
                    title: 'Payroll',
                    subtitle: 'Employee Taxes',
                    route: '/payroll',
                    icon: Icons.payments_rounded,
                    color: const Color(0xFF8B5CF6),
                    isDark: isDark),
                _TaxTile(
                    title: 'Stamp Duty',
                    subtitle: 'Instruments & Docs',
                    route: '/stamp_duty',
                    icon: Icons.description_rounded,
                    color: const Color(0xFFF59E0B),
                    isDark: isDark),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : TaxNGColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            _QuickActionButton(
              icon: Icons.notifications_active_rounded,
              label: 'Tax Reminders',
              isDark: isDark,
              onTap: () => Navigator.pushNamed(context, '/reminders'),
            ),
            const SizedBox(height: 10),
            _QuickActionButton(
              icon: Icons.help_center_rounded,
              label: 'Help & FAQ',
              isDark: isDark,
              onTap: () => Navigator.pushNamed(context, '/help/faq'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    final themeService = Provider.of<ThemeService>(context);

    return Drawer(
      backgroundColor: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
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
                context, Icons.person_outline_rounded, 'Profile', '/profile',
                isDark: isDark),
            _buildDrawerItem(context, Icons.dashboard_outlined, 'Tax Overview',
                '/tax-overview',
                isDark: isDark),
            _buildDrawerItem(context, Icons.history_rounded,
                'Calculation History', '/history',
                isDark: isDark),
            _buildDrawerItem(
                context, Icons.folder_outlined, 'My Templates', '/templates',
                isDark: isDark),
            _buildDrawerItem(context, Icons.notifications_outlined, 'Reminders',
                '/reminders',
                isDark: isDark),
            _buildDrawerItem(context, Icons.receipt_long_outlined,
                'Payment History', '/payment/history',
                isDark: isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                  color: isDark ? Colors.white12 : TaxNGColors.borderLight),
            ),
            _buildDrawerItem(context, Icons.category_outlined,
                'Expense Categories', '/expenses',
                isDark: isDark),
            _buildDrawerItem(context, Icons.share_outlined,
                'Share with Accountant', '/share',
                isDark: isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                  color: isDark ? Colors.white12 : TaxNGColors.borderLight),
            ),
            _buildDrawerItem(context, Icons.calendar_today_outlined,
                'Tax Calendar', '/calendar',
                isDark: isDark),
            _buildDrawerItem(
                context, Icons.help_outline_rounded, 'Help & FAQ', '/help/faq',
                isDark: isDark),
            _buildDrawerItem(context, Icons.article_outlined, 'Help Articles',
                '/help/articles',
                isDark: isDark),
            _buildDrawerItem(context, Icons.feedback_outlined, 'Send Feedback',
                '/help/feedback',
                isDark: isDark),
            _buildDrawerItem(context, Icons.support_agent_outlined,
                'Contact Support', '/help/contact',
                isDark: isDark),

            // Admin section
            if (_isAdmin) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                    color: isDark ? Colors.white12 : TaxNGColors.borderLight),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white38 : TaxNGColors.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildDrawerItem(context, Icons.star_rate_rounded, 'App Ratings',
                  '/admin/ratings',
                  isDark: isDark),
              _buildDrawerItem(context, Icons.admin_panel_settings_rounded,
                  'Subscriptions', '/admin/subscriptions',
                  isDark: isDark),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                  color: isDark ? Colors.white12 : TaxNGColors.borderLight),
            ),

            // Dark mode toggle
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              secondary: Icon(
                themeService.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: TaxNGColors.primary,
                size: 22,
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
              value: themeService.isDarkMode,
              activeColor: TaxNGColors.primary,
              onChanged: (_) => themeService.toggleTheme(),
              dense: true,
            ),

            // Logout
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.logout_rounded,
                  color: TaxNGColors.error, size: 22),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: TaxNGColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, String route,
      {bool isDark = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: TaxNGColors.primary, size: 22),
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isDark ? Colors.white : TaxNGColors.textDark,
          )),
      onTap: () => Navigator.pushNamed(context, route),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDark = false,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) {
        _animController.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _animController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: widget.isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isDark
                  ? const Color(0xFF2A2A3E)
                  : TaxNGColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TaxNGColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: TaxNGColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white : TaxNGColors.textDark,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color:
                      widget.isDark ? Colors.white38 : TaxNGColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaxTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _TaxTile({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
    this.isDark = false,
  });

  @override
  State<_TaxTile> createState() => _TaxTileState();
}

class _TaxTileState extends State<_TaxTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) {
        _animController.reverse();
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, widget.route);
      },
      onTapCancel: () => _animController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
                  ? const Color(0xFF2A2A3E)
                  : TaxNGColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, size: 24, color: widget.color),
              ),
              const Spacer(),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isDark ? Colors.white54 : TaxNGColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
