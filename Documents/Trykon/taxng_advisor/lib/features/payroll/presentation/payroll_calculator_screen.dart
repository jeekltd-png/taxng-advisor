import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/payroll/data/payroll_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';
import 'package:taxng_advisor/services/validation_service.dart';
import 'package:taxng_advisor/services/error_recovery_service.dart';
import 'package:taxng_advisor/widgets/validated_text_field.dart';
import 'package:taxng_advisor/widgets/template_action_buttons.dart';
import 'package:taxng_advisor/widgets/quick_import_button.dart';
import 'package:taxng_advisor/widgets/calculation_info_item.dart';

/// Payroll Calculator Screen
class PayrollCalculatorScreen extends StatefulWidget {
  const PayrollCalculatorScreen({super.key});

  @override
  State<PayrollCalculatorScreen> createState() =>
      _PayrollCalculatorScreenState();
}

class _PayrollCalculatorScreenState extends State<PayrollCalculatorScreen>
    with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _monthlyGrossController = TextEditingController(text: '250000');
  final _pensionRateController = TextEditingController(text: '8');
  final _nhfRateController = TextEditingController(text: '2.5');
  final _otherDeductionsController = TextEditingController(text: '5000');

  PayrollResult? result;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    // Register validation rules
    ValidationService.registerRules(
        'Payroll', ValidationService.getPAYERules());

    // Handle imported data from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null &&
          (args['monthlyGross'] != null ||
              args['pensionRate'] != null ||
              args['nhfRate'] != null ||
              args['otherDeductions'] != null)) {
        if (args['monthlyGross'] != null) {
          _monthlyGrossController.text =
              (args['monthlyGross'] as num).toString();
        }
        if (args['pensionRate'] != null) {
          _pensionRateController.text = (args['pensionRate'] as num).toString();
        }
        if (args['nhfRate'] != null) {
          _nhfRateController.text = (args['nhfRate'] as num).toString();
        }
        if (args['otherDeductions'] != null) {
          _otherDeductionsController.text =
              (args['otherDeductions'] as num).toString();
        }
        _calculatePayroll();
      } else {
        _calculateWithDummyData();
      }
    });
  }

  void _handleImportedData(Map<String, dynamic> data) {
    setState(() {
      if (data['monthlyGross'] != null) {
        _monthlyGrossController.text = data['monthlyGross'].toString();
      }
      if (data['pensionRate'] != null) {
        _pensionRateController.text = data['pensionRate'].toString();
      }
      if (data['nhfRate'] != null) {
        _nhfRateController.text = data['nhfRate'].toString();
      }
      if (data['otherDeductions'] != null) {
        _otherDeductionsController.text = data['otherDeductions'].toString();
      }
    });

    // Automatically calculate after import
    Future.delayed(const Duration(milliseconds: 300), () {
      _calculatePayroll();
    });
  }

  void _calculateWithDummyData() {
    result = PayrollCalculator.calculateWithDeductions(
      monthlyGross: 250000,
      pensionRate: 0.08,
      nhfRate: 0.02,
      otherDeductions: 5000,
    );
  }

  void _calculatePayroll() async {
    final data = {
      'monthlyGross': double.tryParse(_monthlyGrossController.text) ?? 0,
      'pensionRate': (double.tryParse(_pensionRateController.text) ?? 8) / 100,
      'nhfRate': (double.tryParse(_nhfRateController.text) ?? 2.5) / 100,
      'otherDeductions': double.tryParse(_otherDeductionsController.text) ?? 0,
    };

    // Validate before calculating
    if (!await canSubmit('Payroll', data)) {
      return;
    }

    final result = await ErrorRecoveryService.withErrorHandling(
      context,
      () async {
        final monthlyGross = data['monthlyGross']!;
        final pensionRate = data['pensionRate']!;
        final nhfRate = data['nhfRate']!;
        final otherDeductions = data['otherDeductions']!;

        return PayrollCalculator.calculateWithDeductions(
          monthlyGross: monthlyGross,
          pensionRate: pensionRate,
          nhfRate: nhfRate,
          otherDeductions: otherDeductions,
        );
      },
      operationName: 'Payroll Calculation',
      expectedErrorType: ErrorType.calculation,
      onRetry: () => _calculatePayroll(),
    );

    if (result != null) {
      setState(() {
        this.result = result;
        _showResults = true;
      });
      ErrorRecoveryService.showSuccess(
        context,
        '✅ Payroll calculated successfully',
      );
    }
  }

  @override
  void dispose() {
    _monthlyGrossController.dispose();
    _pensionRateController.dispose();
    _nhfRateController.dispose();
    _otherDeductionsController.dispose();
    super.dispose();
  }

  Future<void> _showPaymentDialog(BuildContext context) async {
    if (result == null) return;
    final user = await AuthService.currentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    final taxAmount = result!.monthlyPaye;
    final controller =
        TextEditingController(text: taxAmount.toStringAsFixed(2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payroll Payment'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (₦)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final amt = double.tryParse(controller.text) ?? taxAmount;

      // Process currency conversion for oil & gas sector
      final paymentData = await PaymentService.processPaymentCurrency(
        userId: user.id,
        amount: amt,
        currency: 'NGN',
      );

      await PaymentService.savePayment(
        userId: user.id,
        taxType: 'Payroll',
        amount: paymentData['amount'],
        email: user.email,
        currency: paymentData['currency'],
        originalCurrency: paymentData['originalCurrency'],
        originalAmount: paymentData['originalAmount'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Payment recorded and confirmation sent')),
        );
      }
    }
  }

  Future<void> _openPaymentGateway(BuildContext context) async {
    if (result == null) return;
    final taxAmount = result!.monthlyPaye;
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          taxType: 'Payroll',
          taxAmount: taxAmount,
          currency: 'NGN',
        ),
      ),
    );

    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Payment completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icon.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 8),
            const Text('Payroll Calculator'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Quick Import Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.upload_file, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Quick Import'),
                    ],
                  ),
                  content: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import data quickly using the blue Import button at the bottom.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text('You can:'),
                        SizedBox(height: 8),
                        Text('• Upload CSV or JSON files'),
                        Text('• Copy-paste data directly'),
                        Text('• View sample formats for guidance'),
                        SizedBox(height: 12),
                        Text(
                          'Data will automatically fill the form and calculate!',
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: QuickImportButton(
        calculatorType: 'Payroll',
        onDataImported: _handleImportedData,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payroll Calculator 2025',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Calculate PAYE and net salary',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Information Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'How to Use',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Monthly Gross Salary: Enter the total monthly salary before deductions.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2. Pension Rate: Employee contribution rate (default 8%, employer pays 10%).',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3. NHF Rate: National Housing Fund contribution (default 2.5%).',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '4. Other Deductions: Additional deductions like union dues or loans.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[700]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: Colors.amber[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: PAYE uses progressive tax bands. Pension and NHF are deducted before tax calculation.',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.amber[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Input Form Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Salary Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _monthlyGrossController,
                              label: 'Monthly Gross Salary',
                              fieldName: 'monthlyGross',
                              calculatorKey: 'Payroll',
                              getFormData: () => {
                                'monthlyGross': double.tryParse(
                                        _monthlyGrossController.text) ??
                                    0,
                                'pensionRate': (double.tryParse(
                                            _pensionRateController.text) ??
                                        8) /
                                    100,
                                'nhfRate':
                                    (double.tryParse(_nhfRateController.text) ??
                                            2.5) /
                                        100,
                                'otherDeductions': double.tryParse(
                                        _otherDeductionsController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 250000',
                              suffix: const Icon(Icons.attach_money, size: 20),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: Colors.blue),
                            tooltip: 'Learn more',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Monthly Gross Salary'),
                                  content: const Text(
                                    'Total monthly salary before any deductions. This includes basic salary, allowances, bonuses, and other taxable income.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _pensionRateController,
                              label: 'Pension Rate (%)',
                              fieldName: 'pensionRate',
                              calculatorKey: 'Payroll',
                              getFormData: () => {
                                'monthlyGross': double.tryParse(
                                        _monthlyGrossController.text) ??
                                    0,
                                'pensionRate': (double.tryParse(
                                            _pensionRateController.text) ??
                                        8) /
                                    100,
                                'nhfRate':
                                    (double.tryParse(_nhfRateController.text) ??
                                            2.5) /
                                        100,
                                'otherDeductions': double.tryParse(
                                        _otherDeductionsController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              suffixText: '%',
                              hintText: 'e.g., 8',
                              suffix: const Icon(Icons.savings, size: 20),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: Colors.blue),
                            tooltip: 'Learn more',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Pension Rate'),
                                  content: const Text(
                                    'Employee pension contribution rate (typically 8%). Note: Employers also contribute 10%, but this calculator focuses on employee deductions only.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _nhfRateController,
                              label: 'NHF Rate (%)',
                              fieldName: 'nhfRate',
                              calculatorKey: 'Payroll',
                              getFormData: () => {
                                'monthlyGross': double.tryParse(
                                        _monthlyGrossController.text) ??
                                    0,
                                'pensionRate': (double.tryParse(
                                            _pensionRateController.text) ??
                                        8) /
                                    100,
                                'nhfRate':
                                    (double.tryParse(_nhfRateController.text) ??
                                            2.5) /
                                        100,
                                'otherDeductions': double.tryParse(
                                        _otherDeductionsController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              suffixText: '%',
                              hintText: 'e.g., 2.5',
                              suffix: const Icon(Icons.home, size: 20),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: Colors.blue),
                            tooltip: 'Learn more',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('NHF Rate'),
                                  content: const Text(
                                    'National Housing Fund (NHF) contribution rate (typically 2.5%). This supports affordable housing access and may provide mortgage benefits.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _otherDeductionsController,
                              label: 'Other Deductions',
                              fieldName: 'otherDeductions',
                              calculatorKey: 'Payroll',
                              getFormData: () => {
                                'monthlyGross': double.tryParse(
                                        _monthlyGrossController.text) ??
                                    0,
                                'pensionRate': (double.tryParse(
                                            _pensionRateController.text) ??
                                        8) /
                                    100,
                                'nhfRate':
                                    (double.tryParse(_nhfRateController.text) ??
                                            2.5) /
                                        100,
                                'otherDeductions': double.tryParse(
                                        _otherDeductionsController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 5000',
                              suffix: const Icon(Icons.remove_circle, size: 20),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: Colors.blue),
                            tooltip: 'Learn more',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Other Deductions'),
                                  content: const Text(
                                    'Additional monthly deductions such as union dues, loan repayments, insurance premiums, or other authorized deductions.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _calculatePayroll,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate Payroll'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TemplateActionButtons(
                        taxType: 'Payroll',
                        currentData: {
                          'monthlyGross':
                              double.tryParse(_monthlyGrossController.text) ??
                                  0,
                          'pensionRate':
                              (double.tryParse(_pensionRateController.text) ??
                                      8) /
                                  100,
                          'nhfRate':
                              (double.tryParse(_nhfRateController.text) ??
                                      2.5) /
                                  100,
                          'otherDeductions': double.tryParse(
                                  _otherDeductionsController.text) ??
                              0,
                        },
                        onTemplateLoaded: (data) {
                          setState(() {
                            _monthlyGrossController.text =
                                (data['monthlyGross'] ?? 0).toString();
                            _pensionRateController.text =
                                ((data['pensionRate'] ?? 0.08) * 100)
                                    .toString();
                            _nhfRateController.text =
                                ((data['nhfRate'] ?? 0.025) * 100).toString();
                            _otherDeductionsController.text =
                                (data['otherDeductions'] ?? 0).toString();
                          });
                          _calculatePayroll();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Results Section
            if (_showResults && result != null) ...[
              const Text(
                'Calculation Results',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Monthly Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              CalculationInfoItem(
                label: 'Monthly Gross Salary',
                value: CurrencyFormatter.formatCurrency(result!.monthlyGross),
                explanation:
                    'Monthly Gross Salary is your total salary before any deductions.',
                howCalculated:
                    'This is the amount you entered as your monthly gross salary.',
                why:
                    'Starting point for payroll calculation. All deductions and taxes are calculated from this amount.',
                icon: Icons.attach_money,
              ),
              CalculationInfoItem(
                label: 'Monthly PAYE Tax',
                value: CurrencyFormatter.formatCurrency(result!.monthlyPaye),
                explanation:
                    'Monthly PAYE (Pay As You Earn) is the income tax deducted from your monthly salary.',
                howCalculated:
                    'Calculated using progressive tax bands after deducting pension, NHF, and relief allowances from gross salary.',
                why:
                    'This is your monthly tax obligation that must be remitted to tax authorities.',
                icon: Icons.payment,
                color: Colors.red,
                isHighlight: true,
              ),
              CalculationInfoItem(
                label: 'Monthly Net Pay',
                value: CurrencyFormatter.formatCurrency(result!.monthlyNet),
                explanation:
                    'Monthly Net Pay is your take-home salary after all deductions (PAYE, pension, NHF, and other deductions).',
                howCalculated:
                    'Gross Salary - (PAYE + Pension + NHF + Other Deductions)',
                why:
                    'This is the actual amount you receive in your account each month.',
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Annual Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              CalculationInfoItem(
                label: 'Annual Gross Salary',
                value: CurrencyFormatter.formatCurrency(result!.annualGross),
                explanation:
                    'Annual Gross Salary is your total salary for the year (Monthly Gross × 12).',
                howCalculated:
                    '${CurrencyFormatter.formatCurrency(result!.monthlyGross)} × 12 = ${CurrencyFormatter.formatCurrency(result!.annualGross)}',
                why:
                    'Used for annual tax planning and comparison with tax brackets.',
                icon: Icons.calendar_today,
              ),
              CalculationInfoItem(
                label: 'Annual PAYE Tax',
                value: CurrencyFormatter.formatCurrency(result!.annualPaye),
                explanation:
                    'Annual PAYE is your total income tax for the year (Monthly PAYE × 12).',
                howCalculated:
                    '${CurrencyFormatter.formatCurrency(result!.monthlyPaye)} × 12 = ${CurrencyFormatter.formatCurrency(result!.annualPaye)}',
                why:
                    'Your total annual tax liability. Useful for tax planning and reporting.',
                icon: Icons.receipt_long,
                color: Colors.red,
                isHighlight: true,
              ),
              CalculationInfoItem(
                label: 'Annual Net Pay',
                value: CurrencyFormatter.formatCurrency(result!.annualNet),
                explanation:
                    'Annual Net Pay is your total take-home pay for the year (Monthly Net × 12).',
                howCalculated:
                    '${CurrencyFormatter.formatCurrency(result!.monthlyNet)} × 12 = ${CurrencyFormatter.formatCurrency(result!.annualNet)}',
                why:
                    'Your actual annual income after all taxes and deductions.',
                icon: Icons.savings,
                color: Colors.green,
              ),
              CalculationInfoItem(
                label: 'Effective Tax Rate',
                value: CurrencyFormatter.formatPercentage(
                    result!.effectiveAnnualRate),
                explanation:
                    'Effective Tax Rate shows the percentage of your gross income paid as PAYE tax.',
                howCalculated:
                    '(Annual PAYE / Annual Gross) × 100 = (${CurrencyFormatter.formatCurrency(result!.annualPaye)} / ${CurrencyFormatter.formatCurrency(result!.annualGross)}) × 100',
                why:
                    'Helps understand your real tax burden relative to your income.',
                icon: Icons.analytics,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showPaymentDialog(context),
                      icon: const Icon(Icons.receipt),
                      label: const Text('Record Payment'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openPaymentGateway(context),
                      icon: const Icon(Icons.payment),
                      label: const Text('Pay Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Back to Dashboard'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
