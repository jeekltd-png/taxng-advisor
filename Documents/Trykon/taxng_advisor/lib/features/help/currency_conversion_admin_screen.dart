import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Admin-only screen for currency conversion documentation and implementation
class CurrencyConversionAdminScreen extends StatefulWidget {
  const CurrencyConversionAdminScreen({super.key});

  @override
  State<CurrencyConversionAdminScreen> createState() =>
      _CurrencyConversionAdminScreenState();
}

class _CurrencyConversionAdminScreenState
    extends State<CurrencyConversionAdminScreen> {
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Currency Conversion - Admin Documentation'),
          backgroundColor: Colors.deepPurple,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Implementation'),
              Tab(text: 'API Reference'),
              Tab(text: 'Compliance'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildImplementationTab(),
            _buildApiReferenceTab(),
            _buildComplianceTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Currency Conversion Feature'),
          _buildText(
            'Converts tax amounts from Nigerian Naira (₦) to US Dollars (\$) '
            'and Pounds to USD. Users can see their tax obligations in multiple currencies '
            'for international reporting and compliance.',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Key Features'),
          _buildBulletList([
            'Three-currency display: NGN, USD (from NGN), USD (from GBP)',
            'Expandable widget (compact by default)',
            'Permanent card widget (always visible)',
            'Configurable exchange rates',
            'Works with all 6 tax calculators',
            'Professional appearance for reports',
          ]),
          const SizedBox(height: 16),
          _buildSectionHeader('Exchange Rates'),
          _buildCodeBlock(
            'static const double nairaToUsdRate = 0.00065; // 1 NGN\n'
            'static const double poundToUsdRate = 1.27;    // 1 GBP',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('User Benefits'),
          _buildBulletList([
            'International business: See taxes in familiar currency',
            'Professional reporting: Include USD equivalents in statements',
            'Banking: Provide required USD amounts for loan applications',
            'Financial planning: Budget in multiple currencies',
          ]),
          const SizedBox(height: 24),
          _buildInfoCard(
            'Files Created',
            'lib/utils/tax_helpers.dart (enhanced)\n'
                'lib/widgets/currency_converter_widget.dart (new)',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildImplementationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Integration Steps'),
          _buildNumberedList([
            'Import the widget',
            'Add widget to calculator screen',
            'Test with sample data',
            'Deploy to production',
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Add to CIT Calculator'),
          _buildText(
            'File: lib/features/cit/presentation/cit_calculator_screen.dart',
          ),
          const SizedBox(height: 8),
          _buildCodeBlock(
            "import 'package:taxng_advisor/widgets/currency_converter_widget.dart';\n\n"
            '// Add after _ResultCard for CIT Payable:\n'
            'CurrencyConverterWidget(\n'
            '  nairaAmount: result!.taxPayable,\n'
            '  label: \'CIT Payable\',\n'
            '  color: Colors.red,\n'
            '  isBold: true,\n'
            ')',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Integration for All Calculators'),
          _buildBulletList([
            'CIT: After CIT Payable result',
            'VAT: After VAT Payable/Refundable result',
            'PIT: After Total PIT result',
            'WHT: After WHT Calculated result',
            'Payroll: After Monthly/Annual PAYE result',
            'Stamp Duty: After Stamp Duty Payable result',
          ]),
          const SizedBox(height: 24),
          _buildInfoCard(
            'Integration Time',
            'Each calculator: 5-8 lines of code\n'
                'All 6 calculators: ~1 hour total',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildApiReferenceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CurrencyFormatter Methods'),
          const SizedBox(height: 12),
          _buildMethodCard(
            'convertNairaToUsd',
            'double nairaAmount',
            'double',
            'Converts Naira amount to USD',
          ),
          _buildMethodCard(
            'convertPoundsToUsd',
            'double poundAmount',
            'double',
            'Converts Pounds amount to USD',
          ),
          _buildMethodCard(
            'formatNairaToUsd',
            'double nairaAmount',
            'String',
            'Returns formatted USD string (e.g., "\$1.95K")',
          ),
          _buildMethodCard(
            'formatPoundsToUsd',
            'double poundAmount',
            'String',
            'Returns formatted USD string from GBP',
          ),
          _buildMethodCard(
            'formatMultiCurrency',
            'double nairaAmount',
            'Map<String, String>',
            'Returns all currency formats in a Map',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('CurrencyConverterWidget Constructor'),
          _buildCodeBlock(
            'const CurrencyConverterWidget({\n'
            '  required double nairaAmount,\n'
            '  String label = \'Tax Amount\',\n'
            '  Color? color,\n'
            '  bool isBold = false,\n'
            '})',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('CurrencyConversionCard Constructor'),
          _buildCodeBlock(
            'const CurrencyConversionCard({\n'
            '  required double nairaAmount,\n'
            '  String title = \'Tax Amount Conversion\',\n'
            '})',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Usage Examples'),
          _buildCodeBlock(
            '// Example 1: Expandable widget\n'
            'CurrencyConverterWidget(\n'
            '  nairaAmount: 5000000,\n'
            '  label: \'Tax Payable\',\n'
            '  color: Colors.red,\n'
            ')\n\n'
            '// Example 2: Permanent card\n'
            'CurrencyConversionCard(\n'
            '  nairaAmount: 10000000,\n'
            '  title: \'Annual Tax\',\n'
            ')\n\n'
            '// Example 3: Direct formatting\n'
            'String usdAmount = CurrencyFormatter.formatNairaToUsd(3000000);\n'
            '// Output: "\$1.95K"',
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            'Exchange Rates',
            '1 NGN = \$0.00065\n'
                '1 GBP = \$1.27\n\n'
                'Update in: CurrencyFormatter class (tax_helpers.dart)',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.6),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
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

  Widget _buildNumberedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(items[index], style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard(
    String name,
    String params,
    String returns,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Parameters: $params',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Returns: $returns',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
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

  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Regulatory Compliance & Standards'),
          const SizedBox(height: 8),
          _buildText(
            'TaxNG Advisor follows Nigerian tax regulations and international standards for tax compliance, data security, and professional accounting practices.',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('1. Nigerian Tax Framework'),
          const SizedBox(height: 8),
          _buildInfoCard(
            'Primary Reference',
            'Nigeria Tax Act 2025\nFederal Inland Revenue Service (FIRS) Guidelines',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildText('Tax Types Implemented:'),
          _buildBulletList([
            'CIT (Corporate Income Tax) - For companies',
            'PIT (Personal Income Tax) - Progressive tax bands',
            'VAT (Value Added Tax) - 7.5% standard rate (2025 reform)',
            'WHT (Withholding Tax) - 9 types for different income sources',
            'Stamp Duty - 9 types for various documents/transactions',
            'Payroll/PAYE - Employee tax deductions',
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('2. FIRS Compliance Standards'),
          const SizedBox(height: 8),
          _buildBulletList([
            'VAT registration threshold: ₦25M annual turnover',
            'Stamp duty registration: Annual duty ≥ ₦100,000',
            'Monthly WHT filing (15th of each month)',
            'Monthly VAT returns (21st of each month)',
            'Annual CIT filing (May 31st deadline)',
            'Annual PIT filing (May 31st deadline)',
            'Quarterly VAT returns for businesses',
            'Payroll tax remittance (last business day)',
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('3. Tax Calculation Standards'),
          const SizedBox(height: 8),
          _buildCodeBlock(
            '// VAT Rates (2025 Reform)\n'
            'Standard Rate: 7.5%\n'
            'Zero-rated: 0% (exports, basic goods)\n'
            'Exempt: N/A (healthcare, education)\n\n'
            '// CIT Rates\n'
            'Progressive rates based on company size\n\n'
            '// PIT Bands\n'
            '5 progressive tax bands with reliefs\n\n'
            '// WHT Rates\n'
            '5-10% depending on income type\n\n'
            '// Stamp Duty\n'
            '0.5%-3% by document type',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('4. Data Security & Privacy'),
          const SizedBox(height: 8),
          _buildBulletList([
            'Flutter Secure Storage for sensitive data',
            'Encryption support (encrypt package)',
            'User authentication with password hashing',
            'Admin-only access to sensitive documentation',
            'Local data persistence (no external servers)',
            'Hive database with named boxes',
            'Timestamp tracking for audit trails',
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('5. Code Quality Standards'),
          const SizedBox(height: 8),
          _buildBulletList([
            'Dart conventions and best practices',
            'Strong type safety (no dynamic returns)',
            'Comprehensive dartdoc comments',
            'Input validation at all entry points',
            'Proper error handling with exceptions',
            'Model-View-Controller (MVC) architecture',
            'Repository pattern for data access',
            'Service layer for business logic',
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('6. Currency Conversion Compliance'),
          const SizedBox(height: 8),
          _buildBulletList([
            'Exchange rates documented for audit',
            'Multi-currency support (NGN, USD, GBP)',
            'Conversion tracking for international reporting',
            'Professional format for financial statements',
            'Configurable rates for accuracy',
            'Transparent calculation methodology',
          ]),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Exchange Rate Documentation',
            'Current Rates:\n'
                '1 NGN = \$0.00065 USD\n'
                '1 GBP = \$1.27 USD\n\n'
                'Rates should be updated regularly and documented for compliance.',
            Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('7. Import/Export Standards'),
          const SizedBox(height: 8),
          _buildBulletList([
            'CSV import with header validation',
            'Excel support for bulk data',
            'JSON structured data import',
            'Field validation against tax requirements',
            'Error handling with user feedback',
            'Sample templates provided',
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('8. Reporting & Documentation'),
          const SizedBox(height: 8),
          _buildBulletList([
            'Period-based reporting (monthly, quarterly, annual)',
            'Tax liability summaries',
            'Effective rate calculations',
            'Compliance checklists',
            'Audit trail with timestamps',
            'PDF generation for official reports',
            'Multi-format export (CSV, PDF, Excel)',
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('9. Deadline Management'),
          const SizedBox(height: 8),
          _buildText(
            'Automated reminder system for all tax deadlines:',
          ),
          const SizedBox(height: 8),
          _buildBulletList([
            'VAT: Monthly (21st)',
            'PIT: Annual (May 31st)',
            'CIT: Annual (May 31st)',
            'WHT: Monthly (15th)',
            'Payroll: Monthly (last business day)',
            'Stamp Duty: Quarterly reminders',
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('10. Professional Standards'),
          const SizedBox(height: 8),
          _buildBulletList([
            'Follows accounting best practices',
            'International reporting standards',
            'Multi-user support (Pro/Business tiers)',
            'Accountant collaboration features',
            'Team roles and audit logs (Business tier)',
            'Payment integration (Remita, Flutterwave, Paystack)',
          ]),
          const SizedBox(height: 24),
          _buildInfoCard(
            'Validation & Testing',
            'All calculators include:\n'
                '✓ Input validation\n'
                '✓ Edge case handling\n'
                '✓ Clear error messages\n'
                '✓ Type-safe operations\n'
                '✓ Deterministic behavior\n'
                '✓ Comprehensive documentation',
            Colors.blue,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('11. Updates & Maintenance'),
          const SizedBox(height: 8),
          _buildBulletList([
            'Monitor FIRS guidance for tax rule changes',
            'Push rule updates in app releases',
            'Critical updates flagged in-app',
            'Auto-update notifications',
            'Version control for tax calculations',
            'Documentation updates with each release',
          ]),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Important Note',
            'Users should always verify calculations and stay current with official FIRS guidelines. '
                'This app provides automated calculations but professional tax advice is recommended for complex situations.',
            Colors.red,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('References'),
          const SizedBox(height: 8),
          _buildBulletList([
            'Nigeria Tax Act 2025',
            'Federal Inland Revenue Service (FIRS)',
            'Flutter/Dart Best Practices',
            'Material Design Guidelines',
            'Nigerian Financial Regulations',
          ]),
        ],
      ),
    );
  }
}
