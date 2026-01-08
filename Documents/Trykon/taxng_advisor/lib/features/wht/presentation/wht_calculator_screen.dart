import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/wht/data/wht_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';
import 'package:taxng_advisor/services/validation_service.dart';
import 'package:taxng_advisor/services/error_recovery_service.dart';
import 'package:taxng_advisor/widgets/validated_text_field.dart';
import 'package:taxng_advisor/widgets/template_action_buttons.dart';
import 'package:taxng_advisor/widgets/quick_import_button.dart';
import 'package:taxng_advisor/widgets/calculation_info_item.dart';

/// WHT Calculator Screen
class WhtCalculatorScreen extends StatefulWidget {
  const WhtCalculatorScreen({super.key});

  @override
  State<WhtCalculatorScreen> createState() => _WhtCalculatorScreenState();
}

class _WhtCalculatorScreenState extends State<WhtCalculatorScreen>
    with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '5000000');

  WhtType _selectedType = WhtType.dividends;
  WhtResult? result;
  bool _showResults = false;

  final Map<WhtType, String> _whtTypeLabels = {
    WhtType.dividends: 'Dividends (10%)',
    WhtType.interest: 'Interest (10%)',
    WhtType.rent: 'Rent (10%)',
    WhtType.royalties: 'Royalties (10%)',
    WhtType.directorsFees: 'Directors Fees (10%)',
    WhtType.professionalFees: 'Professional Fees (10%)',
    WhtType.construction: 'Construction Services (5%)',
    WhtType.contracts: 'Contract Payment (5%)',
  };

  @override
  void initState() {
    super.initState();
    // Register validation rules
    ValidationService.registerRules('WHT', ValidationService.getWHTRules());

    // Handle imported data from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && (args['amount'] != null || args['type'] != null)) {
        if (args['amount'] != null) {
          _amountController.text = (args['amount'] as num).toString();
        }
        if (args['type'] != null) {
          _selectedType = _parseWhtType(args['type'].toString());
        }
        _calculateWHT();
      } else {
        _calculateWithDummyData();
      }
    });
  }

  WhtType _parseWhtType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'dividends':
        return WhtType.dividends;
      case 'interest':
        return WhtType.interest;
      case 'rent':
        return WhtType.rent;
      case 'royalties':
        return WhtType.royalties;
      case 'directors':
      case 'directorsfees':
        return WhtType.directorsFees;
      case 'professional':
      case 'professionalfees':
        return WhtType.professionalFees;
      case 'construction':
        return WhtType.construction;
      case 'contracts':
        return WhtType.contracts;
      default:
        return WhtType.dividends;
    }
  }

  void _handleImportedData(Map<String, dynamic> data) {
    setState(() {
      if (data['amount'] != null) {
        _amountController.text = data['amount'].toString();
      }
      if (data['type'] != null) {
        _selectedType = _parseWhtType(data['type'].toString());
      }
    });

    // Automatically calculate after import
    Future.delayed(const Duration(milliseconds: 300), () {
      _calculateWHT();
    });
  }

  void _calculateWithDummyData() {
    result = WhtCalculator.calculate(
      amount: 5000000,
      type: WhtType.dividends,
    );
  }

  void _calculateWHT() async {
    final data = {
      'amount': double.tryParse(_amountController.text) ?? 0,
      'type': _selectedType.toString(),
    };

    // Validate before calculating
    if (!await canSubmit('WHT', data)) {
      return;
    }

    final result = await ErrorRecoveryService.withErrorHandling(
      context,
      () async {
        final amount = data['amount']!;

        return WhtCalculator.calculate(
          amount: amount as double,
          type: _selectedType,
        );
      },
      operationName: 'WHT Calculation',
      expectedErrorType: ErrorType.calculation,
      onRetry: () => _calculateWHT(),
    );

    if (result != null) {
      setState(() {
        this.result = result;
        _showResults = true;
      });
      ErrorRecoveryService.showSuccess(
        context,
        '✅ WHT calculated successfully',
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
            const Text('WHT Calculator'),
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
        calculatorType: 'WHT',
        onDataImported: _handleImportedData,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Withholding Tax (WHT) 2025',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter payment details to calculate WHT',
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
                      '1. Payment Type: Select the type of payment (dividends, interest, rent, etc.).',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2. Gross Amount: Enter the gross payment amount before WHT deduction.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3. Calculate: WHT will be calculated based on the payment type and amount.',
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
                              'Tip: WHT is an advance tax payment. Most types are 10%, but construction/contracts are 5%.',
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
                        'Payment Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Type Dropdown
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<WhtType>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Payment Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _whtTypeLabels.entries.map((entry) {
                                return DropdownMenuItem<WhtType>(
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
                                  title: const Text('Payment Type'),
                                  content: const SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'WHT rates vary by payment type:\n\n'
                                          '• Dividends: 10%\n'
                                          '• Interest: 10%\n'
                                          '• Rent: 10%\n'
                                          '• Royalties: 10%\n'
                                          '• Directors Fees: 10%\n'
                                          '• Professional Fees: 10%\n'
                                          '• Construction: 5%\n'
                                          '• Contracts: 5%\n\n'
                                          'WHT is an advance tax payment deducted at source and remitted to FIRS.',
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

                      // Gross Amount
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _amountController,
                              label: 'Gross Payment Amount',
                              fieldName: 'amount',
                              calculatorKey: 'WHT',
                              getFormData: () => {
                                'amount':
                                    double.tryParse(_amountController.text) ??
                                        0,
                                'type': _selectedType.toString(),
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 5000000',
                              suffix: const Icon(Icons.money, size: 20),
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
                                  title: const Text('Gross Payment Amount'),
                                  content: const Text(
                                    'Enter the total payment amount before WHT deduction. The calculator will determine the WHT to be withheld based on the payment type.',
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
                        onPressed: _calculateWHT,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate WHT'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TemplateActionButtons(
                        taxType: 'WHT',
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
                                  _parseWhtType(data['type'].toString());
                            }
                          });
                          _calculateWHT();
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
                label: 'Payment Type',
                value: _whtTypeLabels[_selectedType] ?? 'Unknown',
                explanation:
                    'The type of payment determines the applicable WHT rate. Different payment categories attract different rates under Nigerian tax law.',
                howCalculated: 'Selected by you from available payment types.',
                why:
                    'WHT rates are standardized by payment type to ensure consistent tax treatment across similar transactions.',
                icon: Icons.category,
                isHighlight: true,
              ),
              CalculationInfoItem(
                label: 'Gross Payment Amount',
                value: CurrencyFormatter.formatCurrency(result!.amount),
                explanation:
                    'The gross amount is the total payment before WHT deduction. This is the base for calculating withholding tax.',
                howCalculated: 'This is the amount you entered.',
                why: 'WHT is calculated as a percentage of this gross amount.',
                icon: Icons.money,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              CalculationInfoItem(
                label: 'WHT Rate',
                value: CurrencyFormatter.formatPercentage(result!.rate),
                explanation:
                    'The WHT rate applicable to this payment type. Standard payments are 10%, while construction/contracts are 5%.',
                howCalculated:
                    'Rate is determined by payment type: Dividends/Interest/Rent/Royalties/Directors/Professional = 10%, Construction/Contracts = 5%.',
                why:
                    'Different rates recognize varying business contexts and compliance requirements.',
                icon: Icons.percent,
                color: Colors.blue,
              ),
              CalculationInfoItem(
                label: 'WHT to be Withheld',
                value: CurrencyFormatter.formatCurrency(result!.wht),
                explanation:
                    'WHT to be Withheld is the tax amount to be deducted from the payment and remitted to FIRS.',
                howCalculated:
                    'Gross Amount (${CurrencyFormatter.formatCurrency(result!.amount)}) × Rate (${CurrencyFormatter.formatPercentage(result!.rate)}) = ${CurrencyFormatter.formatCurrency(result!.wht)}',
                why:
                    'This amount must be remitted to FIRS within 10 days of payment. It serves as advance tax for the recipient.',
                icon: Icons.remove_circle_outline,
                color: Colors.red,
                isHighlight: true,
              ),
              CalculationInfoItem(
                label: 'Net Amount Payable',
                value: CurrencyFormatter.formatCurrency(result!.netAmount),
                explanation:
                    'Net Amount is what the recipient receives after WHT is deducted from the gross payment.',
                howCalculated:
                    'Gross Amount (${CurrencyFormatter.formatCurrency(result!.amount)}) - WHT (${CurrencyFormatter.formatCurrency(result!.wht)}) = ${CurrencyFormatter.formatCurrency(result!.netAmount)}',
                why:
                    'This is the actual amount to be paid to the beneficiary. The withheld amount goes to FIRS.',
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'WHT must be remitted to FIRS within 10 days of payment. Failure to remit attracts penalties.',
                          style:
                              TextStyle(fontSize: 12, color: Colors.amber[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _openPaymentGateway(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.payment),
                label: const Text('Pay WHT via Payment Gateway'),
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

  Future<void> _openPaymentGateway(BuildContext context) async {
    if (result == null) return;
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          taxType: 'WHT',
          taxAmount: result!.wht,
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
}
