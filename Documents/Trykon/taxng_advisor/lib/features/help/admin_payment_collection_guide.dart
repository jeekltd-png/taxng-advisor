import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Admin-only screen for pricing plans explanation and payment collection guide
class AdminPaymentCollectionGuide extends StatefulWidget {
  const AdminPaymentCollectionGuide({super.key});

  @override
  State<AdminPaymentCollectionGuide> createState() =>
      _AdminPaymentCollectionGuideState();
}

class _AdminPaymentCollectionGuideState
    extends State<AdminPaymentCollectionGuide> {
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
        title: const Text('Pricing Plans & Payment Collection'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('💰 4 Pricing Plans Overview'),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: '1. Free Tier',
              price: '₦0/month',
              color: Colors.grey,
              targetAudience: 'New users, curious browsers, trial users',
              userType: 'Any individual wanting to explore the app',
              requirements: [
                'Email registration',
                'No payment required',
                'Immediate access after signup',
              ],
              features: [
                '✓ View-only access to all 6 calculators',
                '✓ Use "Example Data" button to see how it works',
                '✓ See calculated tax amounts',
                '✗ Cannot enter custom data',
                '✗ No PDF export',
                '✗ No share functionality',
                '✗ No calculation history',
                '✗ No tax reminders',
                '✗ No payment recording',
                '✗ No data import (CSV/JSON)',
              ],
              businessCase:
                  'Build trust and let users experience value before paying. Free tier converts to paid when users need real functionality.',
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: '2. Individual Plan',
              price: '₦3,000/month (~\$3.50 USD)',
              annualPrice: '₦30,000/year (Save ₦6,000)',
              color: Colors.blue,
              targetAudience:
                  'Freelancers, consultants, sole traders, small business owners',
              userType:
                  'Individual professionals managing their own tax obligations',
              requirements: [
                'Active email address',
                'Payment method (card, bank transfer, or USSD)',
                'Nigerian phone number (for verification)',
                'Business name/TIN (optional but recommended)',
              ],
              features: [
                '✓ Unlimited calculations across all 6 calculators',
                '✓ PDF export with QR verification',
                '✓ Share results via email/WhatsApp',
                '✓ Calculation history (6 months retention)',
                '✓ Tax payment reminders',
                '✓ Payment recording and tracking',
                '✓ CSV/JSON import and export',
                '✓ Email support (24-48 hour response)',
                '✓ Save calculation templates',
                '✓ Notes and attachments per calculation',
              ],
              businessCase:
                  'Primary revenue driver. Targets Nigeria\'s growing freelance economy and solo entrepreneurs who need professional tax tools.',
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: '3. Business Plan',
              price: '₦12,000/month (~\$14 USD)',
              annualPrice: '₦120,000/year (Save ₦24,000)',
              color: Colors.green,
              targetAudience:
                  'SMEs, accounting firms, tax consultants, growing businesses',
              userType:
                  'Businesses with multiple staff members, registered companies',
              requirements: [
                'Registered business email domain',
                'Business registration certificate (CAC)',
                'Tax Identification Number (TIN)',
                'Contact person details',
                'Payment method (preferably bank transfer for businesses)',
                'Minimum 5 users recommended',
              ],
              features: [
                '✓ Everything in Individual Plan',
                '✓ VAT refund tools (Form 002, reconciliation letters)',
                '✓ Document vault with unlimited storage',
                '✓ Unlimited calculation history (permanent)',
                '✓ Multi-user access (up to 5 users)',
                '✓ Team collaboration features',
                '✓ Priority email support (12-24 hour response)',
                '✓ Tax calculation templates library',
                '✓ Bulk import/export capabilities',
                '✓ Advanced reporting and analytics',
                '✓ Monthly tax compliance reports',
              ],
              businessCase:
                  'Targets SMEs and tax consultants. Price is less than hiring one accountant for a day. High value for small accounting firms.',
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: '4. Enterprise Plan',
              price: '₦50,000/month (~\$60 USD)',
              annualPrice: 'Custom pricing (volume discounts available)',
              color: Colors.deepPurple,
              targetAudience:
                  'Large corporations, multinationals, banks, telecom companies, oil & gas',
              userType: 'Organizations with 20+ employees, complex tax needs',
              requirements: [
                'Corporate email with company domain',
                'Certificate of Incorporation',
                'Tax Identification Number (TIN)',
                'Signed Service Level Agreement (SLA)',
                'Purchase Order or contract required',
                'Designated account manager contact',
                'IT/Technical contact for integration',
                'Security and compliance review',
              ],
              features: [
                '✓ Everything in Business Plan',
                '✓ Unlimited users across organization',
                '✓ Dedicated account manager',
                '✓ Custom API integrations',
                '✓ White-label option (your company branding)',
                '✓ Quarterly tax advisor consultation',
                '✓ Priority phone support (4-hour response)',
                '✓ Custom tax calculation formulas',
                '✓ Advanced security (SSO, 2FA, audit logs)',
                '✓ Custom reports and dashboards',
                '✓ Data migration support',
                '✓ On-premise deployment option',
                '✓ Training for staff members',
              ],
              businessCase:
                  'High-margin tier. One client covers 10+ SME subscriptions. Targets Fortune 500 companies in Nigeria.',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('💳 Payment Collection Methods'),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(
              title: '1. Paystack Integration (Recommended)',
              icon: Icons.credit_card,
              color: Colors.blue,
              howItWorks: [
                'User clicks "Upgrade" in app',
                'Redirected to Paystack payment page',
                'User enters card details (Verve, Mastercard, Visa)',
                'Payment processed instantly',
                'Webhook notifies our system',
                'Subscription activated automatically',
              ],
              advantages: [
                '✓ Instant activation',
                '✓ Automatic recurring billing',
                '✓ Secure payment processing',
                '✓ Accepts all Nigerian cards',
                '✓ USSD and Bank Transfer options',
                '✓ Transaction fee: 1.5% + ₦100',
                '✓ Subscription management built-in',
              ],
              setup: [
                'Create Paystack account (paystack.com)',
                'Verify business (KYC)',
                'Get API keys (test & live)',
                'Integrate subscription plans',
                'Setup webhooks for payment notifications',
                'Test with test cards',
                'Go live',
              ],
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(
              title: '2. Direct Bank Transfer',
              icon: Icons.account_balance,
              color: Colors.green,
              howItWorks: [
                'User selects "Bank Transfer" option',
                'System generates unique payment reference',
                'Shows bank details: Account name, number, bank',
                'User makes transfer via mobile app/USSD',
                'User uploads payment proof in app',
                'Admin verifies payment manually',
                'Admin activates subscription',
              ],
              advantages: [
                '✓ No transaction fees',
                '✓ Works for all banks in Nigeria',
                '✓ Good for businesses with corporate accounts',
                '✓ Higher trust for cautious users',
                '✓ Better for annual subscriptions',
              ],
              setup: [
                'Open dedicated business account for TaxPadi',
                'Display account details clearly',
                'Create payment verification workflow',
                'Build upload proof system in app',
                'Train admin on verification process',
                'Setup email notifications for new transfers',
                'Activate within 24 hours of verification',
              ],
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(
              title: '3. USSD Code (Quick Payment)',
              icon: Icons.dialpad,
              color: Colors.orange,
              howItWorks: [
                'User dials *737*000*Amount*AccountNumber#',
                'Confirms transaction on phone',
                'Receives SMS confirmation',
                'Enters transaction reference in app',
                'System verifies with bank API',
                'Auto-activation after verification',
              ],
              advantages: [
                '✓ Works on any phone (no internet needed)',
                '✓ Fast and convenient',
                '✓ Popular in Nigeria',
                '✓ Good for users without cards',
                '✓ Can automate verification via Paystack',
              ],
              setup: [
                'Integrate with Paystack (includes USSD)',
                'Or partner with bank for direct USSD',
                'Display USSD codes clearly',
                'Build reference verification system',
                'Test with multiple banks',
              ],
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(
              title: '4. Standing Order / Direct Debit',
              icon: Icons.autorenew,
              color: Colors.purple,
              howItWorks: [
                'User sets up standing order with bank',
                'Fixed amount debited monthly on specific date',
                'Bank sends debit alert to user',
                'System checks account for payment',
                'Auto-renew subscription if payment received',
              ],
              advantages: [
                '✓ True "set and forget" automation',
                '✓ Reduces churn (users less likely to cancel)',
                '✓ Good for business/enterprise clients',
                '✓ No technical integration needed',
              ],
              setup: [
                'Provide standing order form template',
                'User submits to their bank',
                'Monitor account for recurring payments',
                'Match payments to user accounts',
                'Send renewal confirmations',
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('🔄 Recommended Payment Flow'),
            const SizedBox(height: 12),
            _buildFlowStep('1', 'User Registration',
                'New users sign up and automatically get Free tier access. No payment required.'),
            _buildFlowStep('2', 'Explore Phase',
                'Users explore calculators with example data. They see value but can\'t use custom data.'),
            _buildFlowStep('3', 'Upgrade Prompt',
                'When user tries to enter custom data, show upgrade modal with pricing plans.'),
            _buildFlowStep('4', 'Plan Selection',
                'User selects Individual, Business, or Enterprise plan based on needs.'),
            _buildFlowStep('5', 'Payment Method',
                'User chooses: Paystack (card/USSD) or Bank Transfer.'),
            _buildFlowStep('6', 'Payment Processing',
                'Paystack: Instant\nBank Transfer: Manual verification within 24 hours'),
            _buildFlowStep('7', 'Activation',
                'Subscription activated, user gets email confirmation and full access.'),
            _buildFlowStep('8', 'Recurring Billing',
                'Paystack auto-charges monthly. Bank transfer requires user action.'),
            const SizedBox(height: 24),
            _buildSectionHeader('📊 Payment Tracking & Management'),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Admin Responsibilities',
              '• Monitor Subscription Management screen daily\n'
                  '• Verify bank transfer payments within 24 hours\n'
                  '• Approve/reject upgrade requests\n'
                  '• Handle failed payment notifications\n'
                  '• Process refund requests\n'
                  '• Track monthly recurring revenue (MRR)\n'
                  '• Follow up on expiring subscriptions\n'
                  '• Respond to payment issues via email',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Automated Features',
              '• Paystack handles recurring charges\n'
                  '• Email reminders 7 days before expiry\n'
                  '• Grace period: 3 days after expiration\n'
                  '• Auto-downgrade to Free after grace period\n'
                  '• Payment failure notifications\n'
                  '• Receipt generation and emailing\n'
                  '• Subscription status updates',
              Colors.green,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('💡 Best Practices'),
            const SizedBox(height: 12),
            _buildBulletList([
              'Start with Paystack only - simplest to implement',
              'Add bank transfer after 50+ users - reduces manual work',
              'Offer 10% discount for annual subscriptions',
              'Send payment reminders 7 days before expiry',
              'Provide 3-day grace period before downgrade',
              'Keep payment records for 7 years (tax law)',
              'Issue receipts for all payments',
              'Respond to payment queries within 24 hours',
              'Monitor failed payments and retry with users',
              'Offer pro-rated refunds for cancellations',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('🎯 Revenue Projections'),
            const SizedBox(height: 12),
            _buildRevenueCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('❓ Common Questions'),
            const SizedBox(height: 12),
            _buildFAQ(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      color: Colors.green[50],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[700]!, width: 2),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green[700], size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pricing & Payment Guide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Complete guide to TaxPadi\'s 4 pricing tiers, target users, '
              'requirements, and payment collection methods for monthly subscriptions.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    String? annualPrice,
    required Color color,
    required String targetAudience,
    required String userType,
    required List<String> requirements,
    required List<String> features,
    required String businessCase,
  }) {
    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (annualPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      annualPrice,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubHeader('Target Audience'),
                  Text(targetAudience, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  _buildSubHeader('User Type'),
                  Text(userType, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  _buildSubHeader('Requirements'),
                  ...requirements.map((req) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ',
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.bold)),
                            Expanded(
                                child: Text(req,
                                    style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  _buildSubHeader('Features'),
                  ...features.map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child:
                            Text(feature, style: const TextStyle(fontSize: 12)),
                      )),
                  const SizedBox(height: 12),
                  _buildSubHeader('Business Case'),
                  Text(businessCase,
                      style: const TextStyle(
                          fontSize: 13, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> howItWorks,
    required List<String> advantages,
    required List<String> setup,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSubHeader('How It Works:'),
            const SizedBox(height: 4),
            ...howItWorks.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
            const SizedBox(height: 12),
            _buildSubHeader('Advantages:'),
            const SizedBox(height: 4),
            ...advantages.map((adv) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(adv, style: const TextStyle(fontSize: 12)),
                )),
            const SizedBox(height: 12),
            _buildSubHeader('Setup Steps:'),
            const SizedBox(height: 4),
            ...setup.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conservative Scenario (Year 1)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRevenueRow('500 Free users', '₦0'),
            _buildRevenueRow('50 Individual (₦3,000/mo)', '₦150,000/month'),
            _buildRevenueRow('10 Business (₦12,000/mo)', '₦120,000/month'),
            _buildRevenueRow('2 Enterprise (₦50,000/mo)', '₦100,000/month'),
            const Divider(),
            _buildRevenueRow('Total Monthly Revenue', '₦370,000', isBold: true),
            _buildRevenueRow('Annual Revenue', '₦4,440,000', isBold: true),
            const SizedBox(height: 8),
            Text(
              'Realistic with focused marketing in Lagos/Abuja',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueRow(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFAQItem(
          'What if user doesn\'t pay on time?',
          '3-day grace period, then auto-downgrade to Free tier. Send reminder emails at 7 days, 3 days, and 1 day before expiry.',
        ),
        _buildFAQItem(
          'Can users switch plans?',
          'Yes. Upgrade takes effect immediately. Downgrade takes effect at next billing cycle.',
        ),
        _buildFAQItem(
          'Refund policy?',
          'Pro-rated refunds within 14 days. No refunds after 14 days, but can cancel anytime.',
        ),
        _buildFAQItem(
          'What about VAT on subscriptions?',
          'Software subscriptions are VAT-exempt in Nigeria. No need to add VAT to prices.',
        ),
        _buildFAQItem(
          'Payment security?',
          'Paystack is PCI-DSS compliant. We never store card details. All transactions encrypted.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q: $question',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'A: $answer',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildInfoCard(String title, String content, Color color) {
    return Card(
      color: color.withOpacity(0.1),
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
}
