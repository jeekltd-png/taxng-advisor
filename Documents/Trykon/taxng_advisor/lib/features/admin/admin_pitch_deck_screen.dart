import 'package:flutter/material.dart';

/// Admin screen with comprehensive pitch deck and presentation guide for TaxPadi
class AdminPitchDeckScreen extends StatelessWidget {
  const AdminPitchDeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pitch Deck & Sales Presentation'),
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
                colors: [Colors.indigo, Colors.blue[300]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.slideshow, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '🎯 TaxPadi Pitch Deck',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Complete presentation guide for pitching to individuals, SMEs, and investors',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Presentation Overview
          _buildOverviewCard(),
          const SizedBox(height: 24),

          // Core Slides Section
          _buildSectionHeader(
              'Core Presentation Structure', '20 Essential Slides'),
          const SizedBox(height: 12),
          _buildSlideCard(
              '1. Title Slide',
              'TaxPadi - Your Smart Tax Compliance Partner',
              'Logo + tagline "Calculate. File. Relax." | Include: Name, Contact, Date'),
          _buildSlideCard(
              '2. The Problem',
              'Managing Nigerian Taxes is Overwhelming',
              'Pain points: Complex calculations, missed deadlines, penalties, lost records | Key stat: 68% of Nigerian SMEs received FIRS penalties'),
          _buildSlideCard('3. The Solution', 'One App for All Your Tax Needs',
              '5 value props: Accurate calculations, Never miss deadlines, Secure storage, Save money, FIRS-ready reports | Tagline: "From calculation to filing in 3 taps"'),
          _buildSlideCard('4. How It Works', '3-Step User Journey',
              'Step 1: Calculate (5 mins) | Step 2: Save & Track | Step 3: File with Confidence | Time savings: 2 hours → 5 minutes'),
          _buildSlideCard(
              '5. Key Features - Calculators',
              '6 Essential Tax Types',
              'VAT, CIT, PIT, WHT, Payroll, Stamp Duty | Each with: Real-time validation, Help tooltips, Templates, Example data'),
          _buildSlideCard(
              '6. Key Features - Management',
              'Smart Tax Management',
              'Tax Overview Dashboard (charts) | Calculation History (search/filter) | Tax Reminders (red badges) | Templates (one-tap recall)'),
          _buildSlideCard('7. Data Import/Export', 'Seamless Data Flow',
              'Import: CSV/Excel, JSON, Copy-Paste | Export: PDF (FIRS format), Excel, CSV, Share | Use case: Import 50 payroll records in 30 seconds'),
          _buildSlideCard('8. Security & Privacy', 'Your Data is Safe',
              'AES-256 encryption | Local-first storage | Password protection | NDPR compliant | Privacy promise: "Your tax data belongs to you"'),
          _buildSlideCard('9. Pricing Plans', 'Plans for Everyone',
              'Free: All calculators, 3 reminders | Basic (₦500/mo): 10 reminders, CSV export | Pro (₦2,000/mo): Unlimited, official PDFs | ROI: Save ₦50K/year on accountants'),
          _buildSlideCard('10. Target Users', 'Who Benefits?',
              'Individuals: Employees, Freelancers, Landlords | SMEs: Retail, Contractors, Manufacturers | Professionals: Accountants (50+ clients), Bookkeepers'),

          const SizedBox(height: 24),
          _buildSectionHeader('Supporting Slides', 'Additional Content'),
          const SizedBox(height: 12),
          _buildSlideCard('11. Success Stories', '3 Case Studies',
              'Sarah\'s Boutique: Saved ₦200K/year | Chukwu Consulting: 70% time reduction | Adeola Freelancer: Avoided ₦50K penalty'),
          _buildSlideCard('12. Competitive Advantage', 'Why TaxPadi Wins',
              'vs Spreadsheets: Accuracy + Speed | vs Accountants: 24/7 availability + Cost | Key: "Accountant knowledge at calculator speed"'),
          _buildSlideCard('13. Live Demo', '5-Minute Walkthrough',
              '1. Calculate VAT (2 min) | 2. View Dashboard (1 min) | 3. Set Reminder (1 min) | 4. Export Report (1 min) | Talk: "Notice how fast?"'),
          _buildSlideCard('14. Market Opportunity', 'Huge Potential',
              '40M+ SMEs in Nigeria | 35% file correctly (65% gap) | TAM: ₦48B/year (20% penetration) | Current: 500+ users, 4.8★ rating'),
          _buildSlideCard('15. Roadmap', 'Coming Soon',
              'Q1: Mobile apps, WhatsApp alerts | Q2: Bank integration, E-filing | Q3: AI advisor, Team collaboration | Vision: #1 by 2027'),
          _buildSlideCard('16. Why Now?', 'Perfect Timing',
              'FIRS going digital | +40% audit rate | 80% SMEs use smartphones | Finance Act 2024 confusion | Government 10% rebate for digital filing'),
          _buildSlideCard('17. CTA - Individuals', 'Start Your Journey',
              'Free forever core features | First month free trial | Money-back guarantee | Bonus: Tax guide eBook + video tutorials | QR code to download'),
          _buildSlideCard('18. CTA - SMEs', 'Take Control',
              'Pro: 50% OFF first 3 months | Free onboarding call | Migration assistance | Accountants: Business tier + ₦200/referral'),
          _buildSlideCard('19. FAQs', 'Address Concerns',
              'Data safety? AES-256 + local | Rate changes? Auto-update 24hrs | Accountant compatible? Yes, export/collaborate | Offline? Yes!'),
          _buildSlideCard('20. Thank You', 'Contact & Next Steps',
              'Web: taxpadi.ng | Phone: 0800-TAX-PADI | Email: hello@taxpadi.ng | Social: @TaxPadi | Leave 5 min for Q&A'),

          const SizedBox(height: 24),

          // Key Talking Points
          _buildTalkingPointsCard(),
          const SizedBox(height: 24),

          // Delivery Strategy
          _buildDeliveryStrategyCard(),
          const SizedBox(height: 24),

          // Audience-Specific Tips
          _buildAudienceGuideCard(),
          const SizedBox(height: 24),

          // Demo Tips
          _buildDemoTipsCard(),
          const SizedBox(height: 24),

          // Supporting Materials
          _buildSupportingMaterialsCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Presentation Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Duration', '15-20 minutes (20 slides)'),
            _buildInfoRow('Demo Time', '5 minutes live walkthrough'),
            _buildInfoRow('Q&A', '5 minutes at end'),
            _buildInfoRow('Format', 'PowerPoint/Google Slides + Live Demo'),
            const Divider(height: 24),
            const Text(
              'Key Message:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '"TaxPadi transforms tax compliance from a stressful, error-prone process into a simple 5-minute task, saving Nigerian businesses thousands in penalties and accountant fees."',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.slideshow, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildSlideCard(String slideNumber, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.preview, color: Colors.indigo[700]),
        ),
        title: Text(
          slideNumber,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Content:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTalkingPointsCard() {
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
                Icon(Icons.record_voice_over,
                    color: Colors.green[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Key Talking Points (Memorize)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTalkingPoint(
              'Elevator Pitch (30 sec)',
              '"TaxPadi is a mobile app that helps Nigerian individuals and businesses calculate, track, and file their taxes accurately. We\'ve simplified 6 complex tax types into a 5-minute process, helping users save thousands in penalties and accountant fees."',
            ),
            const Divider(height: 20),
            _buildTalkingPoint(
              'Value Proposition (1 min)',
              'Nigerian taxes are complex - 6 types, changing rates, strict deadlines. Most pay expensive accountants or risk costly mistakes. TaxPadi gives accountant-level accuracy at calculator speed, right on your phone.',
            ),
            const Divider(height: 20),
            _buildTalkingPoint(
              'Differentiation (30 sec)',
              'Unlike Excel or accounting software, TaxPadi is built specifically for Nigerian tax compliance. We update regulations automatically, provide step-by-step guidance, and format everything for FIRS submission.',
            ),
            const Divider(height: 20),
            _buildTalkingPoint(
              'Social Proof',
              '500+ Nigerian businesses trust TaxPadi. Users save an average of ₦120K/year in accountant fees and ₦50K/year in avoided penalties.',
            ),
            const Divider(height: 20),
            _buildTalkingPoint(
              'Urgency',
              'With FIRS increasing audit rates by 40% and new digital filing requirements in 2026, now is the time. Early adopters get 3 months free - ₦6,000 in savings.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryStrategyCard() {
    return Card(
      elevation: 4,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Delivery Strategy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStrategySection(
              'Opening (2 min)',
              [
                'Start with relatable pain: "Who here has paid a tax penalty?" (get hands up)',
                'Hook: "What if you\'ll never pay another penalty again?"',
                'Build rapport with the audience immediately',
              ],
            ),
            const Divider(height: 20),
            _buildStrategySection(
              'Body (10 min)',
              [
                'Focus on BENEFITS, not features',
                'Use real numbers (₦ savings, time saved)',
                'Tell stories (Sarah\'s boutique case study)',
                'Demo live - don\'t just show slides',
                'Engage audience with questions',
              ],
            ),
            const Divider(height: 20),
            _buildStrategySection(
              'Closing (3 min)',
              [
                'Recap 3 key benefits',
                'Clear call-to-action with urgency',
                'Make sign-up easy (QR code)',
                'Open for questions',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceGuideCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.purple[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Audience-Specific Adjustments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAudienceSection(
              'For Individuals',
              Colors.blue,
              [
                'Emphasize: Simplicity, free tier, avoiding penalties',
                'Show: PIT calculator demo',
                'Tone: Friendly, educational, reassuring',
                'Focus on personal tax stories',
              ],
            ),
            const SizedBox(height: 12),
            _buildAudienceSection(
              'For SME Owners',
              Colors.green,
              [
                'Emphasize: Time/money savings, accuracy, peace of mind',
                'Show: VAT + CIT calculators, multi-company',
                'Tone: Professional, ROI-focused',
                'Focus on business impact and compliance',
              ],
            ),
            const SizedBox(height: 12),
            _buildAudienceSection(
              'For Accountants',
              Colors.orange,
              [
                'Emphasize: Client management, white-label, efficiency',
                'Show: Bulk operations, client dashboard',
                'Tone: B2B partnership opportunity',
                'Focus on scalability and revenue sharing',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoTipsCard() {
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
                Icon(Icons.computer, color: Colors.purple[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Live Demo Tips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDemoStep(
              '1. Calculate VAT (2 min)',
              [
                'Open VAT calculator',
                'Point out help icons: "See these? Explain every field"',
                'Enter sample data (₦5M sales)',
                'Show instant calculation',
                'Explain output: "VAT payable, effective rate, ready to file"',
                'Save calculation',
              ],
            ),
            const Divider(height: 20),
            _buildDemoStep(
              '2. View Dashboard (1 min)',
              [
                'Show tax overview with charts',
                'Point out total taxes paid',
                'Show recent calculations list',
                'Emphasize: "All your tax history in one place"',
              ],
            ),
            const Divider(height: 20),
            _buildDemoStep(
              '3. Set Reminder (1 min)',
              [
                'Add custom VAT return deadline',
                'Show urgent reminder badge (red)',
                'Demonstrate notification',
                'Say: "Never miss another deadline"',
              ],
            ),
            const Divider(height: 20),
            _buildDemoStep(
              '4. Export Report (1 min)',
              [
                'Open calculation history',
                'Export to PDF',
                'Show professional FIRS format',
                'Say: "Ready to submit. No reformatting needed."',
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Pro Tips During Demo:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text('• "Notice how fast this is?"'),
                  const Text(
                      '• "See the error checking? Won\'t let you submit wrong data"'),
                  const Text('• "This PDF is ready to submit to FIRS"'),
                  const Text('• Have backup screenshots in case demo fails'),
                  const Text('• Use pre-populated test account'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportingMaterialsCard() {
    return Card(
      elevation: 4,
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_open, color: Colors.amber[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Supporting Materials',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMaterialItem('1. Leave-Behind Brochure',
                '1-page PDF with key benefits, pricing, QR code'),
            _buildMaterialItem('2. Demo Account',
                'Pre-populated with 3-4 complete calculations'),
            _buildMaterialItem('3. Video Demo',
                '2-minute silent demo for trade shows/website'),
            _buildMaterialItem('4. Proposal Template',
                'Customizable B2B pricing and implementation plan'),
            _buildMaterialItem('5. ROI Calculator',
                'Excel showing savings vs accountant fees'),
            _buildMaterialItem(
                '6. Business Cards', 'With QR code linking to app download'),
            _buildMaterialItem(
                '7. Sample Reports', 'Printed PDFs showing output quality'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 Device Recommendations:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text('• Laptop + projector - large audiences'),
                  Text('• iPad - 1-on-1 meetings (more intimate)'),
                  Text('• Phone mirroring - show mobile experience'),
                  Text('• Always have backup screenshots!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTalkingPoint(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStrategySection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                      child: Text(point, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAudienceSection(String title, Color color, List<String> points) {
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
              Icon(Icons.group, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 13, color: color)),
                    Expanded(
                        child:
                            Text(point, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDemoStep(String title, List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(step, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildMaterialItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description, size: 20, color: Colors.blue),
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
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
