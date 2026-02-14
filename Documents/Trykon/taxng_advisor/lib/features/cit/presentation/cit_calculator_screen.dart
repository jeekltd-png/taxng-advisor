import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/cit/data/cit_calculator.dart';
import 'package:taxng_advisor/features/cit/services/cit_storage_service.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/services/validation_service.dart';
import 'package:taxng_advisor/services/error_recovery_service.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';
import 'package:taxng_advisor/widgets/validated_text_field.dart';
import 'package:taxng_advisor/widgets/supporting_documents_widget.dart';
import 'package:taxng_advisor/models/calculation_attachment.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';
import 'package:taxng_advisor/services/user_activity_tracker.dart';
import 'package:taxng_advisor/widgets/free_plan_banner.dart';
import 'package:taxng_advisor/widgets/free_usage_gate_mixin.dart';
import 'package:taxng_advisor/widgets/quick_import_button.dart';
import 'package:taxng_advisor/widgets/template_action_buttons.dart';
import 'package:taxng_advisor/widgets/form_guidance.dart';
import 'package:taxng_advisor/services/hive_service.dart';
import 'package:taxng_advisor/services/sync_service.dart';

/// CIT Calculator Screen with Input and Results
class CitCalculatorScreen extends StatefulWidget {
  const CitCalculatorScreen({super.key});

  @override
  State<CitCalculatorScreen> createState() => _CitCalculatorScreenState();
}

class _CitCalculatorScreenState extends State<CitCalculatorScreen>
    with FormValidationMixin, FreeUsageGateMixin {
  final _formKey = GlobalKey<FormState>();
  final _turnoverController = TextEditingController();
  final _profitController = TextEditingController();

  CitResult? result;
  bool _showResults = false;
  bool _isExampleData = true;
  final List<CalculationAttachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    // Register validation rules
    ValidationService.registerRules('CIT', ValidationService.getCITRules());

    // Mark as real data when user edits any field
    for (final c in [_turnoverController, _profitController]) {
      c.addListener(() {
        if (_isExampleData && c.text.isNotEmpty) _isExampleData = false;
      });
    }

    // If opened with route arguments (imported data), prefill and calculate.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null &&
          (args['turnover'] != null || args['profit'] != null)) {
        _isExampleData = false;
        if (args['turnover'] != null) {
          _turnoverController.text = (args['turnover'] as num).toString();
        }
        if (args['profit'] != null) {
          _profitController.text = (args['profit'] as num).toString();
        }
        _calculateCIT();
      } else {
        _calculateWithDummyData();
      }
    });
  }

  void _handleImportedData(Map<String, dynamic> data) {
    _isExampleData = false;
    setState(() {
      if (data['turnover'] != null) {
        _turnoverController.text = data['turnover'].toString();
      }
      if (data['profit'] != null) {
        _profitController.text = data['profit'].toString();
      }
    });
    Future.delayed(const Duration(milliseconds: 300), _calculateCIT);
  }

  void _calculateWithDummyData() {
    // Calculate with default (empty) controller values
    _calculateCIT();
  }

  void _calculateCIT() async {
    final data = {
      'turnover': double.tryParse(_turnoverController.text) ?? 0,
      'profit': double.tryParse(_profitController.text) ?? 0,
    };

    // Validate before calculating
    if (!await canSubmit('CIT', data)) {
      return;
    }

    // Free-tier usage gate
    if (!await checkFreeUsageAndProceed('CIT', isExampleData: _isExampleData)) {
      return;
    }

    final calcResult = await ErrorRecoveryService.withErrorHandling(
      context,
      () async {
        final turnover = data['turnover']!;
        final profit = data['profit']!;

        return CitCalculator.calculate(
          turnover: turnover,
          profit: profit,
        );
      },
      operationName: 'CIT Calculation',
      expectedErrorType: ErrorType.calculation,
      onRetry: () => _calculateCIT(),
    );

    if (calcResult != null) {
      setState(() {
        result = calcResult;
        _showResults = true;
      });

      // Save to local storage (legacy service)
      CitStorageService.saveEstimate(result!);
      HiveService.saveCIT(result!.toMap());

      ErrorRecoveryService.showSuccess(
        context,
        '✅ CIT calculated successfully',
      );

      // Track calculator usage for admin analytics
      UserActivityTracker.trackCalculatorUse('cit',
          details: 'Turnover: ${data['turnover']}, Profit: ${data['profit']}');

      _showSyncStatus();
    }
  }

  Future<void> _showSyncStatus() async {
    final isOnline = await SyncService.isOnline();
    final message = isOnline
        ? '✅ Saved and syncing to server...'
        : '💾 Saved offline - will sync when online';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _turnoverController.dispose();
    _profitController.dispose();
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

    final controller =
        TextEditingController(text: result!.taxPayable.toStringAsFixed(2));
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
      final amt = double.tryParse(controller.text) ?? result!.taxPayable;

      // Process currency conversion for oil & gas sector
      final paymentData = await PaymentService.processPaymentCurrency(
        userId: user.id,
        amount: amt,
        currency: 'NGN',
      );

      await PaymentService.savePayment(
        userId: user.id,
        taxType: 'CIT',
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
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          taxType: 'CIT',
          taxAmount: result!.taxPayable,
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
      appBar: const TaxNGAppBar(title: 'CIT Calculator'),
      floatingActionButton: QuickImportButton(
        calculatorType: 'CIT',
        onDataImported: _handleImportedData,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FreePlanBanner(calculatorType: 'CIT'),
            Text(
              'Corporate Income Tax (CIT) ${DateTime.now().year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your business financial details',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Step-by-step progress guide
            FormStepGuide(
              calculatorType: 'CIT',
              currentStep: _turnoverController.text.isEmpty
                  ? 0
                  : _profitController.text.isEmpty
                      ? 1
                      : 2,
              totalSteps: 3,
            ),

            // Information Card
            Card(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
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
                      '1. Annual Business Turnover: Enter your company\'s total annual revenue.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2. Chargeable Profit: Enter the taxable profit after allowable deductions.',
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
                              'Tip: CIT rate depends on company size — Small (≤₦25M turnover): 0%, Medium (₦25M–₦100M): 20%, Large (>₦100M): 30%.',
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
                        'Financial Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormFieldGuide(
                        calculatorType: 'CIT',
                        fieldName: 'turnover',
                        child: ValidatedTextField(
                          controller: _turnoverController,
                          label: 'Annual Business Turnover (₦)',
                          fieldName: 'turnover',
                          calculatorKey: 'CIT',
                          getFormData: () => {
                            'turnover':
                                double.tryParse(_turnoverController.text) ?? 0,
                            'profit':
                                double.tryParse(_profitController.text) ?? 0,
                          },
                          keyboardType: TextInputType.number,
                          hintText: 'e.g., 75000000',
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormFieldGuide(
                        calculatorType: 'CIT',
                        fieldName: 'profit',
                        child: ValidatedTextField(
                          controller: _profitController,
                          label: 'Chargeable Profit (₦)',
                          fieldName: 'profit',
                          calculatorKey: 'CIT',
                          getFormData: () => {
                            'turnover':
                                double.tryParse(_turnoverController.text) ?? 0,
                            'profit':
                                double.tryParse(_profitController.text) ?? 0,
                          },
                          keyboardType: TextInputType.number,
                          hintText: 'e.g., 15000000',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _calculateCIT,
                              icon: const Icon(Icons.calculate),
                              label: const Text('Calculate CIT'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TemplateActionButtons(
                        taxType: 'CIT',
                        currentData: {
                          'turnover':
                              double.tryParse(_turnoverController.text) ?? 0,
                          'profit':
                              double.tryParse(_profitController.text) ?? 0,
                        },
                        onTemplateLoaded: (data) {
                          setState(() {
                            _turnoverController.text =
                                (data['turnover'] ?? 0).toString();
                            _profitController.text =
                                (data['profit'] ?? 0).toString();
                          });
                          _calculateCIT();
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
              _ResultCard(
                label: 'Business Turnover',
                value: CurrencyFormatter.formatCurrency(result!.turnover),
              ),
              _ResultCard(
                label: 'Chargeable Profit',
                value: CurrencyFormatter.formatCurrency(result!.profit),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _ResultCard(
                label: 'Business Category',
                value: result!.category,
                isHighlight: true,
              ),
              _ResultCard(
                label: 'Tax Rate',
                value: CurrencyFormatter.formatPercentage(result!.rate),
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _ResultCard(
                label: 'CIT Payable',
                value: CurrencyFormatter.formatCurrency(result!.taxPayable),
                color: Colors.red,
                isBold: true,
                isHighlight: true,
              ),
              _ResultCard(
                label: 'Effective Tax Rate',
                value:
                    CurrencyFormatter.formatPercentage(result!.effectiveRate),
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Business Category: ${result!.category}\nCIT rate applied: ${CurrencyFormatter.formatPercentage(result!.rate)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showPaymentDialog(context),
                      icon: const Icon(Icons.payment),
                      label: const Text('Record Payment'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openPaymentGateway(context),
                      icon: const Icon(Icons.shopping_cart),
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
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isHighlight;
  final bool isBold;

  const _ResultCard({
    required this.label,
    required this.value,
    this.color,
    this.isHighlight = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: isHighlight ? const Color(0xFFDBEFDC) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              value,
              style: TextStyle(
                fontSize: isBold ? 16 : 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
