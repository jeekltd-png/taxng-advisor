import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/features/help/payment_guide_screen.dart';
import 'package:taxng_advisor/features/help/privacy_policy_screen.dart';

class HelpArticlesScreen extends StatefulWidget {
  const HelpArticlesScreen({Key? key}) : super(key: key);

  @override
  State<HelpArticlesScreen> createState() => _HelpArticlesScreenState();
}

class _HelpArticlesScreenState extends State<HelpArticlesScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = await AuthService.currentUser();
    setState(() {
      _isAdmin = user?.isAdmin ?? false;
    });
  }

  static const _articles = [
    {
      'title': 'How to import JSON data',
      'body':
          'Go to Profile > Import Data section. Paste your JSON data or choose a JSON file. The app will automatically prefill the calculator with your data. JSON format: {"type": "CIT", "year": 2024, "data": {...}}'
    },
    {
      'title': 'How to import CSV data',
      'body':
          'Go to Profile > Import Data section. You can paste CSV data (comma-separated values) or choose a CSV file. First row must contain headers matching field names (type, year, turnover, expenses, profit, businessName, tin for CIT). The app will parse and prefill your calculator.'
    },
    {
      'title': 'CSV format by tax type',
      'body':
          'CIT: type,year,turnover,expenses,profit,businessName,tin\n\nVAT: type,year,period,totalSales,taxableSales,exemptSales,inputTax,outputTax,vat\n\nPIT: type,year,employeeId,employeeName,grossIncome,taxableIncome,personalRelief,standardRelief,pit\n\nUse Sample Data screen to see examples and copy working templates.'
    },
    {
      'title': 'How to use Excel files',
      'body':
          'Create your data in Excel, then save as CSV format (File > Save As > Format: CSV). Then import the CSV file into the app Profile > Import Data. Alternatively, copy-paste the data from Excel directly into the import field.'
    },
    {
      'title': 'How to generate a payment link',
      'body':
          'Go to the relevant calculator (e.g., VAT/CIT), fill your details and tap "Generate Payment Link". You can copy or share the link to complete payment via supported gateways.'
    },
    {
      'title': 'Backing up your data',
      'body':
          'Enable cloud backup in Settings to securely store encrypted backups of your records. Backups are AES-encrypted and require your account credentials to restore.'
    },
    {
      'title': 'Inviting an accountant',
      'body':
          'Upgrade to Pro or Business, then open Profile > Team and invite your accountant via email. The invited user will get access according to the role you assign.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Articles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Help articles
          ..._articles.map((a) => ListTile(
                title: Text(a['title']!),
                subtitle: Text(a['body']!),
              )),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Quick Actions heading
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Admin buttons
          if (_isAdmin)
            _ActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/help/admin/user-testing'),
              label: 'Admin: User Testing',
              icon: Icons.science,
            ),
          if (_isAdmin) const SizedBox(height: 12),
          if (_isAdmin)
            _ActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/help/admin/csv-excel'),
              label: 'Admin: CSV/Excel',
              icon: Icons.table_chart,
            ),
          if (_isAdmin) const SizedBox(height: 12),
          if (_isAdmin)
            _ActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/help/admin/deployment'),
              label: 'Admin: Deployment',
              icon: Icons.cloud_upload,
            ),
          if (_isAdmin) const SizedBox(height: 12),
          if (_isAdmin)
            _ActionButton(
              onPressed: () => Navigator.pushNamed(
                  context, '/help/admin/currency-conversion'),
              label: 'Admin: Currency',
              icon: Icons.admin_panel_settings,
            ),
          if (_isAdmin) const SizedBox(height: 12),
          if (_isAdmin)
            _ActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentGuideScreen(isAdmin: true),
                ),
              ),
              label: 'Admin: Payments',
              icon: Icons.receipt,
            ),
          if (_isAdmin) const SizedBox(height: 12),
          // User buttons
          _ActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentGuideScreen(isAdmin: false),
              ),
            ),
            label: 'Tax Payments',
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            onPressed: () => Navigator.pushNamed(context, '/help/pricing'),
            label: 'Pricing & Plans',
            icon: Icons.payments,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            onPressed: () => Navigator.pushNamed(context, '/help/sample-data'),
            label: 'Sample Data',
            icon: Icons.data_object,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            onPressed: () => Navigator.pushNamed(context, '/help/contact'),
            label: 'Contact Support',
            icon: Icons.email,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            ),
            label: 'Privacy Policy',
            icon: Icons.privacy_tip,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _ActionButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA5D6A7),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
