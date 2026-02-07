import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/bank_account_config.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

/// Admin-Only Screen for Managing Bank Account Configuration
///
/// This screen allows main administrators to:
/// - View current bank account details
/// - Update bank account information (future feature)
/// - Test bank account display
/// - View security logs (future feature)
class AdminBankAccountConfigScreen extends StatefulWidget {
  const AdminBankAccountConfigScreen({Key? key}) : super(key: key);

  @override
  State<AdminBankAccountConfigScreen> createState() =>
      _AdminBankAccountConfigScreenState();
}

class _AdminBankAccountConfigScreenState
    extends State<AdminBankAccountConfigScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final user = await AuthService.currentUser();

    // Require main admin access for bank account configuration
    if (user == null || !user.isMainAdmin) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Main Admin privileges required.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $label copied to clipboard'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Access Denied')),
      );
    }

    final accounts = BankAccountConfig.getBankAccounts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Account Configuration'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            tooltip: 'Security Info',
            onPressed: _showSecurityInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Warning Banner
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings,
                        color: Colors.red[700], size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠️ ADMIN ONLY - SENSITIVE INFORMATION',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This page contains sensitive bank account details. '
                            'Do not share screenshots or information from this page.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Current Configuration Section
            Text(
              'Current Bank Account Configuration',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'These accounts are displayed to users when they select bank transfer payment',
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Bank Accounts
            ...accounts.asMap().entries.map((entry) {
              final index = entry.key;
              final account = entry.value;
              final isPrimary = account['isPrimary'] == 'true';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isPrimary
                                  ? Colors.green[100]
                                  : Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.account_balance,
                              color: isPrimary
                                  ? Colors.green[700]
                                  : Colors.blue[700],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isPrimary
                                          ? 'Primary Account'
                                          : 'Alternate Account',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (isPrimary) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green[700],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'PRIMARY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  'Account ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Bank Name',
                        account['bankName']!,
                        Icons.account_balance,
                        onCopy: () => _copyToClipboard(
                          account['bankName']!,
                          'Bank Name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Account Number',
                        account['accountNumber']!,
                        Icons.credit_card,
                        onCopy: () => _copyToClipboard(
                          account['accountNumber']!,
                          'Account Number',
                        ),
                        sensitive: true,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Account Name',
                        account['accountName']!,
                        Icons.person,
                        onCopy: () => _copyToClipboard(
                          account['accountName']!,
                          'Account Name',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Support Contact Info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Support Contact Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Support Email',
                      BankAccountConfig.supportEmail,
                      Icons.email,
                      onCopy: () => _copyToClipboard(
                        BankAccountConfig.supportEmail,
                        'Support Email',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Support Phone',
                      BankAccountConfig.supportPhone,
                      Icons.phone,
                      onCopy: () => _copyToClipboard(
                        BankAccountConfig.supportPhone,
                        'Support Phone',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Configuration Instructions
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'How to Update Configuration',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'To update bank account details:\n\n'
                      '1. Open: lib/config/bank_account_config.dart\n'
                      '2. Update the const values for bank details\n'
                      '3. Rebuild and redeploy the application\n\n'
                      '⚠️ Important: Always use secure channels when updating bank details.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Subscription Tier System Explanation
            Text(
              'Subscription Tier System Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Understanding user types vs subscription tiers',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber[700], size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Important: User Type ≠ Subscription Tier',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // User Type vs Subscription Tier
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1️⃣ USER TYPE (isBusiness flag)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• isBusiness: false → Individual person\n'
                            '• isBusiness: true → Company/Business entity\n\n'
                            'This only identifies WHO the user is, not what they can access.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2️⃣ SUBSCRIPTION TIER (subscriptionTier)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• "free" (₦0/month) - View-only, example data\n'
                            '• "individual" (₦3,000/month) - Full calculators, PDF export\n'
                            '• "business" (₦12,000/month) - VAT tools, multi-user, vault\n'
                            '• "enterprise" (₦50,000/month) - Unlimited users, API, dedicated manager\n\n'
                            'This determines WHAT FEATURES the user can access.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Common Mistake: A business entity (isBusiness: true) registering does NOT automatically get Business tier features. They start on FREE tier and must UPGRADE to "business" subscription tier (₦12,000/month) to access Business Tools.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Business Tools Visibility Logic
            Card(
              color: Colors.indigo[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility,
                            color: Colors.indigo[700], size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Business Tools Visibility Logic',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard Code (dashboard_screen.dart):',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: Colors.indigo[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'if (user.subscriptionTier == \'business\' || user.isAdmin) {\n'
                              '  // Show Business Tools section\n'
                              '}',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '✅ Business Tools are visible when:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• subscriptionTier == "business" (paid ₦12,000/month), OR\n'
                            '• user.isAdmin == true (any admin role)',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '❌ Business Tools are NOT visible when:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• isBusiness: true but subscriptionTier: "free"\n'
                            '• subscriptionTier: "individual" or "enterprise"\n'
                            '• Any user who hasn\'t paid for Business tier',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business Tools Include:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Team Management (/business/team)\n'
                            '2. Document Vault (/business/vault)\n'
                            '3. VAT Form 002 (/business/vat-form-002)',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 4 Subscription Tiers Details
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payments,
                            color: Colors.green[700], size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The 4 Subscription Tiers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTierCard(
                      'FREE',
                      '₦0/month',
                      Colors.grey,
                      [
                        'View-only calculator access',
                        'Example data button only',
                        'No custom data entry',
                        'No PDF export or sharing',
                        'No calculation history',
                      ],
                      'Default for all new registrations',
                    ),
                    const SizedBox(height: 12),
                    _buildTierCard(
                      'INDIVIDUAL',
                      '₦3,000/month',
                      Colors.blue,
                      [
                        'Unlimited calculations',
                        'PDF export & sharing',
                        '6 months calculation history',
                        'Tax reminders',
                        'CSV/JSON import/export',
                      ],
                      'For freelancers and sole proprietors',
                    ),
                    const SizedBox(height: 12),
                    _buildTierCard(
                      'BUSINESS',
                      '₦12,000/month',
                      Colors.orange,
                      [
                        'Everything in Individual',
                        '⭐ VAT refund tools (Form 002)',
                        '⭐ Document vault',
                        '⭐ Multiple users (up to 5)',
                        'Unlimited history',
                        'Priority support',
                      ],
                      'Most Popular - Required for Business Tools access',
                    ),
                    const SizedBox(height: 12),
                    _buildTierCard(
                      'ENTERPRISE',
                      '₦50,000/month',
                      Colors.purple,
                      [
                        'Everything in Business',
                        'Unlimited users',
                        'Dedicated account manager',
                        'Custom integrations & API',
                        'Tax advisor consultation',
                        'White-label option',
                      ],
                      'For large organizations',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // User Upgrade Flow Section (All Tiers)
            Text(
              'User Upgrade Flow (All Tiers)',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'How users upgrade from Free to Individual, Business, or Enterprise tiers',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.upgrade,
                            color: Colors.purple[700], size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Complete Upgrade Process',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildUpgradeStep(
                      '1',
                      'Access Points',
                      'Users can upgrade from:\n'
                          '• Pricing Screen: /help/pricing → "Upgrade Now" button\n'
                          '• Calculator Screens: When hitting tier limits\n'
                          '• Direct Route: /subscription/upgrade',
                      Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildUpgradeStep(
                      '2',
                      'Plan Selection',
                      'User selects desired tier (higher than current):\n'
                          '• Individual Tier (₦3,000/month)\n'
                          '• Business Tier (₦12,000/month) - Most Popular ⭐\n'
                          '• Enterprise Tier (₦50,000/month)\n'
                          '\nUpgrade Paths:\n'
                          '• FREE → Individual, Business, or Enterprise\n'
                          '• Individual → Business or Enterprise\n'
                          '• Business → Enterprise',
                      Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildUpgradeStep(
                      '3',
                      'Bank Details Display',
                      'BankAccountDetailsCard shows:\n'
                          '• Access Bank: ${BankAccountConfig.primaryAccountNumber}\n'
                          '• GTBank: ${BankAccountConfig.alternateAccountNumber}\n'
                          '• Account Name: ${BankAccountConfig.primaryAccountName}\n'
                          '• Copy-to-clipboard for each field',
                      Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildUpgradeStep(
                      '4',
                      'Payment Instructions',
                      '• Make direct bank transfer\n'
                          '• Upload payment receipt/screenshot\n'
                          '• Enter amount paid (required)\n'
                          '• Optional: Bank name, account number, notes',
                      Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildUpgradeStep(
                      '5',
                      'Submission & Verification',
                      '• User clicks "Submit with Payment Proof"\n'
                          '• Request sent to admin for review\n'
                          '• Admin verifies payment (24-48 hours)\n'
                          '• Subscription activated upon approval',
                      Colors.purple,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[700]!, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '✅ Same process for ALL users: Free, Individual, Business, Enterprise!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Free tier users can upgrade to Individual, Business, or Enterprise. Individual users can upgrade to Business or Enterprise. Business users can upgrade to Enterprise. Same bank details, payment proof, and verification process for everyone.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Test User Credentials
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: Colors.teal[700], size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Test User for Verification',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Test Accounts for Upgrade Flow:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal[400]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person,
                                  color: Colors.teal[700], size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'testuser (FREE TIER - Individual)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('Password: ',
                                  style: TextStyle(fontSize: 12)),
                              const Text(
                                'Test@1234',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                tooltip: 'Copy credentials',
                                onPressed: () => _copyToClipboard(
                                  'testuser / Test@1234',
                                  'testuser credentials',
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '→ Can upgrade to: Individual, Business, or Enterprise',
                            style: TextStyle(
                                fontSize: 11, color: Colors.teal[900]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.purple[400]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.business,
                                  color: Colors.purple[700], size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'business1 (BUSINESS TIER)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('Password: ',
                                  style: TextStyle(fontSize: 12)),
                              const Text(
                                'Biz@1234',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                tooltip: 'Copy credentials',
                                onPressed: () => _copyToClipboard(
                                  'business1 / Biz@1234',
                                  'business1 credentials',
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '→ Can upgrade to: Enterprise only',
                            style: TextStyle(
                                fontSize: 11, color: Colors.purple[900]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange[700], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Use testuser (Free) to test upgrades to Individual/Business/Enterprise, or business1 (Business) to test Business→Enterprise upgrade.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'All Test Users (For Testing & Admin Functions):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTestUserRow('testuser', 'Test@1234', 'Regular User'),
                    _buildTestUserRow('business1', 'Biz@1234', 'Business User'),
                    _buildTestUserRow('admin', 'Admin@123', 'Main Admin'),
                    _buildTestUserRow(
                        'subadmin1', 'SubAdmin1@123', 'Sub Admin 1'),
                    _buildTestUserRow(
                        'subadmin2', 'SubAdmin2@123', 'Sub Admin 2'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeStep(
    String number,
    String title,
    String description,
    MaterialColor color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color[700],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color[900],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: color[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestUserRow(String username, String password, String role) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              username,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              password,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.red,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              role,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            tooltip: 'Copy credentials',
            onPressed: () => _copyToClipboard(
              '$username / $password',
              'Credentials',
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onCopy,
    bool sensitive = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: sensitive ? Colors.red[900] : null,
                      ),
                    ),
                  ),
                  if (onCopy != null)
                    IconButton(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy $label',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTierCard(
    String name,
    String price,
    MaterialColor color,
    List<String> features,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color[900],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: color[800],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: color[700]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.red),
            SizedBox(width: 8),
            Text('Security Information'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bank Account Security',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                '✓ This page is restricted to Main Admin only\n'
                '✓ Bank details are only shown to authenticated users making payments\n'
                '✓ Account numbers are displayed with copy protection\n'
                '✓ All access to this page is logged\n\n'
                'Best Practices:\n'
                '• Never share screenshots of this page\n'
                '• Update bank details through secure channels only\n'
                '• Regularly audit payment verification logs\n'
                '• Monitor for suspicious payment activities\n'
                '• Keep support contact information up to date',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
