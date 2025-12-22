import 'package:flutter/material.dart';
import 'package:taxng_advisor/models/pricing_tier.dart';
import 'package:taxng_advisor/services/pricing_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Pricing and subscription tiers screen
class PricingScreen extends StatefulWidget {
  const PricingScreen({Key? key}) : super(key: key);

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  List<PricingTier> _tiers = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService.currentUser();
    setState(() {
      _tiers = PricingService.getTiers();
      _isAdmin = user?.isAdmin ?? false;
    });
  }

  Color _getTierColor(int index) {
    const colors = [Colors.grey, Colors.blue, Colors.deepPurple, Colors.orange];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing & Plans'),
        backgroundColor: Colors.green[700],
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Pricing',
              onPressed: () async {
                await Navigator.pushNamed(context, '/help/admin/pricing');
                _loadData(); // Reload after editing
              },
            ),
        ],
      ),
      body: _tiers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  ..._tiers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tier = entry.value;
                    return Column(
                      children: [
                        _buildPricingTier(
                          tier.name,
                          tier.price,
                          tier.period,
                          _getTierColor(index),
                          tier.features,
                          isPopular: tier.isPopular,
                        ),
                        if (index < _tiers.length - 1)
                          const SizedBox(height: 16),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
            _buildTransactionalAddOns(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildFeatureComparison(),
            const SizedBox(height: 24),
            _buildCTA(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Simplified tax calculations, reminders, and receipts tailored for Nigerian businesses and individuals.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingTier(
    String name,
    String price,
    String period,
    Color color,
    List<String> features, {
    bool isPopular = false,
  }) {
    return Card(
      elevation: isPopular ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPopular ? color : Colors.transparent,
          width: isPopular ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (isPopular)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: color,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
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

  Widget _buildTransactionalAddOns() {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle_outline, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Transactional Add-ons',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBulletPoint('Payment confirmation: ₦50-200 per transaction'),
            _buildBulletPoint(
                'Filing submission: Small percentage fee for managed filings'),
            _buildBulletPoint('Custom integrations: Contact sales for pricing'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Payment Methods',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'We support the following payment gateways:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Remita'),
            _buildBulletPoint('Flutterwave'),
            _buildBulletPoint('Paystack'),
            const SizedBox(height: 8),
            Text(
              'Payment links can be generated from the app (Pro tier and above).',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feature Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildComparisonRow('Tax Calculators', ['✓', '✓', '✓', '✓']),
            _buildComparisonRow('Reminders', ['3', '10', '∞', '∞']),
            _buildComparisonRow('CSV Export', ['-', '✓', '✓', '✓']),
            _buildComparisonRow(
                'PDF Reports', ['-', 'Watermarked', 'Official', 'Official']),
            _buildComparisonRow('Payment Links', ['-', '-', '✓', '✓']),
            _buildComparisonRow('Multi-user', ['-', '-', '✓', '✓']),
            _buildComparisonRow('Team Roles', ['-', '-', '-', '✓']),
            _buildComparisonRow('API Access', ['-', '-', '-', '✓']),
            _buildComparisonRow('White-labeling', ['-', '-', '-', '✓']),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Free',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('Basic',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('Pro',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('Business',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String feature, List<String> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          ...values.map((value) {
            return Expanded(
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        value == '✓' ? FontWeight.bold : FontWeight.normal,
                    color: value == '✓' ? Colors.green : Colors.grey[700],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Card(
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Ready to simplify your tax compliance?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Start with the free plan or upgrade to Pro for advanced features.',
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/help/contact');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Upgrade Now'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/help/contact');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Contact Sales'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
