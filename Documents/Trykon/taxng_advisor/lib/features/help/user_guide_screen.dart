import 'package:flutter/material.dart';

/// Comprehensive user guide for using the TaxPadi app
class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use TaxPadi'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome section
          _buildWelcomeCard(),
          const SizedBox(height: 16),

          // Quick start guide
          _buildQuickStartGuide(),
          const SizedBox(height: 16),

          // Step-by-step instructions
          _buildStepByStepInstructions(),
          const SizedBox(height: 16),

          // Tips and best practices
          _buildTipsSection(),
          const SizedBox(height: 16),

          // FAQ section
          _buildFAQSection(),
          const SizedBox(height: 24),

          // Get started button
          _buildGetStartedButton(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/icon.png', height: 80, width: 80),
            const SizedBox(height: 12),
            const Text(
              'Welcome to TaxPadi!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tax Compliance Made Simple',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Calculate • Document • Notify • Comply\n\nThe Multi Tax professional-grade Tool to calculate, document, and communicate Nigerian Tax',
              style: TextStyle(fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartGuide() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Quick Start (5 Easy Steps)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuickStep(
              number: '1',
              title: 'Login',
              description: 'Use admin/Admin@123 for full access (testing)',
              icon: Icons.login,
              color: Colors.blue,
            ),
            _buildQuickStep(
              number: '2',
              title: 'Choose Calculator',
              description:
                  'Select tax type: CIT, PIT, VAT, WHT, PAYE, Stamp Duty',
              icon: Icons.calculate,
              color: Colors.green,
            ),
            _buildQuickStep(
              number: '3',
              title: 'Enter Data & Evidence',
              description: 'Input amounts, add notes and attachments',
              icon: Icons.edit_note,
              color: Colors.orange,
            ),
            _buildQuickStep(
              number: '4',
              title: 'Calculate & Review',
              description: 'See results with detailed breakdowns',
              icon: Icons.analytics,
              color: Colors.purple,
            ),
            _buildQuickStep(
              number: '5',
              title: 'Save or Pay',
              description: 'Save as template, record payment, or pay online',
              icon: Icons.payment,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepByStepInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Detailed Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstruction(
              step: '1',
              title: 'Login/Register',
              details: [
                'Open TaxPadi app',
                'Enter your email and password',
                'New user? Tap "Register" to create account',
                'Select your business sector',
              ],
            ),
            _buildInstruction(
              step: '2',
              title: 'Navigate Dashboard',
              details: [
                'View your current subscription tier',
                'See tax calculator options',
                'Access payment history',
                'Check reminders and deadlines',
              ],
            ),
            _buildInstruction(
              step: '3',
              title: 'Select Tax Calculator',
              details: [
                'Tap on the tax type you need:',
                '  • CIT - Company Income Tax',
                '  • VAT - Value Added Tax',
                '  • PIT - Personal Income Tax',
                '  • WHT - Withholding Tax',
                '  • Payroll - Employee taxes',
                '  • Stamp Duty - Transaction taxes',
              ],
            ),
            _buildInstruction(
              step: '4',
              title: 'Enter Your Data',
              details: [
                'Fill in required fields (marked with *)',
                'Use number format: 1000000 (no commas)',
                'Tap info icons (ℹ️) next to fields for help',
                'Real-time validation shows errors instantly with contextual help',
                '🎯 NEW: Tap "Use Example Data" button for instant sample data',
                '📥 NEW: Tap blue "Import" button to upload CSV/JSON files',
                'Import auto-fills form and calculates immediately',
                'For USD payments (Oil & Gas): Amount auto-converts',
                'Save common inputs as templates for reuse',
                '📝 Add notes and attachments in "Data Source & Notes" section',
              ],
            ),
            _buildInstruction(
              step: '5',
              title: 'Review Calculations',
              details: [
                'Tap green "Calculate" button to see results',
                '⏳ NEW: Animated progress indicator shows calculation in progress',
                'Validation errors block calculation until fixed',
                'Warning messages let you confirm and continue',
                'Review each calculation line with detailed breakdowns',
                'Tap any item to see detailed explanations',
                '📄 NEW: Use Quick Export buttons - PDF or Share',
                '  • PDF: Opens viewer with save/print/share options',
                '  • Share: Email, WhatsApp, or Copy to clipboard',
                '🕐 NEW: View Recent Calculations on dashboard (last 3)',
              ],
            ),
            _buildInstruction(
              step: '6',
              title: 'Make Payment',
              details: [
                'Tap "Pay Now" button',
                'Select tax account (Federal/State)',
                'Choose payment method',
                'Confirm payment details',
                'Receive email confirmation',
                'Download receipt',
              ],
            ),
            _buildInstruction(
              step: '7',
              title: 'Track & Manage',
              details: [
                'View payment history in Profile',
                'Set tax reminders for deadlines',
                'Use templates to save common calculations',
                'Search templates by name, category, or period',
                'Export reports to PDF/CSV',
                'Contact support if needed',
              ],
            ),
            _buildInstruction(
              step: '8',
              title: 'Team Collaboration (Pro/Business)',
              details: [
                'Go to Profile → Team Management',
                'Invite accountant or team members via email',
                'Assign roles: Viewer, Editor, or Admin',
                'Share calculation history and templates',
                'Business tier: View audit logs of all changes',
                'Collaborate without manual file exports',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction({
    required String step,
    required String title,
    required List<String> details,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Step $step',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...details.map((detail) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.grey[600])),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  'Tips & Best Practices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip(
              icon: Icons.upload_file,
              title: 'Quick Import',
              tip:
                  'NEW! Tap the blue Import button in any calculator to upload CSV/JSON files. Data fills automatically!',
            ),
            _buildTip(
              icon: Icons.save,
              title: 'Use Templates',
              tip:
                  'Save frequent calculations as templates. Load them with one tap for recurring periods.',
            ),
            _buildTip(
              icon: Icons.touch_app,
              title: 'Tap Info Icons',
              tip:
                  'Blue info icons (ℹ️) next to fields and buttons provide helpful guidance and examples.',
            ),
            _buildTip(
              icon: Icons.check_circle,
              title: 'Validation Helps',
              tip:
                  'Real-time validation catches errors as you type. Red = must fix, Orange = review.',
            ),
            _buildTip(
              icon: Icons.calendar_today,
              title: 'Set Reminders',
              tip: 'Enable tax reminders so you never miss a filing deadline.',
            ),
            _buildTip(
              icon: Icons.receipt_long,
              title: 'Keep Records',
              tip: 'Export PDFs and keep payment receipts for your records.',
            ),
            _buildTip(
              icon: Icons.currency_exchange,
              title: 'Currency Conversion',
              tip:
                  'Oil & Gas sector? Amounts automatically convert between NGN and USD.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip({
    required IconData icon,
    required String title,
    required String tip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.amber[700]),
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
                  tip,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFAQ(
              question: 'Is my data secure?',
              answer:
                  'Yes! All data is encrypted and stored securely on your device.',
            ),
            _buildFAQ(
              question: 'Can I use this offline?',
              answer:
                  'Yes, calculations work offline. Payments require internet connection.',
            ),
            _buildFAQ(
              question: 'What payment methods are accepted?',
              answer:
                  'Bank transfer, card payments (via Paystack), and mobile money.',
            ),
            _buildFAQ(
              question: 'How do I upgrade my subscription?',
              answer:
                  'Go to Profile → Upgrade Subscription. Upload payment proof for verification.',
            ),
            _buildFAQ(
              question: 'What are templates and how do I use them?',
              answer:
                  'Templates save your input data for reuse. Tap "Save" after entering data, then "Load" to quickly fill forms later. Search by name, period (e.g., "Q1 2025"), or category.',
            ),
            _buildFAQ(
              question: 'Can I upload data from Excel or CSV files?',
              answer:
                  'Yes! Tap the blue "Import" button in any calculator. Choose your CSV/JSON file or paste data directly. The form fills and calculates automatically. See "View Sample Format" for examples.',
            ),
            _buildFAQ(
              question: 'What do the validation messages mean?',
              answer:
                  'Red errors must be fixed before calculating. Orange warnings are suggestions - you can review and proceed if the values are intentional.',
            ),
            _buildFAQ(
              question: 'Can I invite my accountant or team members?',
              answer:
                  'Yes! Pro and Business tiers support multi-user access. Go to Profile → Team Management and invite via email. You can assign roles (Viewer, Editor, Admin) and Business tier includes team audit logs for tracking all changes.',
            ),
            _buildFAQ(
              question: 'Why invite an accountant?',
              answer:
                  'Your accountant can review calculations, verify entries for compliance, access your history and templates, and generate professional reports - all without manual file sharing. Perfect for businesses with multiple tax obligations.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ({
    required String question,
    required String answer,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q: $question',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A: $answer',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: Image.asset('assets/icon.png', height: 24, width: 24),
        label: const Text(
          'Got It! Start Using TaxPadi',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
