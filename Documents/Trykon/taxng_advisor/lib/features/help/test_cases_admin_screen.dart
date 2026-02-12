import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/theme/colors.dart';

/// Admin-only screen for accessing comprehensive test cases
/// This screen is restricted to administrators and QA testers only
class TestCasesAdminScreen extends StatefulWidget {
  const TestCasesAdminScreen({super.key});

  @override
  State<TestCasesAdminScreen> createState() => _TestCasesAdminScreenState();
}

class _TestCasesAdminScreenState extends State<TestCasesAdminScreen> {
  int _selectedCategory = 0;

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
            content: Text('⚠️ Admin access required for Test Cases'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Cases - Admin Only'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TaxNGColors.primaryDark, TaxNGColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'View Full Documentation',
            onPressed: _showFullDocumentationDialog,
          ),
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: 'Test Execution Checklist',
            onPressed: _showTestChecklist,
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar navigation
          Container(
            width: 250,
            color: Colors.grey[100],
            child: ListView(
              children: [
                _buildCategoryTile(0, '📊 Overview', Icons.dashboard),
                _buildCategoryTile(1, '🧮 CIT Tests', Icons.business),
                _buildCategoryTile(2, '👤 PIT Tests', Icons.person),
                _buildCategoryTile(3, '📈 VAT Tests', Icons.show_chart),
                _buildCategoryTile(4, '💰 WHT Tests', Icons.attach_money),
                _buildCategoryTile(5, '📜 Stamp Duty', Icons.description),
                _buildCategoryTile(6, '💼 Payroll Tests', Icons.payment),
                _buildCategoryTile(7, '💾 Data Tests', Icons.storage),
                _buildCategoryTile(8, '🔔 Reminder Tests', Icons.notifications),
                _buildCategoryTile(9, '💳 Payment Tests', Icons.payment),
                _buildCategoryTile(10, '🎨 UI/UX Tests', Icons.design_services),
                _buildCategoryTile(11, '⚡ Performance', Icons.speed),
                _buildCategoryTile(12, '🔒 Security', Icons.security),
                _buildCategoryTile(13, '🐛 Error Handling', Icons.bug_report),
                _buildCategoryTile(14, '📱 Compatibility', Icons.phone_android),
                _buildCategoryTile(15, '🏪 Play Store', Icons.store),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCategoryContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(int index, String title, IconData icon) {
    final isSelected = _selectedCategory == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.redAccent : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.redAccent : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.red[50],
      onTap: () => setState(() => _selectedCategory = index),
    );
  }

  Widget _buildCategoryContent() {
    switch (_selectedCategory) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildCITTests();
      case 2:
        return _buildPITTests();
      case 3:
        return _buildVATTests();
      case 4:
        return _buildWHTTests();
      case 5:
        return _buildStampDutyTests();
      case 6:
        return _buildPayrollTests();
      case 7:
        return _buildDataTests();
      case 8:
        return _buildReminderTests();
      case 9:
        return _buildPaymentTests();
      case 10:
        return _buildUITests();
      case 11:
        return _buildPerformanceTests();
      case 12:
        return _buildSecurityTests();
      case 13:
        return _buildErrorHandlingTests();
      case 14:
        return _buildCompatibilityTests();
      case 15:
        return _buildPlayStoreTests();
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Test Cases Overview'),
        const SizedBox(height: 16),
        _buildInfoCard(
          'App Information',
          [
            'App Name: TAXNG Advisor',
            'Version: 1.0.0+1',
            'Platform: Android',
            'Release Type: Play Store (Internal Testing)',
            'Test Date: December 30, 2025',
          ],
        ),
        const SizedBox(height: 24),
        _buildStatCard('Total Test Cases', '70+', Colors.blue),
        const SizedBox(height: 16),
        _buildStatCard('High Priority Cases', '35+', Colors.red),
        const SizedBox(height: 16),
        _buildStatCard('Medium Priority Cases', '25+', Colors.orange),
        const SizedBox(height: 16),
        _buildStatCard('Low Priority Cases', '10+', Colors.green),
        const SizedBox(height: 24),
        _buildHeader('Test Coverage Summary'),
        const SizedBox(height: 16),
        _buildCoverageList([
          'Functional Testing: CIT, PIT, VAT, WHT, Stamp Duty, Payroll',
          'Data Persistence: Save, Retrieve, Delete operations',
          'Reminders & Notifications: Creation, Scheduling, Delivery',
          'Payment Gateway: Flow, Methods, History',
          'UI/UX: Navigation, Layout, Accessibility',
          'Performance: Launch time, Calculations, Database queries',
          'Security: Secure storage, Data privacy, Input sanitization',
          'Compatibility: Android versions, Screen sizes, Devices',
          'Error Handling: Invalid inputs, Edge cases',
          'Play Store: Installation, Updates, Reviews',
        ]),
        const SizedBox(height: 24),
        _buildHeader('Testing Phases'),
        const SizedBox(height: 16),
        _buildPhaseCard(
          'Phase 1: Critical',
          'High priority functional tests',
          Colors.red,
          ['All calculator tests', 'Payment flow', 'Data persistence'],
        ),
        const SizedBox(height: 12),
        _buildPhaseCard(
          'Phase 2: Core',
          'Medium priority + End-to-end flows',
          Colors.orange,
          ['UI/UX tests', 'Import/Export', 'Reminder system'],
        ),
        const SizedBox(height: 12),
        _buildPhaseCard(
          'Phase 3: Polish',
          'Low priority + Edge cases',
          Colors.blue,
          ['Accessibility', 'Localization', 'Advanced features'],
        ),
        const SizedBox(height: 12),
        _buildPhaseCard(
          'Phase 4: Pre-Launch',
          'Play Store specific + Final regression',
          Colors.green,
          ['Installation tests', 'Update process', 'Final validation'],
        ),
      ],
    );
  }

  Widget _buildCITTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Corporate Income Tax (CIT) Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-CIT-001',
          'Standard CIT Calculation',
          'High',
          [
            'Enter Turnover: ₦100,000,000',
            'Enter Assessable Profit: ₦20,000,000',
            'Click "Calculate"',
          ],
          [
            'CIT Payable: ₦6,000,000 (30% of ₦20M)',
            'Effective Rate: 6%',
            'Display breakdown correctly',
            'Values formatted with currency symbol',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-CIT-002',
          'Small Company Education Tax Calculation',
          'High',
          [
            'Enter Turnover: ₦100,000,000',
            'Enter Assessable Profit: ₦20,000,000',
            'Enable "Include Education Tax" checkbox',
            'Click "Calculate"',
          ],
          [
            'CIT Payable: ₦6,000,000',
            'Education Tax: ₦600,000',
            'Total Tax: ₦6,600,000',
            'Breakdown shows both components',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-CIT-003',
          'Input Validation - Negative Values',
          'High',
          [
            'Enter Turnover: -₦100,000',
            'Attempt to calculate',
          ],
          [
            'Error message: "Turnover must be a positive value"',
            'Calculate button disabled or shows error',
            'No calculation performed',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-CIT-004',
          'Input Validation - Profit > Turnover',
          'High',
          [
            'Enter Turnover: ₦10,000,000',
            'Enter Profit: ₦20,000,000',
            'Click "Calculate"',
          ],
          [
            'Error message: "Profit cannot exceed turnover"',
            'Calculation blocked',
            'User prompted to correct input',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-CIT-005',
          'Zero/Null Input Handling',
          'Medium',
          [
            'Leave Turnover empty or enter 0',
            'Enter Profit: ₦1,000,000',
            'Click "Calculate"',
          ],
          [
            'Error message: "Please enter valid turnover"',
            'Calculation prevented',
            'Form highlights invalid field',
          ],
        ),
      ],
    );
  }

  Widget _buildPITTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Personal Income Tax (PIT) Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-PIT-001',
          'Basic PIT Calculation with Progressive Bands',
          'High',
          [
            'Enter Gross Income: ₦5,000,000',
            'Enter Other Deductions: ₦200,000',
            'Click "Calculate"',
          ],
          [
            'Chargeable Income calculated correctly',
            'Tax calculated using progressive bands',
            'Total PIT displayed',
            'Breakdown by tax band shown',
            'Effective rate calculated',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-PIT-002',
          'Rent Relief Application',
          'High',
          [
            'Enter Gross Income: ₦10,000,000',
            'Enter Annual Rent Paid: ₦3,000,000',
            'Click "Calculate"',
          ],
          [
            'Rent Relief: ₦500,000 (max 20% or ₦500K cap)',
            'Chargeable income reduced by rent relief',
            'Relief amount clearly shown in breakdown',
            'Total PIT recalculated with relief',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-PIT-003',
          'Multiple Deductions',
          'Medium',
          [
            'Enter Gross Income: ₦8,000,000',
            'Enter Pension: ₦640,000',
            'Enter NHF: ₦160,000',
            'Enter Other Deductions: ₦300,000',
            'Click "Calculate"',
          ],
          [
            'All deductions applied correctly',
            'Total deductions: ₦1,100,000',
            'Chargeable income = Gross - Deductions - CRA',
            'Tax calculated on reduced amount',
          ],
        ),
      ],
    );
  }

  Widget _buildVATTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Value Added Tax (VAT) Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-VAT-001',
          'Standard VAT Calculation',
          'High',
          [
            'Add supply: Amount ₦10,000,000, Type: Standard (7.5%)',
            'Enter Total Input VAT: ₦500,000',
            'Click "Calculate"',
          ],
          [
            'Output VAT: ₦750,000 (7.5% of ₦10M)',
            'Recoverable Input VAT: ₦500,000',
            'Net VAT Payable: ₦250,000',
            'Breakdown clearly displayed',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-VAT-002',
          'Zero-Rated Supplies',
          'High',
          [
            'Add supply: Amount ₦5,000,000, Type: Zero-Rated (0%)',
            'Add supply: Amount ₦5,000,000, Type: Standard (7.5%)',
            'Enter Input VAT: ₦600,000',
            'Click "Calculate"',
          ],
          [
            'Output VAT: ₦375,000 (only on standard)',
            'All input VAT recoverable: ₦600,000',
            'VAT Refundable: ₦225,000',
            'Correct classification of supplies',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-VAT-003',
          'Exempt Supplies Impact',
          'Medium',
          [
            'Add supply: Amount ₦10,000,000, Type: Exempt',
            'Enter Total Input VAT: ₦800,000',
            'Enter Exempt Input VAT: ₦300,000',
            'Click "Calculate"',
          ],
          [
            'Output VAT: ₦0 (exempt supplies)',
            'Recoverable Input: ₦500,000',
            'Exempt input VAT not recoverable',
            'Clear explanation shown',
          ],
        ),
      ],
    );
  }

  Widget _buildWHTTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Withholding Tax (WHT) Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-WHT-001',
          'Dividend WHT Calculation',
          'High',
          [
            'Select Type: Dividends',
            'Enter Amount: ₦1,000,000',
            'Click "Calculate"',
          ],
          [
            'WHT Rate: 10%',
            'WHT Amount: ₦100,000',
            'Net to Recipient: ₦900,000',
            'Rate automatically applied',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-WHT-002',
          'Professional Fees WHT',
          'High',
          [
            'Select Type: Professional Fees',
            'Enter Amount: ₦5,000,000',
            'Calculate',
          ],
          [
            'WHT Rate: 10%',
            'WHT Amount: ₦500,000',
            'Net Payment: ₦4,500,000',
            'Description shows "Professional service fees"',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-WHT-003',
          'Construction Contracts (Reduced Rate)',
          'Medium',
          [
            'Select Type: Construction',
            'Enter Amount: ₦20,000,000',
            'Calculate',
          ],
          [
            'WHT Rate: 5% (reduced rate)',
            'WHT Amount: ₦1,000,000',
            'Net Payment: ₦19,000,000',
            'Note about reduced rate displayed',
          ],
        ),
      ],
    );
  }

  Widget _buildStampDutyTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Stamp Duty Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-SD-001',
          'Property Transfer Stamp Duty',
          'High',
          [
            'Select Type: Property Transfer',
            'Enter Amount: ₦50,000,000',
            'Calculate',
          ],
          [
            'Stamp Duty Rate applied correctly',
            'Duty amount calculated',
            'Transaction value shown',
            'Type-specific notes displayed',
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'All Stamp Duty Types',
          [
            'Property Transfer',
            'Lease Agreements',
            'Share Transfers',
            'Loan Agreements',
            'Bills of Exchange',
            'Promissory Notes',
            'Powers of Attorney',
            'Contracts',
            'Other Instruments',
          ],
        ),
      ],
    );
  }

  Widget _buildPayrollTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Payroll (PAYE) Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-PAYROLL-001',
          'Basic Monthly PAYE Calculation',
          'High',
          [
            'Enter Monthly Gross: ₦500,000',
            'Enter Pension Rate: 8%',
            'Enter NHF Rate: 2%',
            'Calculate',
          ],
          [
            'Monthly Pension: ₦40,000',
            'Monthly NHF: ₦10,000',
            'Monthly PAYE calculated using annual PIT rates',
            'Monthly Net Salary: Gross - PAYE - Deductions',
            'Annual projections shown',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-PAYROLL-002',
          'Custom Deductions',
          'Medium',
          [
            'Enter Monthly Gross: ₦800,000',
            'Add Other Deductions: ₦50,000',
            'Set custom pension rate: 10%',
            'Calculate',
          ],
          [
            'All deductions applied',
            'PAYE based on taxable income',
            'Net salary accurate',
            'Annual totals calculated correctly',
          ],
        ),
      ],
    );
  }

  Widget _buildDataTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Data Persistence Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-DATA-001',
          'Save Calculation History',
          'High',
          [
            'Perform CIT calculation',
            'Navigate away from screen',
            'Return to calculations history',
          ],
          [
            'Calculation saved to Hive database',
            'Historical record visible in history',
            'All calculation details preserved',
            'Timestamp recorded',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-DATA-002',
          'Retrieve Recent Calculations',
          'High',
          [
            'Perform multiple calculations (CIT, PIT, VAT)',
            'Go to Dashboard',
            'View recent calculations',
          ],
          [
            'All recent calculations listed',
            'Correct tax type labels',
            'Accurate amounts displayed',
            'Chronological order (newest first)',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-DATA-003',
          'Delete Calculation Record',
          'Medium',
          [
            'View calculation history',
            'Select a record',
            'Delete the record',
            'Confirm deletion',
          ],
          [
            'Record removed from history',
            'Database updated',
            'UI refreshes without deleted item',
            'No errors or crashes',
          ],
        ),
      ],
    );
  }

  Widget _buildReminderTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Reminders & Notifications Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-REM-001',
          'Set Tax Deadline Reminder',
          'High',
          [
            'Go to Reminders screen',
            'Create new reminder: "CIT Filing Due" for Feb 1, 2026',
            'Save reminder',
          ],
          [
            'Reminder created successfully',
            'Stored in Hive database',
            'Appears in reminders list',
            'Notification scheduled with OS',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-REM-002',
          'Receive Notification at Due Date',
          'High',
          [
            'Set reminder for near-future time (5 minutes ahead)',
            'Wait for notification',
          ],
          [
            'Push notification received at scheduled time',
            'Notification shows reminder title',
            'Tapping opens app to reminders screen',
            'Sound/vibration as per device settings',
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Payment Gateway Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-PAY-001',
          'Navigate to Payment Screen',
          'High',
          [
            'Complete a tax calculation (e.g., CIT)',
            'Click "Pay Tax" button',
          ],
          [
            'Payment gateway screen opens',
            'Tax amount pre-filled',
            'Tax type displayed correctly',
            'Payment options shown',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-PAY-002',
          'Select Payment Method - Bank Transfer',
          'High',
          [
            'On payment screen, select Bank Transfer',
            'View payment instructions',
          ],
          [
            'Correct government tax account displayed',
            'Account number, bank name shown',
            'Reference number generated',
            'Instructions clear and complete',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-PAY-003',
          'Record Bank Transfer Payment',
          'High',
          [
            'Select Bank Transfer',
            'Enter bank details and reference',
            'Mark as paid',
            'Submit',
          ],
          [
            'Payment record saved',
            'Status: "Success" (or "Pending")',
            'Receipt/confirmation shown',
            'Record added to payment history',
          ],
        ),
      ],
    );
  }

  Widget _buildUITests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('UI/UX Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-UI-001',
          'Navigation Between Screens',
          'High',
          [
            'Navigate through all main screens',
            'Test back button functionality',
            'Check screen transitions',
          ],
          [
            'Smooth transitions',
            'Back button works correctly',
            'No screen freezes',
            'Consistent navigation patterns',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-UI-002',
          'Responsive Layout - Portrait/Landscape',
          'Medium',
          [
            'Rotate device between portrait and landscape',
            'Test on different screens',
          ],
          [
            'Layout adapts properly',
            'No UI elements cut off',
            'Text readable in both orientations',
            'Form fields accessible',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-UI-004',
          'Accessibility - Screen Reader',
          'Medium',
          [
            'Enable TalkBack/Screen Reader',
            'Navigate app',
          ],
          [
            'All buttons/fields have labels',
            'Navigation announced clearly',
            'Forms accessible',
            'Calculation results readable',
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Performance Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-PERF-001',
          'App Launch Time',
          'Medium',
          [
            'Close app completely',
            'Launch app and time until fully loaded',
          ],
          [
            'App launches within 3 seconds (cold start)',
            'Splash screen shows briefly',
            'Main screen loads smoothly',
            'No ANR (Application Not Responding)',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-PERF-002',
          'Calculation Speed',
          'High',
          [
            'Enter complex calculation (VAT with 20 supplies)',
            'Click Calculate',
            'Measure response time',
          ],
          [
            'Calculation completes within 500ms',
            'UI remains responsive',
            'Results display immediately',
            'No lag or freeze',
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Security Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-SEC-001',
          'Secure Storage of Sensitive Data',
          'High',
          [
            'Save user profile with TIN',
            'Check device storage',
          ],
          [
            'TIN stored in flutter_secure_storage',
            'Encrypted at rest',
            'Not accessible via file browser',
            'Proper key management',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-SEC-002',
          'Data Privacy - No Unauthorized Access',
          'High',
          [
            'Store tax calculations',
            'Attempt to access via external tools',
          ],
          [
            'Hive database encrypted/protected',
            'Data not readable externally',
            'No plain text sensitive info',
            'App sandbox respected',
          ],
        ),
      ],
    );
  }

  Widget _buildErrorHandlingTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Error Handling Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-ERROR-003',
          'Invalid Date Input',
          'Medium',
          [
            'In reminder, enter date in past',
            'Attempt to save',
          ],
          [
            'Validation error shown',
            'Message: "Date must be in the future"',
            'Reminder not created',
            'User prompted to correct',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-ERROR-005',
          'Concurrent Calculations',
          'Low',
          [
            'Rapidly switch between calculators',
            'Start calculations without completing previous',
          ],
          [
            'Each calculator maintains state',
            'No data mixing between types',
            'Results accurate for each',
            'No race conditions',
          ],
        ),
      ],
    );
  }

  Widget _buildCompatibilityTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Compatibility Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-COMPAT-001',
          'Android Version Compatibility',
          'High',
          [
            'Test on Android 10, 11, 12, 13, 14',
            'Verify all features work',
          ],
          [
            'App installs on all supported versions',
            'Features work consistently',
            'UI renders correctly',
            'No version-specific bugs',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-COMPAT-002',
          'Device Screen Size Compatibility',
          'High',
          [
            'Test on phones: 5", 6", 6.5"',
            'Test on tablets: 7", 10"',
          ],
          [
            'UI scales appropriately',
            'Touch targets adequate size',
            'Text readable on all sizes',
            'No overflow or clipping',
          ],
        ),
      ],
    );
  }

  Widget _buildPlayStoreTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Play Store Test Cases'),
        const SizedBox(height: 24),
        _buildTestCase(
          'TC-PS-001',
          'Install from Play Store (Internal Testing)',
          'High',
          [
            'Access internal testing link',
            'Install app from Play Store',
            'Launch app',
          ],
          [
            'Download completes successfully',
            'Installation smooth',
            'App launches without errors',
            'Version matches uploaded AAB',
          ],
        ),
        const SizedBox(height: 16),
        _buildTestCase(
          'TC-PS-002',
          'App Update Process',
          'Medium',
          [
            'Have v1.0.0 installed',
            'Upload v1.0.1 to Play Store',
            'Update app',
          ],
          [
            'Update notification received',
            'Update installs successfully',
            'Data preserved after update',
            'App works normally',
          ],
        ),
      ],
    );
  }

  // UI Helper Widgets

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.redAccent,
      ),
    );
  }

  Widget _buildTestCase(
    String id,
    String title,
    String priority,
    List<String> steps,
    List<String> expected,
  ) {
    Color priorityColor;
    switch (priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    _copyTestCase(id, title, priority, steps, expected);
                  },
                  tooltip: 'Copy test case',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Steps:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...steps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('${entry.key + 1}. ${entry.value}'),
                )),
            const SizedBox(height: 16),
            const Text(
              'Expected Result:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...expected.map((result) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✓ ', style: TextStyle(color: Colors.green)),
                      Expanded(child: Text(result)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.assessment, color: color, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageList(List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPhaseCard(
    String phase,
    String description,
    Color color,
    List<String> tasks,
  ) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: color),
                const SizedBox(width: 8),
                Text(
                  phase,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            ...tasks.map((task) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $task'),
                )),
          ],
        ),
      ),
    );
  }

  void _copyTestCase(
    String id,
    String title,
    String priority,
    List<String> steps,
    List<String> expected,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('$id: $title');
    buffer.writeln('Priority: $priority');
    buffer.writeln('\nTest Steps:');
    for (var i = 0; i < steps.length; i++) {
      buffer.writeln('${i + 1}. ${steps[i]}');
    }
    buffer.writeln('\nExpected Result:');
    for (var result in expected) {
      buffer.writeln('✓ $result');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test case copied to clipboard')),
    );
  }

  void _showFullDocumentationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full Test Documentation'),
        content: const SingleChildScrollView(
          child: Text(
            'Complete test documentation is available in:\n\n'
            'TEST_CASES.md\n\n'
            'This file contains all 70+ test cases with detailed steps, '
            'expected results, test data, and reporting templates.\n\n'
            'Location: /docs/TEST_CASES.md\n\n'
            'The document includes:\n'
            '• All functional test cases\n'
            '• Non-functional test cases\n'
            '• Test execution checklist\n'
            '• Bug report template\n'
            '• Test coverage summary',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTestChecklist() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Execution Checklist'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pre-Testing Setup:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildChecklistItem('Install latest AAB build'),
              _buildChecklistItem('Clear app data for fresh tests'),
              _buildChecklistItem('Prepare test devices (Android 10-14)'),
              _buildChecklistItem('Prepare test data (CSV, JSON samples)'),
              _buildChecklistItem('Setup test user profiles'),
              const SizedBox(height: 16),
              const Text(
                'Testing Environment:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildChecklistItem('Test on Wi-Fi and mobile data'),
              _buildChecklistItem('Test in various network conditions'),
              _buildChecklistItem('Test with different battery levels'),
              _buildChecklistItem('Test with storage nearly full'),
              const SizedBox(height: 16),
              const Text(
                'Post-Testing:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildChecklistItem('Document all defects found'),
              _buildChecklistItem('Create bug reports with screenshots'),
              _buildChecklistItem('Verify fixes in next build'),
              _buildChecklistItem('Update test cases based on findings'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
