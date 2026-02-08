import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/pit/data/pit_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';
import 'package:taxng_advisor/widgets/supporting_documents_widget.dart';
import 'package:taxng_advisor/models/calculation_attachment.dart';
import 'package:taxng_advisor/services/validation_service.dart';
import 'package:taxng_advisor/services/error_recovery_service.dart';
import 'package:taxng_advisor/widgets/validated_text_field.dart';
import 'package:taxng_advisor/widgets/template_action_buttons.dart';
import 'package:taxng_advisor/widgets/quick_import_button.dart';
import 'package:taxng_advisor/widgets/calculation_info_item.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';

/// PIT Calculator Screen
class PitCalculatorScreen extends StatefulWidget {
  const PitCalculatorScreen({super.key});

  @override
  State<PitCalculatorScreen> createState() => _PitCalculatorScreenState();
}

class _PitCalculatorScreenState extends State<PitCalculatorScreen>
    with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _grossIncomeController = TextEditingController(text: '5000000');
  final _otherDeductionsController = TextEditingController(text: '200000');
  final _annualRentPaidController = TextEditingController(text: '1200000');

  PitResult? result;
  bool _showResults = false;
  final List<CalculationAttachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    // Register validation rules
    ValidationService.registerRules('PIT', ValidationService.getPITRules());

    // Handle imported data from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null &&
          (args['grossIncome'] != null ||
              args['otherDeductions'] != null ||
              args['annualRentPaid'] != null)) {
        if (args['grossIncome'] != null) {
          _grossIncomeController.text = (args['grossIncome'] as num).toString();
        }
        if (args['otherDeductions'] != null) {
          _otherDeductionsController.text =
              (args['otherDeductions'] as num).toString();
        }
        if (args['annualRentPaid'] != null) {
          _annualRentPaidController.text =
              (args['annualRentPaid'] as num).toString();
        }
        _calculatePIT();
      } else {
        _calculateWithDummyData();
      }
    });
  }

  void _handleImportedData(Map<String, dynamic> data) {
    setState(() {
      if (data['grossIncome'] != null) {
        _grossIncomeController.text = data['grossIncome'].toString();
      }
      if (data['otherDeductions'] != null) {
        _otherDeductionsController.text = data['otherDeductions'].toString();
      }
      if (data['annualRentPaid'] != null) {
        _annualRentPaidController.text = data['annualRentPaid'].toString();
      }
    });

    // Automatically calculate after import
    Future.delayed(const Duration(milliseconds: 300), () {
      _calculatePIT();
    });
  }

  void _calculateWithDummyData() {
    result = PitCalculator.calculate(
      grossIncome: 5000000,
      otherDeductions: [200000],
      annualRentPaid: 1200000,
    );
  }

  void _calculatePIT() async {
    final data = {
      'grossIncome': double.tryParse(_grossIncomeController.text) ?? 0,
      'otherDeductions': double.tryParse(_otherDeductionsController.text) ?? 0,
      'annualRentPaid': double.tryParse(_annualRentPaidController.text) ?? 0,
    };

    // Validate before calculating
    if (!await canSubmit('PIT', data)) {
      return;
    }

    final result = await ErrorRecoveryService.withErrorHandling(
      context,
      () async {
        final grossIncome = data['grossIncome']!;
        final otherDeductions = data['otherDeductions']!;
        final annualRentPaid = data['annualRentPaid']!;

        return PitCalculator.calculate(
          grossIncome: grossIncome,
          otherDeductions: otherDeductions > 0 ? [otherDeductions] : [],
          annualRentPaid: annualRentPaid,
        );
      },
      operationName: 'PIT Calculation',
      expectedErrorType: ErrorType.calculation,
      onRetry: () => _calculatePIT(),
    );

    if (result != null) {
      setState(() {
        this.result = result;
        _showResults = true;
      });
      ErrorRecoveryService.showSuccess(
        context,
        '✅ PIT calculated successfully',
      );
    }
  }

  @override
  void dispose() {
    _grossIncomeController.dispose();
    _otherDeductionsController.dispose();
    _annualRentPaidController.dispose();
    super.dispose();
  }

  Future<void> _showPaymentDialog(BuildContext context) async {
    final user = await AuthService.currentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    final controller = TextEditingController(
        text: result?.totalTax.toStringAsFixed(2) ?? '0.00');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (₦)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed == true) {
      final amt = double.tryParse(controller.text) ?? result?.totalTax ?? 0.0;

      // Process currency conversion for oil & gas sector
      final paymentData = await PaymentService.processPaymentCurrency(
        userId: user.id,
        amount: amt,
        currency: 'NGN',
      );

      await PaymentService.savePayment(
        userId: user.id,
        taxType: 'PIT',
        amount: paymentData['amount'],
        email: user.email,
        currency: paymentData['currency'],
        originalCurrency: paymentData['originalCurrency'],
        originalAmount: paymentData['originalAmount'],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded and confirmation sent')),
      );
    }
  }

  Future<void> _openPaymentGateway(BuildContext context) async {
    if (result == null) return;
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          taxType: 'PIT',
          taxAmount: result!.totalTax,
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
      appBar: TaxNGAppBar(
        title: 'PIT Calculator',
        additionalActions: [
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
        calculatorType: 'PIT',
        onDataImported: _handleImportedData,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Income Tax (PIT) 2025',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your personal income details',
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
                      '1. Gross Annual Income: Enter your total annual income from employment or business.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2. Other Deductions: Enter additional allowable deductions beyond standard relief.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3. Annual Rent Paid: Enter your annual rent to claim rent relief (20% up to ₦500K cap).',
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
                              'Tip: PIT uses progressive tax bands. Automatic deductions include Pension (8%) and NHF (2.5%).',
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
                        'Income Information',
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
                              controller: _grossIncomeController,
                              label: 'Gross Annual Income',
                              fieldName: 'grossIncome',
                              calculatorKey: 'PIT',
                              getFormData: () => {
                                'grossIncome': double.tryParse(
                                        _grossIncomeController.text) ??
                                    0,
                                'otherDeductions': double.tryParse(
                                        _otherDeductionsController.text) ??
                                    0,
                                'annualRentPaid': double.tryParse(
                                        _annualRentPaidController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 5000000',
                              suffix: const Icon(Icons.account_balance_wallet,
                                  size: 20),
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
                                  title: const Text('Gross Annual Income'),
                                  content: const Text(
                                    'Total income from employment, business, or professional practice before any deductions. Include salaries, bonuses, allowances, and other taxable income.',
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
                              calculatorKey: 'PIT',
                              getFormData: () => {
                                'grossIncome': double.tryParse(
                                        _grossIncomeController.text) ??
                                    0,
                                'otherDeductions': double.tryParse(
                                        _otherDeductionsController.text) ??
                                    0,
                                'annualRentPaid': double.tryParse(
                                        _annualRentPaidController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 200000',
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
                                    'Additional allowable deductions beyond standard relief. These are specific expenses you can deduct to reduce your chargeable income.',
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
                              controller: _annualRentPaidController,
                              label: 'Annual Rent Paid',
                              fieldName: 'annualRentPaid',
                              calculatorKey: 'PIT',
                              getFormData: () => {
                                'grossIncome': double.tryParse(
                                        _grossIncomeController.text) ??
                                    0,
                                'otherDeductions': double.tryParse(
                                        _otherDeductionsController.text) ??
                                    0,
                                'annualRentPaid': double.tryParse(
                                        _annualRentPaidController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 1200000',
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
                                  title: const Text('Annual Rent Paid'),
                                  content: const Text(
                                    'Total annual rent paid for your primary residence. You can claim 20% of rent as relief, capped at ₦500,000. If your rent is ₦2.5M or more, the maximum relief is ₦500K.',
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
                        onPressed: _calculatePIT,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate PIT'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TemplateActionButtons(
                        taxType: 'PIT',
                        currentData: {
                          'grossIncome':
                              double.tryParse(_grossIncomeController.text) ?? 0,
                          'otherDeductions': double.tryParse(
                                  _otherDeductionsController.text) ??
                              0,
                          'annualRentPaid':
                              double.tryParse(_annualRentPaidController.text) ??
                                  0,
                        },
                        onTemplateLoaded: (data) {
                          setState(() {
                            _grossIncomeController.text =
                                (data['grossIncome'] ?? 0).toString();
                            _otherDeductionsController.text =
                                (data['otherDeductions'] ?? 0).toString();
                            _annualRentPaidController.text =
                                (data['annualRentPaid'] ?? 0).toString();
                          });
                          _calculatePIT();
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
              CalculationInfoItem(
                label: 'Gross Annual Income',
                value: CurrencyFormatter.formatCurrency(result!.grossIncome),
                explanation:
                    'Gross Annual Income is your total income from employment or business before any deductions.',
                howCalculated:
                    'This is the amount you entered. It includes salaries, bonuses, allowances, and other taxable income.',
                why:
                    'Starting point for calculating PIT. All deductions and reliefs are applied against this amount.',
                icon: Icons.account_balance_wallet,
              ),
              CalculationInfoItem(
                label: 'Total Deductions',
                value:
                    CurrencyFormatter.formatCurrency(result!.totalDeductions),
                explanation:
                    'Total Deductions include Pension (8%), NHF (2.5%), Rent Relief (20% of rent up to ₦500K), and other deductions.',
                howCalculated:
                    'Pension: ${CurrencyFormatter.formatCurrency(result!.grossIncome * 0.08)}, NHF: ${CurrencyFormatter.formatCurrency(result!.grossIncome * 0.025)}, Rent Relief: ${CurrencyFormatter.formatCurrency(result!.rentRelief)}, Other: ${CurrencyFormatter.formatCurrency(result!.totalDeductions - (result!.grossIncome * 0.105) - result!.rentRelief)}',
                why:
                    'These deductions reduce your taxable income, lowering your overall tax burden.',
                icon: Icons.remove_circle,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              CalculationInfoItem(
                label: 'Chargeable Income',
                value:
                    CurrencyFormatter.formatCurrency(result!.chargeableIncome),
                explanation:
                    'Chargeable Income is your gross income minus all allowable deductions. This is the amount on which PIT is calculated.',
                howCalculated:
                    'Gross Income (${CurrencyFormatter.formatCurrency(result!.grossIncome)}) - Total Deductions (${CurrencyFormatter.formatCurrency(result!.totalDeductions)}) = ${CurrencyFormatter.formatCurrency(result!.chargeableIncome)}',
                why:
                    'Progressive tax bands are applied to this amount to calculate your final PIT liability.',
                icon: Icons.assessment,
                isHighlight: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tax by Progressive Bands:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...result!.breakdown.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 13)),
                        Text(
                          CurrencyFormatter.formatCurrency(entry.value),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              CalculationInfoItem(
                label: 'Total PIT Payable',
                value: CurrencyFormatter.formatCurrency(result!.totalTax),
                explanation:
                    'Total PIT Payable is the sum of tax calculated across all progressive tax bands.',
                howCalculated:
                    'Sum of all band calculations: ${result!.breakdown.entries.map((e) => '${e.key}: ${CurrencyFormatter.formatCurrency(e.value)}').join(', ')}',
                why:
                    'This is your final tax liability for the year. It must be paid to avoid penalties.',
                icon: Icons.payment,
                color: Colors.red,
                isHighlight: true,
              ),
              CalculationInfoItem(
                label: 'Effective Tax Rate',
                value:
                    CurrencyFormatter.formatPercentage(result!.effectiveRate),
                explanation:
                    'Effective Tax Rate shows the percentage of your gross income paid as tax.',
                howCalculated:
                    '(Total PIT / Gross Income) × 100 = (${CurrencyFormatter.formatCurrency(result!.totalTax)} / ${CurrencyFormatter.formatCurrency(result!.grossIncome)}) × 100',
                why:
                    'Helps understand your real tax burden relative to your income.',
                icon: Icons.analytics,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showPaymentDialog(context),
                    icon: const Icon(Icons.payment),
                    label: const Text('Record Payment'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openPaymentGateway(context),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Pay Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            SupportingDocumentsWidget(
              attachments: _attachments,
              onDocumentAdded: (doc) {
                setState(() {
                  _attachments.add(doc);
                });
              },
              onDocumentRemoved: (doc) {
                setState(() {
                  _attachments.remove(doc);
                });
              },
              calculationId: null, // Will save when calculation is saved
            ),
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
