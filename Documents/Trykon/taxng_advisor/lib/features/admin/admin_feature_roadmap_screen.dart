import 'package:flutter/material.dart';

/// Admin screen showing recommended feature roadmap and monetization strategy
class AdminFeatureRoadmapScreen extends StatelessWidget {
  const AdminFeatureRoadmapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Roadmap & Monetization'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple[300]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚀 TaxPadi Feature Roadmap',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'High-value features to increase user engagement, retention, and revenue',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Revenue Impact Summary
          _buildSummaryCard(),
          const SizedBox(height: 24),

          // Tier 1: Critical Revenue-Driving Features
          _buildTierSection(
            tier: 'Tier 1',
            title: 'Critical Revenue-Driving Features',
            subtitle: 'Highest ROI - Implement First',
            color: Colors.red,
            features: _tier1Features,
          ),
          const SizedBox(height: 24),

          // Tier 2: Strong Engagement Features
          _buildTierSection(
            tier: 'Tier 2',
            title: 'Strong Engagement Features',
            subtitle: 'Drive Daily Active Users',
            color: Colors.orange,
            features: _tier2Features,
          ),
          const SizedBox(height: 24),

          // Tier 3: Competitive Differentiators
          _buildTierSection(
            tier: 'Tier 3',
            title: 'Competitive Differentiators',
            subtitle: 'Build Competitive Moats',
            color: Colors.blue,
            features: _tier3Features,
          ),
          const SizedBox(height: 24),

          // Tier 4: Long-term Stickiness
          _buildTierSection(
            tier: 'Tier 4',
            title: 'Long-term Stickiness & Scale',
            subtitle: 'Enterprise & Platform Features',
            color: Colors.green,
            features: _tier4Features,
          ),
          const SizedBox(height: 24),

          // Implementation Priority
          _buildImplementationPriority(),
          const SizedBox(height: 24),

          // Key Metrics
          _buildKeyMetrics(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green[700], size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Revenue Impact Projection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
                'Multi-company fees', '₦5,000-10,000/accountant/month'),
            _buildMetricRow(
                'E-TCC transactions', '₦1.6M/year (1,000 users × 2 apps)'),
            _buildMetricRow(
                'Document storage upsells', '+₦450/user (30% conversion)'),
            _buildMetricRow(
                'API Access (20 businesses)', '₦300K/month = ₦3.6M/year'),
            _buildMetricRow('Employee Portal', '₦100K/month (50 companies)'),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Annual Increase:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₦15M - ₦30M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierSection({
    required String tier,
    required String title,
    required String subtitle,
    required Color color,
    required List<Map<String, String>> features,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                tier,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...features.map((feature) => _buildFeatureCard(feature, color)),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, String> feature, Color accentColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(
          _getFeatureIcon(feature['title']!),
          color: accentColor,
          size: 28,
        ),
        title: Text(
          feature['title']!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          feature['why']!,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature['description']!,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature['monetization']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImplementationPriority() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Implementation Priority',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPhaseCard(
              'Phase 1 - Q1 2026',
              'Highest ROI',
              Colors.red,
              [
                'Multi-Company Management',
                'Document Vault',
                'WhatsApp/Email Alerts',
                'Compliance Dashboard',
              ],
            ),
            const SizedBox(height: 12),
            _buildPhaseCard(
              'Phase 2 - Q2 2026',
              'Revenue Generators',
              Colors.orange,
              [
                'E-TCC Application',
                'Automated Tax Return Generation',
                'Tax Forecasting',
                'Accountant Collaboration',
              ],
            ),
            const SizedBox(height: 12),
            _buildPhaseCard(
              'Phase 3 - Q3 2026',
              'Competitive Moats',
              Colors.blue,
              [
                'FIRS Portal Integration',
                'Accounting Software Integration',
                'Tax Optimization Advisor',
                'Industry Benchmarking',
              ],
            ),
            const SizedBox(height: 12),
            _buildPhaseCard(
              'Phase 4 - Q4 2026',
              'Scale & Enterprise',
              Colors.green,
              [
                'API Access',
                'White-Label',
                'Employee Portal',
                'Tax Training & Certification',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard(
      String phase, String label, Color color, List<String> features) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                phase,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Card(
      elevation: 4,
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Key Success Metrics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              'Retention Rate',
              '85%+',
              'Multi-company + Document Vault',
              Icons.people_alt,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildMetricCard(
              'Upgrade Rate',
              '25%+',
              'Free-to-Pro conversion',
              Icons.trending_up,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildMetricCard(
              'Transaction Revenue',
              '₦2M+/year',
              'E-TCC + Tax Returns',
              Icons.receipt_long,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildMetricCard(
              'Viral Coefficient',
              '1.3+',
              'Each user invites 1.3 others',
              Icons.share,
              Colors.purple,
            ),
            const SizedBox(height: 8),
            _buildMetricCard(
              'Churn Reduction',
              '<5%/month',
              'WhatsApp alerts + Auto-filing',
              Icons.lock,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String target,
    String driver,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  driver,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            target,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String title) {
    if (title.contains('Portal Integration')) return Icons.cloud_sync;
    if (title.contains('Multi-Company')) return Icons.business;
    if (title.contains('E-TCC')) return Icons.verified;
    if (title.contains('Compliance')) return Icons.dashboard;
    if (title.contains('Tax Return')) return Icons.description;
    if (title.contains('Document')) return Icons.folder;
    if (title.contains('Forecasting')) return Icons.show_chart;
    if (title.contains('Collaboration')) return Icons.people;
    if (title.contains('WhatsApp')) return Icons.notifications;
    if (title.contains('Optimization')) return Icons.lightbulb;
    if (title.contains('Integration')) return Icons.link;
    if (title.contains('Benchmarking')) return Icons.compare;
    if (title.contains('Penalty')) return Icons.warning;
    if (title.contains('Payment')) return Icons.payment;
    if (title.contains('News')) return Icons.newspaper;
    if (title.contains('Employee')) return Icons.badge;
    if (title.contains('Audit')) return Icons.search;
    if (title.contains('API')) return Icons.code;
    if (title.contains('White-Label')) return Icons.branding_watermark;
    if (title.contains('Training')) return Icons.school;
    return Icons.star;
  }

  // Feature data
  static final List<Map<String, String>> _tier1Features = [
    {
      'title': '1. Direct FIRS Portal Integration',
      'why': 'Eliminates manual form filling - biggest pain point',
      'description':
          '• Auto-populate FIRS tax returns from calculations\n• One-click submission to FIRS portal\n• Track submission status in real-time\n• Download filed returns automatically\n• Integration with TaxPro-Max API',
      'monetization': 'Pro tier feature (₦2,000/mo justified by time savings)',
    },
    {
      'title': '2. Multi-Company/Client Management',
      'why': 'Accountants manage 10-50+ clients',
      'description':
          '• Switch between companies with one tap\n• Separate calculation histories per company\n• Bulk operations across all clients\n• Client dashboard showing all tax obligations\n• Company-specific settings and branding',
      'monetization':
          'Business tier (₦8,000+), charge ₦1,000 per additional company',
    },
    {
      'title': '3. E-TCC Application & Tracking',
      'why': 'TCC is mandatory for contracts/tenders',
      'description':
          '• Direct TCC application through app\n• Upload supporting documents (tax clearance, receipts)\n• Track TCC application status\n• Reminder 30 days before TCC expiry\n• Store digital TCC certificates in vault',
      'monetization': 'Transaction fee: ₦500-1,000 per TCC application',
    },
    {
      'title': '4. Tax Compliance Dashboard',
      'why': 'Visual compliance status = peace of mind',
      'description':
          '• Traffic light system (Red/Yellow/Green)\n• Outstanding obligations highlighted\n• Compliance score (0-100%)\n• Next action items prioritized\n• Historical compliance trends\n• Export compliance report',
      'monetization': 'Pro tier exclusive feature',
    },
    {
      'title': '5. Automated Tax Return Generation',
      'why': 'Saves hours of manual form filling',
      'description':
          '• Auto-generate PDF in official FIRS format\n• Pre-filled forms ready for submission\n• Support all major tax forms (CIT01, VAT01, WHT01, etc.)\n• Digital signature integration\n• Audit trail for all generated returns',
      'monetization': 'Pro tier + ₦200 per generated return',
    },
  ];

  static final List<Map<String, String>> _tier2Features = [
    {
      'title': '6. Document Vault',
      'why': 'Secure storage = audit-ready business',
      'description':
          '• Store receipts, invoices, tax returns\n• OCR scan receipts automatically\n• Tag documents to specific calculations\n• Share documents with accountant\n• Cloud backup with AES-256 encryption\n• Search by date, amount, or keywords',
      'monetization':
          'Storage limits: 1GB free, 10GB Basic, unlimited Pro/Business',
    },
    {
      'title': '7. Tax Forecasting & Cash Flow Planning',
      'why': 'Plan ahead = avoid cash crunches',
      'description':
          '• Predict next quarter\'s tax obligations\n• "What-if" scenario analysis\n• Cash flow impact visualization\n• Seasonal business patterns\n• Export forecasts to Excel',
      'monetization': 'Pro tier feature',
    },
    {
      'title': '8. Accountant Collaboration Portal',
      'why': 'Seamless client-accountant workflow',
      'description':
          '• Invite accountant with view/edit permissions\n• Accountant can review calculations before filing\n• Comment threads on specific calculations\n• Approval workflow before submission\n• Activity log for accountability',
      'monetization': 'Pro tier + ₦500/additional user',
    },
    {
      'title': '9. WhatsApp & Email Tax Alerts',
      'why': 'Never miss deadlines',
      'description':
          '• WhatsApp reminders 7/3/1 days before deadline\n• Email summaries of pending obligations\n• Customizable reminder schedules\n• One-tap action from WhatsApp\n• Delivery status tracking',
      'monetization': 'Basic tier feature (engagement driver)',
    },
    {
      'title': '10. Tax Optimization Advisor',
      'why': 'Legal tax savings >> subscription cost',
      'description':
          '• AI-powered analysis of calculations\n• Identify missed deductions\n• Suggest timing strategies (e.g., advance payments)\n• Compare estimated tax across different structures\n• Industry-specific tax-saving tips',
      'monetization': 'Pro tier (AI-powered = premium value)',
    },
  ];

  static final List<Map<String, String>> _tier3Features = [
    {
      'title': '11. Accounting Software Integration',
      'why': 'Eliminate double data entry',
      'description':
          '• QuickBooks, Sage, Zoho Books integration\n• Auto-import revenue/expense data\n• Two-way sync of tax calculations\n• Match transactions to tax categories\n• Export to accounting software',
      'monetization': 'Business tier + one-time ₦5,000 integration fee',
    },
    {
      'title': '12. Industry Benchmarking',
      'why': 'Know if you\'re paying too much tax',
      'description':
          '• Compare tax rates with industry averages\n• Effective tax rate comparison\n• Identify unusual patterns\n• Anonymous aggregated data\n• Peer comparison reports',
      'monetization': 'Pro tier feature',
    },
    {
      'title': '13. Penalty & Interest Calculator',
      'why': 'Avoid surprises from FIRS',
      'description':
          '• Calculate penalties for late payment\n• Interest on overdue taxes\n• Grace period tracking\n• Settlement amount projections\n• Payment plan recommendations',
      'monetization': 'Free (drives upgrade to avoid penalties)',
    },
    {
      'title': '14. Payment Scheduling & Automation',
      'why': 'Set it and forget it',
      'description':
          '• Recurring payment setup\n• Direct debit integration with banks\n• Payment reminders before auto-debit\n• Payment history tracking\n• Failed payment retry logic',
      'monetization': 'Pro tier + payment gateway integration',
    },
    {
      'title': '15. Tax News & Regulatory Updates',
      'why': 'Stay compliant with changing laws',
      'description':
          '• FIRS circulars delivered in-app\n• Plain-language explanations of tax law changes\n• Impact analysis ("How this affects you")\n• Push notifications for critical updates\n• Archived updates library',
      'monetization': 'Free (engagement + authority building)',
    },
  ];

  static final List<Map<String, String>> _tier4Features = [
    {
      'title': '16. Employee Self-Service Portal',
      'why': 'Reduce payroll admin time',
      'description':
          '• Employees view their payslips\n• Download tax certificates (annual PAYE)\n• Submit expense claims\n• Request tax deduction adjustments\n• YTD tax summary',
      'monetization': 'Business tier: ₦200/employee/month',
    },
    {
      'title': '17. Audit Trail & Compliance Reports',
      'why': 'Pass FIRS audits easily',
      'description':
          '• Complete audit history of all calculations\n• Who changed what, when\n• Export audit-ready reports\n• Compliance certificates\n• Tamper-proof logging',
      'monetization': 'Business tier (audit protection = premium)',
    },
    {
      'title': '18. API Access for Developers',
      'why': 'Build custom integrations',
      'description':
          '• REST API for all calculators\n• Webhook notifications\n• Bulk calculation endpoints\n• API rate limits by tier\n• Developer documentation',
      'monetization': 'Business tier: ₦15,000+/month',
    },
    {
      'title': '19. White-Label for Accounting Firms',
      'why': 'Brand it as their own tool',
      'description':
          '• Custom branding (logo, colors)\n• Custom domain (tax.accountingfirm.com)\n• Resell to their clients\n• White-label mobile apps\n• Revenue sharing model',
      'monetization': 'Enterprise tier: ₦50,000+/month',
    },
    {
      'title': '20. Tax Training & Certification',
      'why': 'Professional development',
      'description':
          '• Video courses on Nigerian tax laws\n• CPE credits for accountants (ICAN/ANAN)\n• Certification upon completion\n• Interactive quizzes\n• Certificates of completion',
      'monetization': 'Per-course pricing: ₦10,000-25,000',
    },
  ];
}
