import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

class AdminPricingStrategyScreen extends StatefulWidget {
  const AdminPricingStrategyScreen({super.key});

  @override
  State<AdminPricingStrategyScreen> createState() =>
      _AdminPricingStrategyScreenState();
}

class _AdminPricingStrategyScreenState
    extends State<AdminPricingStrategyScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final user = await AuthService.currentUser();
    if (user == null || !user.isAdmin) {
      Navigator.pop(context);
      return;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing Strategy Guide'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildRecommendedModel(),
            const SizedBox(height: 24),
            _buildFreeTier(),
            const SizedBox(height: 16),
            _buildIndividualPlan(),
            const SizedBox(height: 16),
            _buildBusinessPlan(),
            const SizedBox(height: 16),
            _buildEnterprisePlan(),
            const SizedBox(height: 24),
            _buildWhyThisWorks(),
            const SizedBox(height: 24),
            _buildPayPerCalculatorModel(),
            const SizedBox(height: 24),
            _buildAlternativeModel(),
            const SizedBox(height: 24),
            _buildImplementationNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.green[700], size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Recommended Pricing Strategy',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Freemium + Tiered Subscriptions Model',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Optimized for Nigerian market with focus on customer acquisition and scalability',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedModel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  'Best Model: Freemium + Tiered',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This model balances customer acquisition, retention, and revenue growth.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeTier() {
    return _buildPricingCard(
      title: 'Free',
      subtitle: '',
      price: '₦0/month',
      color: Colors.grey,
      features: [
        'View-only access to all calculators',
        'Use "Example Data" button only (no custom data entry)',
        'See calculated tax amounts',
        'No PDF export',
        'No Share functionality',
        'No calculation history',
        'No tax reminders',
        'No payment recording',
        'No data import (CSV/JSON)',
      ],
      note: '',
    );
  }

  Widget _buildIndividualPlan() {
    return _buildPricingCard(
      title: 'Individual Plan',
      subtitle: 'For Freelancers & Sole Traders',
      price: '₦3,000/month',
      annualPrice: '₦30,000/year',
      color: Colors.blue,
      features: [
        'Unlimited calculations',
        'PDF export',
        'Calculation history (6 months)',
        'Tax reminders',
        'Import/export data (CSV, JSON)',
        'Email support',
      ],
      note: 'USD equivalent: ~\$3.50/month - Affordable for individuals',
    );
  }

  Widget _buildBusinessPlan() {
    return _buildPricingCard(
      title: 'Business Plan',
      subtitle: 'For SMEs & Growing Companies',
      price: '₦12,000/month',
      annualPrice: '₦120,000/year',
      color: Colors.green,
      features: [
        'Everything in Individual',
        'VAT refund tools (Form 002, letters, reconciliation)',
        'Document vault',
        'Unlimited history',
        'Multiple users (up to 5)',
        'Priority support',
        'Tax templates',
      ],
      note: 'USD equivalent: ~\$14/month - Less than one tax consultant visit',
    );
  }

  Widget _buildEnterprisePlan() {
    return _buildPricingCard(
      title: 'Enterprise Plan',
      subtitle: 'For Large Organizations',
      price: '₦50,000/month',
      annualPrice: 'Custom pricing available',
      color: Colors.purple,
      features: [
        'Everything in Business',
        'Unlimited users',
        'Dedicated account manager',
        'Custom integrations',
        'Tax advisor consultation (quarterly)',
        'White-label option',
        'API access',
        'Custom reports',
      ],
      note: 'USD equivalent: ~\$60/month - High-value corporate solution',
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String subtitle,
    required String price,
    String? annualPrice,
    required Color color,
    required List<String> features,
    String? note,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (annualPrice != null) ...[
              const SizedBox(height: 4),
              Text(
                annualPrice,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 18, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
            if (note != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note,
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWhyThisWorks() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Why This Works for Nigeria',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBulletPoint(
              '💰 Price Sensitivity',
              'Starting at ₦3,000/month is affordable for individuals while business tier targets SMEs with tax compliance budgets',
            ),
            _buildBulletPoint(
              '💳 Cash Flow',
              'Annual plans save 2 months - aligns with Nigerian discount expectations and encourages commitment',
            ),
            _buildBulletPoint(
              '📊 Business Justification',
              '₦120,000/year is less than one tax consultant visit, making it easy to justify ROI',
            ),
            _buildBulletPoint(
              '📱 Mobile Money',
              'Works with Paystack (bank transfer, USSD, cards, mobile money) - covers all Nigerian payment preferences',
            ),
            _buildBulletPoint(
              '🎯 Try Before Buy',
              'Free tier builds trust in a market where financial apps need credibility',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayPerCalculatorModel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.teal[700]),
                const SizedBox(width: 8),
                const Text(
                  'Alternative: Pay-Per-Calculator Model',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'One-time purchase per calculator (lifetime access)',
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // Individual Calculators
            _buildCalculatorPrice('VAT Calculator', '₦2,000',
                'Most popular - includes refund tools package worth ₦8,000 extra'),
            _buildCalculatorPrice(
                'PIT Calculator', '₦1,500', 'For individuals and freelancers'),
            _buildCalculatorPrice(
                'CIT Calculator', '₦2,500', 'For businesses and corporations'),
            _buildCalculatorPrice(
                'WHT Calculator', '₦1,500', 'For withholding tax compliance'),
            _buildCalculatorPrice(
                'Payroll/PAYE Calculator', '₦2,000', 'For salary calculations'),
            _buildCalculatorPrice(
                'Stamp Duty Calculator', '₦1,000', 'For document stamping'),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Bundles
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bundle Packages (Save up to 40%)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBundleItem(
                      'Basic Bundle', '₦4,000', 'VAT + PIT (Save ₦1,500)'),
                  _buildBundleItem('Business Bundle', '₦7,000',
                      'VAT + CIT + WHT + Payroll (Save ₦3,000)'),
                  _buildBundleItem('All Calculators', '₦10,000',
                      'Complete access (Save ₦5,500) - Best Value!'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pros & Cons
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.thumb_up,
                                size: 16, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              'PROS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildProConItem('Lower barrier to entry'),
                        _buildProConItem('Users pay only for what they need'),
                        _buildProConItem('No subscription fatigue'),
                        _buildProConItem('Clear value proposition'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.thumb_down,
                                size: 16, color: Colors.red[700]),
                            const SizedBox(width: 4),
                            Text(
                              'CONS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildProConItem('Lower lifetime value'),
                        _buildProConItem('One-time revenue only'),
                        _buildProConItem('No recurring income'),
                        _buildProConItem('Updates cost not covered'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Best Use: Great for launch to build user base quickly. Consider transitioning to subscription after 6-12 months for sustainability.',
                      style: TextStyle(fontSize: 13, color: Colors.amber[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorPrice(String name, String price, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleItem(String name, String price, String savings) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.local_offer, size: 16, color: Colors.teal[700]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$name: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '$price - ',
                    style: TextStyle(
                        color: Colors.teal[700], fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: savings),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProConItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeModel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.alt_route, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Alternative: Hybrid Model',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'If subscription resistance is high, consider:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildBulletPoint(
              '✓ Free calculators',
              'All basic calculators remain free forever',
            ),
            _buildBulletPoint(
              '₦10,000',
              'VAT Refund Package (one-time purchase)',
            ),
            _buildBulletPoint(
              '₦2,000/month',
              'Unlimited History feature',
            ),
            _buildBulletPoint(
              '₦500 per document',
              'PDF Export pay-as-you-go',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber,
                      size: 20, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: This model has lower lifetime value but may ease initial adoption',
                      style: TextStyle(fontSize: 13, color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImplementationNotes() {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.construction, color: Colors.amber[900]),
                const SizedBox(width: 8),
                const Text(
                  'Implementation Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimelineItem('Phase 1 (Month 1)',
                'Launch with Free tier only - build user base'),
            _buildTimelineItem('Phase 2 (Month 2-3)',
                'Introduce Individual plan - convert power users'),
            _buildTimelineItem(
                'Phase 3 (Month 4-6)', 'Add Business plan - target SMEs'),
            _buildTimelineItem(
                'Phase 4 (Month 7+)', 'Enterprise plan for corporations'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recommendation: Start with Freemium + Tiered model. It\'s proven in Nigeria (like Paystack, Flutterwave did), gives users flexibility, and scales as businesses grow.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String phase, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.amber[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$phase: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
