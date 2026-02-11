import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/stamp_duty/data/stamp_duty_calculator.dart';
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
import 'package:taxng_advisor/widgets/supporting_documents_widget.dart';
import 'package:taxng_advisor/models/calculation_attachment.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';

/// Stamp Duty Screen
class StampDutyScreen extends StatefulWidget {
  const StampDutyScreen({super.key});

  @override
  State<StampDutyScreen> createState() => _StampDutyScreenState();
}

class _StampDutyScreenState extends State<StampDutyScreen>
    with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  StampDutyType _selectedType = StampDutyType.sale;
  StampDutyResult? result;
  bool _showResults = false;
  final List<CalculationAttachment> _attachments = [];

  final Map<StampDutyType, String> _stampDutyTypeLabels = {
    StampDutyType.electronicTransfer: 'Electronic Transfer (0.15%)',
    StampDutyType.cheque: 'Cheque (₦20 flat)',
    StampDutyType.affidavit: 'Affidavit (₦100 flat)',
    StampDutyType.agreement: 'Agreement (0.5%)',
    StampDutyType.mortgage: 'Mortgage (0.5%)',
    StampDutyType.sale: 'Sale (0.5%)',
    StampDutyType.lease: 'Lease (1%)',
    StampDutyType.powerOfAttorney: 'Power of Attorney (0.1%)',
  };

  @override
  void initState() {
    super.initState();
    // Register validation rules
    ValidationService.registerRules(
        'StampDuty', ValidationService.getStampDutyRules());

    // Handle imported data from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && (args['amount'] != null || args['type'] != null)) {
        if (args['amount'] != null) {
          _amountController.text = (args['amount'] as num).toString();
        }
        if (args['type'] != null) {
          _selectedType = _parseStampDutyType(args['type'].toString());
        }
        _calculateStampDuty();
      } else {
        _calculateWithDummyData();
      }
    });
  }

  StampDutyType _parseStampDutyType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'electronictransfer':
      case 'electronic':
        return StampDutyType.electronicTransfer;
      case 'cheque':
        return StampDutyType.cheque;
      case 'affidavit':
        return StampDutyType.affidavit;
      case 'agreement':
        return StampDutyType.agreement;
      case 'mortgage':
        return StampDutyType.mortgage;
      case 'sale':
        return StampDutyType.sale;
      case 'lease':
        return StampDutyType.lease;
      case 'powerofattorney':
        return StampDutyType.powerOfAttorney;
      default:
        return StampDutyType.sale;
    }
  }

  void _handleImportedData(Map<String, dynamic> data) {
    setState(() {
      if (data['amount'] != null) {
        _amountController.text = data['amount'].toString();
      }
      if (data['type'] != null) {
        _selectedType = _parseStampDutyType(data['type'].toString());
      }
    });

    // Automatically calculate after import
    Future.delayed(const Duration(milliseconds: 300), () {
      _calculateStampDuty();
    });
  }

  void _calculateWithDummyData() {
    result = StampDutyCalculator.calculate(
      amount: 50000000,
      type: StampDutyType.sale,
    );
  }

  void _calculateStampDuty() async {
    final data = {
      'amount': double.tryParse(_amountController.text) ?? 0,
      'type': _selectedType.toString(),
    };

    // Validate before calculating
    if (!await canSubmit('StampDuty', data)) {
      return;
    }

    final result = await ErrorRecoveryService.withErrorHandling(
      context,
      () async {
        final amount = data['amount']!;

        return StampDutyCalculator.calculate(
          amount: amount as double,
          type: _selectedType,
        );
      },
      operationName: 'Stamp Duty Calculation',
      expectedErrorType: ErrorType.calculation,
      onRetry: () => _calculateStampDuty(),
    );

    if (result != null) {
      setState(() {
        this.result = result;
        _showResults = true;
      });
      ErrorRecoveryService.showSuccess(
        context,
        '✅ Stamp Duty calculated successfully',
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
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

    final taxAmount = result!.duty;
    final controller =
        TextEditingController(text: taxAmount.toStringAsFixed(2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Stamp Duty Payment'),
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
        taxType: 'StampDuty',
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
    final taxAmount = result!.duty;
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          taxType: 'StampDuty',
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
      appBar: TaxNGAppBar(
        title: 'Stamp Duty Calculator',
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
        calculatorType: 'StampDuty',
        onDataImported: _handleImportedData,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stamp Duty Calculator ${DateTime.now().year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Calculate stamp duty on transactions',
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
                      '1. Transaction Type: Select the type of transaction (sale, lease, mortgage, etc.).',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2. Transaction Amount: Enter the value of the transaction or document.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3. Calculate: Stamp duty will be calculated based on type (flat rate or percentage).',
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
                              'Tip: Electronic transfers above ₦10K attract 0.15% stamp duty. Flat rates apply for cheques and affidavits.',
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
                        'Transaction Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Transaction Type Dropdown
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<StampDutyType>(
                              initialValue: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Transaction Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              items: _stampDutyTypeLabels.entries.map((entry) {
                                return DropdownMenuItem<StampDutyType>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
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
                                  title: const Text('Transaction Type'),
                                  content: const SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Stamp duty rates by transaction type:\n\n'
                                          '• Electronic Transfer: 0.15% (above ₦10K)\n'
                                          '• Cheque: ₦20 flat\n'
                                          '• Affidavit: ₦100 flat\n'
                                          '• Agreement: 0.5%\n'
                                          '• Mortgage: 0.5%\n'
                                          '• Sale: 0.5%\n'
                                          '• Lease: 1%\n'
                                          '• Power of Attorney: 0.1%\n\n'
                                          'Stamp duty is payable on execution of relevant documents and transactions.',
                                        ),
                                      ],
                                    ),
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

                      // Transaction Amount
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _amountController,
                              label: 'Transaction Amount',
                              fieldName: 'amount',
                              calculatorKey: 'StampDuty',
                              getFormData: () => {
                                'amount':
                                    double.tryParse(_amountController.text) ??
                                        0,
                                'type': _selectedType.toString(),
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 50000000',
                              suffix:
                                  const Icon(Icons.monetization_on, size: 20),
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
                                  title: const Text('Transaction Amount'),
                                  content: const Text(
                                    'Enter the total value of the transaction or document. For property sales, enter the sale price. For leases, enter total rental value. For cheques and affidavits, the amount doesn\'t affect the flat duty.',
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
                        onPressed: _calculateStampDuty,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate Stamp Duty'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TemplateActionButtons(
                        taxType: 'StampDuty',
                        currentData: {
                          'amount':
                              double.tryParse(_amountController.text) ?? 0,
                          'type': _selectedType.toString(),
                        },
                        onTemplateLoaded: (data) {
                          setState(() {
                            _amountController.text =
                                (data['amount'] ?? 0).toString();
                            if (data['type'] != null) {
                              _selectedType =
                                  _parseStampDutyType(data['type'].toString());
                            }
                          });
                          _calculateStampDuty();
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
                label: 'Transaction Type',
                value: _stampDutyTypeLabels[_selectedType] ?? 'Unknown',
                explanation:
                    'The type of transaction determines the applicable stamp duty rate. Different transactions attract different rates or flat fees.',
                howCalculated:
                    'Selected by you from available transaction types.',
                why:
                    'Stamp duty rates are standardized by transaction type to ensure consistent tax treatment.',
                icon: Icons.description,
                isHighlight: true,
              ),
              CalculationInfoItem(
                label: 'Transaction Amount',
                value: CurrencyFormatter.formatCurrency(result!.amount),
                explanation:
                    'The transaction amount is the base value for calculating stamp duty (except for flat-rate transactions like cheques).',
                howCalculated: 'This is the amount you entered.',
                why:
                    'Percentage-based stamp duties are calculated from this amount.',
                icon: Icons.monetization_on,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              CalculationInfoItem(
                label: 'Stamp Duty Rate',
                value: _getStampDutyRateDisplay(_selectedType),
                explanation:
                    'The stamp duty rate or flat fee applicable to this transaction type.',
                howCalculated:
                    'Rate is determined by transaction type as per Stamp Duties Act.',
                why:
                    'Different rates reflect the nature and value of different transaction types.',
                icon: Icons.percent,
                color: Colors.blue,
              ),
              CalculationInfoItem(
                label: 'Stamp Duty Payable',
                value: CurrencyFormatter.formatCurrency(result!.duty),
                explanation:
                    'Stamp Duty Payable is the tax amount due on this transaction or document.',
                howCalculated:
                    _getCalculationDescription(_selectedType, result!),
                why:
                    'This amount must be paid to make the document legally valid and enforceable.',
                icon: Icons.receipt_long,
                color: Colors.red,
                isHighlight: true,
              ),
              CalculationInfoItem(
                label: 'Net Amount (After Stamp Duty)',
                value: CurrencyFormatter.formatCurrency(result!.netAmount),
                explanation:
                    'Net amount represents the transaction value minus stamp duty (where applicable).',
                howCalculated:
                    'Transaction Amount (${CurrencyFormatter.formatCurrency(result!.amount)}) - Stamp Duty (${CurrencyFormatter.formatCurrency(result!.duty)}) = ${CurrencyFormatter.formatCurrency(result!.netAmount)}',
                why:
                    'Shows the effective cost including stamp duty obligations.',
                icon: Icons.account_balance,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stamp Duty Details:',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStampDutyDescription(_selectedType),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
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

  String _getStampDutyRateDisplay(StampDutyType type) {
    const rates = {
      StampDutyType.electronicTransfer: '0.15%',
      StampDutyType.cheque: 'Flat ₦20',
      StampDutyType.affidavit: 'Flat ₦100',
      StampDutyType.agreement: '0.5%',
      StampDutyType.lease: '1.0%',
      StampDutyType.mortgage: '0.5%',
      StampDutyType.sale: '0.5%',
      StampDutyType.powerOfAttorney: '0.1%',
    };
    return rates[type] ?? '0.5%';
  }

  String _getCalculationDescription(
      StampDutyType type, StampDutyResult result) {
    if (type == StampDutyType.cheque) {
      return 'Flat fee of ₦20 per cheque';
    } else if (type == StampDutyType.affidavit) {
      return 'Flat fee of ₦100 per affidavit';
    } else {
      final rate = _getStampDutyRateDisplay(type);
      return 'Transaction Amount (${CurrencyFormatter.formatCurrency(result.amount)}) × $rate';
    }
  }

  String _getStampDutyDescription(StampDutyType type) {
    const descriptions = {
      StampDutyType.electronicTransfer:
          'Charged on electronic fund transfers at 0.15% of transaction amount above ₦10,000.',
      StampDutyType.cheque:
          'Fixed stamp duty of ₦20 per cheque presented for payment.',
      StampDutyType.affidavit:
          'Affidavits carry a fixed stamp duty of ₦100 per document.',
      StampDutyType.agreement:
          'Deeds, bonds, and contracts are charged at 0.5% of consideration.',
      StampDutyType.lease:
          'Lease agreements are charged at 1.0% of total rental value.',
      StampDutyType.mortgage:
          'Mortgage/charge on property is charged at 0.5% of loan amount.',
      StampDutyType.sale:
          'Transfer of property ownership is charged at 0.5% of sale price.',
      StampDutyType.powerOfAttorney:
          'Power of Attorney documents are charged at 0.1% of value.',
    };
    return descriptions[type] ?? 'Stamp duty rates apply as per regulations.';
  }
}
