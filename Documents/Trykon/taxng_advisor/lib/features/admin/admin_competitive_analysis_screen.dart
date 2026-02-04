import 'package:flutter/material.dart';

class AdminCompetitiveAnalysisScreen extends StatelessWidget {
  const AdminCompetitiveAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Competitive Analysis'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildCompetitorComparison(),
          const SizedBox(height: 24),
          _buildCompetitiveAdvantages(),
          const SizedBox(height: 24),
          _buildFeatureMatrix(),
          const SizedBox(height: 24),
          _buildImprovementSuggestions(),
          const SizedBox(height: 24),
          _buildMonetizationStrategy(),
          const SizedBox(height: 24),
          _buildActionPlan(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TaxNG Advisor vs Nigerian Tax Apps',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Comprehensive Market Analysis',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.compare, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Competitor Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCompetitorCard(
              'Taxizi',
              'Basic PIT/PAYE calculator',
              [
                'PAYE calculations only',
                'Simple UI',
                'No history',
                'Free with ads'
              ],
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildCompetitorCard(
              'Taxmateng',
              'Nigerian tax calculator',
              [
                'PIT calculator',
                'Basic features',
                'Limited validation',
                'Free'
              ],
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildCompetitorCard(
              'Generic Tax Calculators',
              'Web-based calculators',
              [
                '1-2 calculators',
                'No data persistence',
                'Outdated rates',
                'Session-based'
              ],
              Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitorCard(
      String name, String description, List<String> features, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(f, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCompetitiveAdvantages() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Our Competitive Advantages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAdvantageItem('Comprehensiveness',
                '6 calculators vs 1-2 in competitors', Icons.dashboard),
            _buildAdvantageItem(
                'Compliance',
                'Tax Act 2025 updated (competitors outdated)',
                Icons.verified_user),
            _buildAdvantageItem('Professional Features',
                'Templates, bulk ops, export (unique)', Icons.business_center),
            _buildAdvantageItem('Data Management',
                'History, search, filtering (none have this)', Icons.storage),
            _buildAdvantageItem(
                'Quality Assurance',
                '215+ tests, 82% coverage (production-grade)',
                Icons.check_circle),
            _buildAdvantageItem('Business Tools',
                'Payment tracking, subscriptions (exclusive)', Icons.payment),
            _buildAdvantageItem('Productivity',
                'Shortcuts, favorites, notes, reminders', Icons.speed),
            _buildAdvantageItem('Technical Excellence',
                'Offline-first, encrypted, error recovery', Icons.security),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvantageItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureMatrix() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.table_chart, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Feature Comparison',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                      label: Text('Feature',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('TaxNG',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Taxizi',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Others',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  _buildFeatureRow('CIT Calculator', true, false, false),
                  _buildFeatureRow('PIT Calculator', true, true, true),
                  _buildFeatureRow('VAT Calculator', true, false, false),
                  _buildFeatureRow('WHT Calculator', true, false, false),
                  _buildFeatureRow('Payroll/PAYE', true, true, true),
                  _buildFeatureRow('Stamp Duty', true, false, false),
                  _buildFeatureRow('History', true, false, false),
                  _buildFeatureRow('Templates', true, false, false),
                  _buildFeatureRow('Bulk Operations', true, false, false),
                  _buildFeatureRow('Import/Export', true, false, false),
                  _buildFeatureRow('Payment Tracking', true, false, false),
                  _buildFeatureRow(
                      'Accountant Collaboration', true, false, false),
                  _buildFeatureRow('Multi-User Access', true, false, false),
                  _buildFeatureRow('Tax Act 2025', true, false, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildFeatureRow(String feature, bool us, bool taxizi, bool others) {
    return DataRow(cells: [
      DataCell(Text(feature)),
      DataCell(Icon(us ? Icons.check_circle : Icons.cancel,
          color: us ? Colors.green : Colors.red, size: 20)),
      DataCell(Icon(taxizi ? Icons.check_circle : Icons.cancel,
          color: taxizi ? Colors.green : Colors.red, size: 20)),
      DataCell(Icon(others ? Icons.check_circle : Icons.cancel,
          color: others ? Colors.green : Colors.red, size: 20)),
    ]);
  }

  Widget _buildImprovementSuggestions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Improvement Suggestions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSuggestionCategory(
                'High Priority - Quick Wins',
                [
                  'Tax Planning Module (scenario comparison)',
                  'Compliance Calendar (interactive deadlines)',
                  'Enhanced Reporting (tax-ready exports)',
                  'Educational Content (guides & tutorials)',
                  'Client Management (multi-client for practitioners)',
                ],
                Colors.red),
            const SizedBox(height: 12),
            _buildSuggestionCategory(
                'Medium Priority - Competitive Edge',
                [
                  'Smart Features (auto-suggestions)',
                  'Enhanced Collaboration (team roles, audit logs)',
                  'Integration Capabilities (QuickBooks, Xero)',
                  'Advanced Analytics (tax burden analysis)',
                  'Compliance Checker (audit risk assessment)',
                ],
                Colors.orange),
            const SizedBox(height: 12),
            _buildSuggestionCategory(
                'Lower Priority - Future Differentiation',
                [
                  'AI-Powered Features (chatbot, OCR)',
                  'Cloud Sync (cross-device)',
                  'Professional Services Marketplace',
                  'Multi-language Support',
                  'Advanced Forecasting',
                ],
                Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCategory(
      String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildMonetizationStrategy() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Monetization Strategy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPricingTier(
              'Free',
              '₦0/month',
              [
                'PIT calculator only',
                'Limited history (10 records)',
                'Basic features'
              ],
              Colors.grey,
            ),
            const SizedBox(height: 8),
            _buildPricingTier(
              'Basic',
              '₦2,500/month',
              [
                'All 6 calculators',
                'Unlimited history',
                'Templates & favorites',
                'Export to CSV'
              ],
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildPricingTier(
              'Pro',
              '₦5,000/month',
              [
                'Everything in Basic',
                'Bulk operations',
                'Client management',
                'Advanced analytics',
                'Priority support'
              ],
              Colors.purple,
            ),
            const SizedBox(height: 8),
            _buildPricingTier(
              'Enterprise',
              '₦15,000/month',
              [
                'Everything in Pro',
                'Multi-user (5 seats)',
                'Team collaboration',
                'Custom integrations',
                'Dedicated support'
              ],
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTier(
      String name, String price, List<String> features, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(f, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionPlan() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Phase 4 Action Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPhaseCard(
                'Month 1-2: Quick Wins',
                [
                  'Add tax planning scenarios',
                  'Enhance dashboard with shortcuts',
                  'Create comparison marketing page',
                  'Add simplified mode toggle',
                ],
                Colors.green),
            const SizedBox(height: 12),
            _buildPhaseCard(
                'Month 3-4: Competitive Edge',
                [
                  'Implement client management',
                  'Build compliance calendar',
                  'Add educational content',
                  'Create video tutorials',
                ],
                Colors.blue),
            const SizedBox(height: 12),
            _buildPhaseCard(
                'Month 5-6: Market Leadership',
                [
                  'Smart suggestions engine',
                  'Industry benchmarking',
                  'Practitioner marketplace',
                  'Launch certification program',
                ],
                Colors.purple),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Current Status: Production-ready for launch. Phase 4 features to be implemented post-launch based on user feedback.',
                      style: TextStyle(fontSize: 13),
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

  Widget _buildPhaseCard(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
