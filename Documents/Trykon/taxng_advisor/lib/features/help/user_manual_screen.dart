import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/models/user.dart';

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({Key? key}) : super(key: key);

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  UserProfile? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.currentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  bool get _isPaidUser {
    return _currentUser?.isPro ?? false;
  }

  final List<ManualSection> _sections = [
    ManualSection(
      title: '1. Getting Started',
      icon: Icons.play_circle,
      content: '''
Welcome to TaxPadi! This comprehensive guide will help you master all features.

**First-Time Setup**
1. Launch TaxPadi
2. Sign up with email or phone number
3. Complete profile setup (Name, TIN, Business details)
4. Choose your subscription tier (Free, Pro, or Business)
5. Start calculating taxes

**Quick Tour**
- Dashboard: Your tax overview and quick actions
- Calculators: CIT, VAT, PIT, WHT, Stamp Duty, Vehicle License
- History: View all past calculations
- Templates: Save & reuse common calculations
- Profile: Manage account and settings
''',
    ),
    ManualSection(
      title: '2. Dashboard Overview',
      icon: Icons.dashboard,
      content: '''
**Main Features**
- Recent Calculations: Quick access to your last 5 calculations
- Quick Actions: Jump to any calculator instantly
- Subscription Status: View your current plan and benefits
- Navigation: Access all features from the bottom navigation bar

**Navigation Bar**
- Dashboard: Home screen
- History: View all calculations
- Templates: Saved calculation templates
- Help: Access this manual and support
- Profile: Account settings and preferences
''',
    ),
    ManualSection(
      title: '3. Tax Calculators',
      icon: Icons.calculate,
      content: '''
**Available Calculators**
1. Corporate Income Tax (CIT)
2. Value Added Tax (VAT)
3. Personal Income Tax (PIT)
4. Withholding Tax (WHT)
5. Stamp Duty
6. Vehicle License

**Basic Usage**
1. Select calculator from Dashboard
2. Enter required details (amounts, dates, etc.)
3. Tap "Calculate" to see results
4. Review Tax Calculation Details
5. Add evidence (notes/attachments)
6. Record payment or generate payment link

**Calculator Features**
- Real-time validation
- Instant calculations
- Clear breakdown of tax computation
- Export to PDF
- Save as template
- Share results
''',
    ),
    ManualSection(
      title: '4. Evidence Management',
      icon: Icons.description,
      content: '''
**Adding Evidence to Calculations**

Every calculation includes an Evidence section where you can:

**Notes**
- Add text explanations
- Document special circumstances
- Reference supporting details
- Provide context for calculations

**Attachments**
- Upload supporting documents
- Attach receipts, invoices, forms
- Include proof of payment
- Store related files

**Benefits**
- Complete audit trail
- Professional documentation
- Easy reference during audits
- Compliance support
- Record keeping

**How to Add Evidence**
1. Complete your tax calculation
2. Scroll to "Tax Calculation Details" card
3. Enter notes in the Notes field
4. Tap "Add Attachments" to upload files
5. Evidence is saved with your calculation
6. Appears on PDF exports and payment records
''',
    ),
    ManualSection(
      title: '5. Templates',
      icon: Icons.bookmark,
      content: '''
**Save Time with Templates**

Templates let you save calculations for reuse.

**Creating Templates**
1. Complete any calculation
2. Tap "Save as Template"
3. Give it a memorable name
4. Template is saved for future use

**Using Templates**
1. Go to Templates screen
2. Browse your saved templates
3. Tap on any template
4. Calculator opens with pre-filled data
5. Modify as needed and calculate

**Template Features**
- Automatic 10-second save confirmation
- "View" button to instantly access saved template
- Edit or delete existing templates
- Works with all calculator types
- Includes all calculation details

**Best Use Cases**
- Recurring monthly tax calculations
- Standard business scenarios
- Common client situations (for accountants)
- Regular payroll calculations
''',
    ),
    ManualSection(
      title: '6. Payment Options',
      icon: Icons.payment,
      content: '''
**Two Ways to Handle Payments**

**Option 1: Record Payment**
- For payments made outside the app
- Creates PDF receipt with payment details
- Includes Tax Calculation Details
- Contains QR code for verification
- Stores payment record in history

**Option 2: Pay Now**
- Integrated payment gateway
- Pay directly through the app
- Automatic payment confirmation
- Instant receipt generation
- Real-time payment tracking

**Payment Receipt Features**
- Professional PDF format
- TaxPadi branding with green border
- Complete tax calculation breakdown
- Evidence (notes & attachments)
- QR code with verification data:
  - Username/Business name
  - Calculator type
  - Date and time stamp
  - Payment details

**Sharing Receipts**
- Email PDF attachments
- Share via messaging apps
- Save to device
- Print directly
- Archive for records
''',
    ),
    ManualSection(
      title: '7. Import & Export',
      icon: Icons.import_export,
      content: '''
**Import Data**

Import data from JSON or CSV files to quickly populate calculators.

**JSON Import**
1. Go to Profile > Import Data
2. Paste JSON or select file
3. Format: {"type": "CIT", "year": 2024, "data": {...}}
4. App auto-fills calculator

**CSV Import**
1. Go to Profile > Import Data
2. Paste CSV or select file
3. First row must have headers
4. Example headers: type, year, turnover, expenses, profit, businessName, tin

**CSV Format by Tax Type**

**CIT**: type, year, turnover, expenses, profit, businessName, tin
**VAT**: type, year, period, totalSales, taxableSales, exemptSales, inputTax, outputTax, vat
**PIT**: type, year, employeeId, employeeName, grossIncome, taxableIncome, personalRelief, standardRelief, pit

**Excel Files**
1. Create data in Excel
2. Save As > CSV format
3. Import CSV into TaxPadi
4. Or copy-paste directly from Excel

**Export Features**
- PDF Export: Professional tax reports
- CSV Export: Bulk data export (Pro/Business)
- Email Sharing: Send PDFs directly
- Cloud Backup: Secure encrypted storage
''',
    ),
    ManualSection(
      title: '8. Profile & Settings',
      icon: Icons.settings,
      content: '''
**Profile Management**

**Personal Information**
- Name and contact details
- TIN (Tax Identification Number)
- Business information
- Email verification
- Phone number

**Subscription Management**
- View current plan
- Upgrade/downgrade tiers
- View benefits
- Manage billing
- Cancel subscription

**Team Management (Pro/Business)**
- Invite accountants/team members
- Assign roles (Viewer, Editor, Admin)
- Manage permissions
- View team activity (Business tier)
- Audit logs

**Settings**
- Language preferences
- Currency settings
- Notification preferences
- Cloud backup enable/disable
- Privacy settings
- Dark mode (if available)

**Data Management**
- Import data
- Export calculations
- Backup & restore
- Clear cache
- Delete account
''',
    ),
    ManualSection(
      title: '9. Tips & Best Practices',
      icon: Icons.tips_and_updates,
      content: '''
**Maximize Your TaxPadi Experience**

**Accuracy Tips**
✓ Double-check all amounts before calculating
✓ Use templates for recurring calculations
✓ Add evidence to all important calculations
✓ Keep receipts and supporting documents
✓ Regular backups of your data

**Efficiency Tips**
✓ Save frequently used calculations as templates
✓ Use CSV import for bulk data entry
✓ Enable cloud backup for peace of mind
✓ Organize calculations with clear naming
✓ Review history regularly

**Compliance Tips**
✓ Add notes explaining special circumstances
✓ Attach supporting documentation
✓ Generate PDF receipts for all payments
✓ Maintain complete calculation history
✓ Review calculations before submission

**Collaboration Tips (Pro/Business)**
✓ Invite your accountant for professional review
✓ Assign appropriate roles to team members
✓ Use audit logs to track changes (Business)
✓ Regular team communication
✓ Centralized record keeping

**Security Tips**
✓ Use strong password
✓ Enable two-factor authentication (if available)
✓ Log out on shared devices
✓ Regular password updates
✓ Review account activity
''',
    ),
    ManualSection(
      title: '10. Troubleshooting',
      icon: Icons.help_outline,
      content: '''
**Common Issues & Solutions**

**Calculator Not Working**
- Check internet connection
- Ensure all required fields are filled
- Verify amounts are valid numbers
- Try clearing and re-entering data
- Restart the app

**PDF Export Failed**
- Check storage permissions
- Ensure sufficient device storage
- Try again with stable internet
- Update app to latest version

**Payment Issues**
- Verify payment gateway connection
- Check payment method validity
- Ensure sufficient funds
- Contact payment support

**Template Not Saving**
- Check if template name is unique
- Ensure calculation is complete
- Verify storage permissions
- Try again after calculation

**Import Failed**
- Check file format (CSV/JSON)
- Verify headers match requirements
- Ensure data is properly formatted
- Review sample data for format

**Login Problems**
- Verify email/password
- Check internet connection
- Reset password if forgotten
- Contact support if issues persist

**Missing Calculations**
- Check History screen
- Verify logged into correct account
- Ensure cloud backup is enabled
- Try refreshing the screen

**Need More Help?**
- Visit Help > Contact Support
- Email: support@taxpadi.com
- Check FAQ section
- Join community forum
''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Manual'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Free users see only first 3 sections
    final sectionsToShow = _isPaidUser ? _sections : _sections.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Could implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sectionsToShow.length + (!_isPaidUser ? 1 : 0),
        itemBuilder: (context, index) {
          // Show upgrade card after free sections
          if (!_isPaidUser && index == sectionsToShow.length) {
            return _UpgradeCard(
              onUpgrade: () {
                Navigator.pushNamed(context, '/help/pricing');
              },
            );
          }

          final section = sectionsToShow[index];
          return _SectionCard(section: section);
        },
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
  final ManualSection section;

  const _SectionCard({required this.section});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.section.icon,
                      color: Colors.green[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.section.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.green[700],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildFormattedContent(widget.section.content),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Bold headers (wrapped in **)
      if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        );
      }
      // Numbered lists
      else if (RegExp(r'^\d+\.').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              line,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        );
      }
      // Bullet points (- or ✓)
      else if (line.startsWith('- ') || line.startsWith('✓ ')) {
        final text = line.substring(2);
        final icon = line.startsWith('✓') ? '✓' : '•';
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$icon ',
                  style: TextStyle(
                    fontSize: 14,
                    color: line.startsWith('✓') ? Colors.green[700] : null,
                    fontWeight: line.startsWith('✓') ? FontWeight.bold : null,
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Regular text
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final VoidCallback onUpgrade;

  const _UpgradeCard({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.lock,
              size: 48,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 16),
            const Text(
              '🔒 Unlock Complete User Manual',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Upgrade to Pro or Business to access:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...[
              '📄 Evidence Management Guide',
              '📑 Templates & Time-Saving Tips',
              '💳 Advanced Payment Options',
              '📊 Import & Export Features',
              '👤 Profile & Team Management',
              '💡 Pro Tips & Best Practices',
              '🔧 Advanced Troubleshooting',
            ].map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUpgrade,
                icon: const Icon(Icons.workspace_premium),
                label: const Text(
                  'Upgrade Now',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onUpgrade,
              child: const Text('View Pricing Plans'),
            ),
          ],
        ),
      ),
    );
  }
}

class ManualSection {
  final String title;
  final IconData icon;
  final String content;

  ManualSection({
    required this.title,
    required this.icon,
    required this.content,
  });
}
