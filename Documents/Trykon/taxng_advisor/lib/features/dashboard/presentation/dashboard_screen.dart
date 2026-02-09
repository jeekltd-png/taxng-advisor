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
import 'package:taxng_advisor/services/calculation_history_service.dart';
import 'package:intl/intl.dart';

/// Dashboard Screen - Main entry point
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isAdmin = false;
  bool _isBusiness = false;
  List<Map<String, dynamic>> _recentCalcs = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final isAdmin = await AdminAccessControl.isAdmin();
    final user = await AuthService.currentUser();
    final calcs =
        await CalculationHistoryService.getRecentCalculations(limit: 3);
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isBusiness = user?.isBusiness ?? false;
        _recentCalcs = calcs;
      });
    }
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
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Recent Calculations (before tax calculators) ──
            _buildRecentCalculations(isDark),
            const SizedBox(height: 24),

            // ── Business Tools (only for Business users + Admins) ──
            if (_isBusiness || _isAdmin) ...[
              _buildBusinessTools(isDark),
              const SizedBox(height: 24),
            ],

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
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                final childAspectRatio =
                    constraints.maxWidth > 600 ? 1.3 : 1.15;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
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
                );
              },
            ),
            const SizedBox(height: 24),

            Text(
              'More Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : TaxNGColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MoreOptionCard(
                    icon: Icons.pie_chart_rounded,
                    label: 'Tax Overview',
                    color: const Color(0xFF16A34A),
                    isDark: isDark,
                    onTap: () => Navigator.pushNamed(context, '/tax-overview'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MoreOptionCard(
                    icon: Icons.notifications_active_rounded,
                    label: 'Reminders',
                    color: const Color(0xFFF59E0B),
                    isDark: isDark,
                    onTap: () => Navigator.pushNamed(context, '/reminders'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MoreOptionCard(
                    icon: Icons.help_center_rounded,
                    label: 'Help',
                    color: const Color(0xFF3B82F6),
                    isDark: isDark,
                    onTap: () => Navigator.pushNamed(context, '/help/faq'),
                  ),
                ),
              ],
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
                      color: Colors.white.withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.85),
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
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.upload_file_rounded,
                  color: TaxNGColors.primary, size: 22),
              title: const Text('Import Data',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: TaxNGColors.primary,
                  )),
              onTap: () => Navigator.pushNamed(context, '/import-data'),
              dense: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            _buildDrawerItem(context, Icons.history_rounded, 'Import History',
                '/import-history',
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
              activeThumbColor: TaxNGColors.primary,
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

  // ─── Recent Calculations Section ──────────────────────────────────

  Widget _buildRecentCalculations(bool isDark) {
    final fmt = NumberFormat('#,##0.00');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, color: TaxNGColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recent Calculations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
              const Spacer(),
              if (_recentCalcs.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/history'),
                  child: const Text('View All', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_recentCalcs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.calculate_outlined,
                        size: 40,
                        color:
                            isDark ? Colors.white24 : TaxNGColors.textLighter),
                    const SizedBox(height: 8),
                    Text(
                      'No calculations yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white38 : TaxNGColors.textLight,
                      ),
                    ),
                    Text(
                      'Start with a calculator below',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.white24 : TaxNGColors.textLighter,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(_recentCalcs.map((calc) {
              final type = calc['type'] ?? 'Tax';
              final amount = calc['amount'] ?? 0.0;
              final date = calc['date'] as String?;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: TaxNGColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          type.toString().substring(
                              0,
                              type.toString().length > 3
                                  ? 3
                                  : type.toString().length),
                          style: const TextStyle(
                            color: TaxNGColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$type Calculation',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white : TaxNGColors.textDark,
                            ),
                          ),
                          if (date != null)
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white38
                                    : TaxNGColors.textLight,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '₦${fmt.format(amount)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: TaxNGColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            })),
        ],
      ),
    );
  }

  // ─── Business Tools Section ───────────────────────────────────────

  Widget _buildBusinessTools(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.business_center_rounded,
                color: TaxNGColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Business Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : TaxNGColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _BusinessToolTile(
                  title: 'Team',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/business/team'),
                ),
                _BusinessToolTile(
                  title: 'Vault',
                  icon: Icons.folder_rounded,
                  color: const Color(0xFF0D9488),
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/business/vault'),
                ),
                _BusinessToolTile(
                  title: 'VAT 002',
                  icon: Icons.description_rounded,
                  color: const Color(0xFF16A34A),
                  isDark: isDark,
                  onTap: () =>
                      Navigator.pushNamed(context, '/business/vat-form'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Business tool tile card
class _BusinessToolTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _BusinessToolTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: title,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _MoreOptionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: label,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
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
      child: Semantics(
        button: true,
        label: '${widget.title} calculator. ${widget.subtitle}',
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
                    color: widget.color.withValues(alpha: 0.1),
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
                    color:
                        widget.isDark ? Colors.white54 : TaxNGColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
