import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/vat/data/vat_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';
import 'package:taxng_advisor/services/validation_service.dart';
import 'package:taxng_advisor/widgets/validated_text_field.dart';
import 'package:taxng_advisor/widgets/template_action_buttons.dart';
import 'package:taxng_advisor/widgets/quick_import_button.dart';
import 'package:taxng_advisor/widgets/calculation_info_item.dart';
import 'package:taxng_advisor/widgets/supporting_documents_widget.dart';
import 'package:taxng_advisor/models/calculation_attachment.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';

/// VAT Calculator Screen
class VatCalculatorScreen extends StatefulWidget {
  const VatCalculatorScreen({super.key});

  @override
  State<VatCalculatorScreen> createState() => _VatCalculatorScreenState();
}

class _VatCalculatorScreenState extends State<VatCalculatorScreen>
    with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _standardSalesController = TextEditingController(text: '7000000');
  final _zeroRatedSalesController = TextEditingController(text: '3000000');
  final _exemptSalesController = TextEditingController(text: '1500000');
  final _totalInputVatController = TextEditingController(text: '850000');
  final _exemptInputVatController = TextEditingController(text: '0');

  VatResult? result;
  bool _showResults = false;
  final List<CalculationAttachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    ValidationService.registerRules('VAT', ValidationService.getVATRules());

    // Handle imported data from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _handleImportedData(args);
      } else {
        _calculateWithDummyData();
      }
    });
  }

  void _handleImportedData(Map<String, dynamic> data) {
    setState(() {
      _standardSalesController.text =
          (data['standardSales'] ?? 7000000).toString();
      _zeroRatedSalesController.text =
          (data['zeroRatedSales'] ?? 3000000).toString();
      _exemptSalesController.text = (data['exemptSales'] ?? 1500000).toString();
      _totalInputVatController.text =
          (data['totalInputVat'] ?? 850000).toString();
      _exemptInputVatController.text = (data['exemptInputVat'] ?? 0).toString();
    });

    Future.delayed(const Duration(milliseconds: 300), _calculateVAT);
  }

  void _calculateWithDummyData() {
    // Use default controller values
    _calculateVAT();
  }

  void _calculateVAT() async {
    final data = {
      'standardSales': double.tryParse(_standardSalesController.text) ?? 0,
      'zeroRatedSales': double.tryParse(_zeroRatedSalesController.text) ?? 0,
      'exemptSales': double.tryParse(_exemptSalesController.text) ?? 0,
      'totalInputVat': double.tryParse(_totalInputVatController.text) ?? 0,
      'exemptInputVat': double.tryParse(_exemptInputVatController.text) ?? 0,
    };

    if (!await canSubmit('VAT', data)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final standardSales = data['standardSales']!;
    final zeroRatedSales = data['zeroRatedSales']!;
    final exemptSales = data['exemptSales']!;
    final totalInputVat = data['totalInputVat']!;
    final exemptInputVat = data['exemptInputVat']!;

    final supplies = <VatSupply>[];

    if (standardSales > 0) {
      supplies.add(VatSupply(
        description: 'Standard-Rated Sales',
        amount: standardSales,
        type: SupplyType.standard,
      ));
    }

    if (zeroRatedSales > 0) {
      supplies.add(VatSupply(
        description: 'Zero-Rated Sales',
        amount: zeroRatedSales,
        type: SupplyType.zeroRated,
      ));
    }

    if (exemptSales > 0) {
      supplies.add(VatSupply(
        description: 'Exempt Sales',
        amount: exemptSales,
        type: SupplyType.exempt,
      ));
    }

    setState(() {
      result = VatCalculator.calculate(
        supplies: supplies,
        totalInputVat: totalInputVat,
        exemptInputVat: exemptInputVat,
      );
      _showResults = true;
    });
  }

  @override
  void dispose() {
    _standardSalesController.dispose();
    _zeroRatedSalesController.dispose();
    _exemptSalesController.dispose();
    _totalInputVatController.dispose();
    _exemptInputVatController.dispose();
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

    final taxAmount = result!.netPayable.abs();
    final controller =
        TextEditingController(text: taxAmount.toStringAsFixed(2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record VAT Payment'),
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
        taxType: 'VAT',
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
    final taxAmount = result!.netPayable.abs();
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          taxType: 'VAT',
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
        title: 'VAT Calculator',
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
        calculatorType: 'VAT',
        onDataImported: _handleImportedData,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Value Added Tax (VAT) ${DateTime.now().year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your VAT-related transactions',
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
                      '1. Standard-Rated Sales: Enter sales subject to 7.5% VAT.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2. Zero-Rated Sales: Enter exports and other zero-rated supplies.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3. Exempt Sales: Enter VAT-exempt supplies (medical, education, etc.).',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '4. Input VAT: Enter VAT paid on purchases and expenses.',
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
                              'Tip: Input VAT on exempt supplies cannot be recovered. Ensure accurate allocation.',
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
                        'Sales Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Standard-Rated Sales
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _standardSalesController,
                              label: 'Standard-Rated Sales (7.5%)',
                              fieldName: 'standardSales',
                              calculatorKey: 'VAT',
                              getFormData: () => {
                                'standardSales': double.tryParse(
                                        _standardSalesController.text) ??
                                    0,
                                'zeroRatedSales': double.tryParse(
                                        _zeroRatedSalesController.text) ??
                                    0,
                                'exemptSales': double.tryParse(
                                        _exemptSalesController.text) ??
                                    0,
                                'totalInputVat': double.tryParse(
                                        _totalInputVatController.text) ??
                                    0,
                                'exemptInputVat': double.tryParse(
                                        _exemptInputVatController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 7000000',
                              suffix: const Icon(Icons.shopping_cart, size: 20),
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
                                  title: const Text('Standard-Rated Sales'),
                                  content: const SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'What it means:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Total sales of goods and services subject to 7.5% VAT rate. This is the most common category for business transactions.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Example:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'If you sold goods worth ₦7,000,000, you should charge customers ₦525,000 VAT (7.5%), making total invoice ₦7,525,000.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'How it\'s used:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Output VAT = Standard Sales × 7.5%. This is the VAT you collect from customers and must remit to FIRS.',
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

                      // Zero-Rated Sales
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _zeroRatedSalesController,
                              label: 'Zero-Rated Sales (0%)',
                              fieldName: 'zeroRatedSales',
                              calculatorKey: 'VAT',
                              getFormData: () => {
                                'standardSales': double.tryParse(
                                        _standardSalesController.text) ??
                                    0,
                                'zeroRatedSales': double.tryParse(
                                        _zeroRatedSalesController.text) ??
                                    0,
                                'exemptSales': double.tryParse(
                                        _exemptSalesController.text) ??
                                    0,
                                'totalInputVat': double.tryParse(
                                        _totalInputVatController.text) ??
                                    0,
                                'exemptInputVat': double.tryParse(
                                        _exemptInputVatController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 3000000',
                              suffix:
                                  const Icon(Icons.flight_takeoff, size: 20),
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
                                  title: const Text('Zero-Rated Sales'),
                                  content: const SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'What it means:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Supplies taxed at 0% VAT rate. Includes exports, goods/services sold in free trade zones, and items used for humanitarian purposes.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Example:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'If you exported goods worth ₦3,000,000, you charge 0% VAT but can still recover input VAT on related purchases.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Key benefit:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Unlike exempt supplies, zero-rated supplies allow you to recover input VAT, improving cash flow.',
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

                      // Exempt Sales
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _exemptSalesController,
                              label: 'Exempt Sales',
                              fieldName: 'exemptSales',
                              calculatorKey: 'VAT',
                              getFormData: () => {
                                'standardSales': double.tryParse(
                                        _standardSalesController.text) ??
                                    0,
                                'zeroRatedSales': double.tryParse(
                                        _zeroRatedSalesController.text) ??
                                    0,
                                'exemptSales': double.tryParse(
                                        _exemptSalesController.text) ??
                                    0,
                                'totalInputVat': double.tryParse(
                                        _totalInputVatController.text) ??
                                    0,
                                'exemptInputVat': double.tryParse(
                                        _exemptInputVatController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 1500000',
                              suffix:
                                  const Icon(Icons.local_hospital, size: 20),
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
                                  title: const Text('Exempt Sales'),
                                  content: const SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'What it means:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Supplies that are not subject to VAT. Includes medical services, educational services, basic food items, pharmaceuticals, and financial services.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Example:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'A hospital providing ₦1,500,000 worth of medical services does not charge VAT to patients.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Important:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Input VAT on purchases related to exempt supplies CANNOT be recovered. You must track and allocate exempt input VAT separately.',
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
                      const SizedBox(height: 20),

                      const Text(
                        'Input VAT Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Total Input VAT
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _totalInputVatController,
                              label: 'Total Input VAT',
                              fieldName: 'totalInputVat',
                              calculatorKey: 'VAT',
                              getFormData: () => {
                                'standardSales': double.tryParse(
                                        _standardSalesController.text) ??
                                    0,
                                'zeroRatedSales': double.tryParse(
                                        _zeroRatedSalesController.text) ??
                                    0,
                                'exemptSales': double.tryParse(
                                        _exemptSalesController.text) ??
                                    0,
                                'totalInputVat': double.tryParse(
                                        _totalInputVatController.text) ??
                                    0,
                                'exemptInputVat': double.tryParse(
                                        _exemptInputVatController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 850000',
                              suffix: const Icon(Icons.receipt_long, size: 20),
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
                                  title: const Text('Total Input VAT'),
                                  content: const SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'What it means:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Total VAT you paid on purchases, expenses, and imports during the period. This is VAT incurred on business inputs.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Example:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'If you purchased ₦11,333,333 worth of goods/services, you paid ₦850,000 VAT (7.5%) that can be offset against output VAT.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'How it\'s used:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Net VAT Payable = Output VAT - Recoverable Input VAT. Input VAT reduces your tax burden.',
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

                      // Exempt Input VAT
                      Row(
                        children: [
                          Expanded(
                            child: ValidatedTextField(
                              controller: _exemptInputVatController,
                              label: 'Exempt Input VAT',
                              fieldName: 'exemptInputVat',
                              calculatorKey: 'VAT',
                              getFormData: () => {
                                'standardSales': double.tryParse(
                                        _standardSalesController.text) ??
                                    0,
                                'zeroRatedSales': double.tryParse(
                                        _zeroRatedSalesController.text) ??
                                    0,
                                'exemptSales': double.tryParse(
                                        _exemptSalesController.text) ??
                                    0,
                                'totalInputVat': double.tryParse(
                                        _totalInputVatController.text) ??
                                    0,
                                'exemptInputVat': double.tryParse(
                                        _exemptInputVatController.text) ??
                                    0,
                              },
                              keyboardType: TextInputType.number,
                              prefixText: '₦',
                              hintText: 'e.g., 0',
                              suffix: const Icon(Icons.block, size: 20),
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
                                  title: const Text('Exempt Input VAT'),
                                  content: const SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'What it means:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'VAT paid on purchases specifically used for making exempt supplies. This VAT cannot be recovered.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Example:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'A private school (exempt) buys furniture for ₦1,000,000 + ₦75,000 VAT. The ₦75,000 VAT cannot be claimed back.',
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'How it\'s used:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Recoverable Input VAT = Total Input VAT - Exempt Input VAT. Proper allocation is critical for accurate returns.',
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
                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: _calculateVAT,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate VAT'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TemplateActionButtons(
                        taxType: 'VAT',
                        currentData: {
                          'standardSales':
                              double.tryParse(_standardSalesController.text) ??
                                  0,
                          'zeroRatedSales':
                              double.tryParse(_zeroRatedSalesController.text) ??
                                  0,
                          'exemptSales':
                              double.tryParse(_exemptSalesController.text) ?? 0,
                          'totalInputVat':
                              double.tryParse(_totalInputVatController.text) ??
                                  0,
                          'exemptInputVat':
                              double.tryParse(_exemptInputVatController.text) ??
                                  0,
                        },
                        onTemplateLoaded: (data) {
                          setState(() {
                            _standardSalesController.text =
                                (data['standardSales'] ?? 0).toString();
                            _zeroRatedSalesController.text =
                                (data['zeroRatedSales'] ?? 0).toString();
                            _exemptSalesController.text =
                                (data['exemptSales'] ?? 0).toString();
                            _totalInputVatController.text =
                                (data['totalInputVat'] ?? 0).toString();
                            _exemptInputVatController.text =
                                (data['exemptInputVat'] ?? 0).toString();
                          });
                          _calculateVAT();
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
                label: 'Total Sales',
                value: CurrencyFormatter.formatCurrency(result!.totalSales),
                explanation:
                    'Total Sales is the sum of all your supplies during the period (standard-rated, zero-rated, and exempt).',
                howCalculated:
                    'Total Sales = Standard Sales + Zero-Rated Sales + Exempt Sales.',
                why:
                    'This gives you a complete picture of your business turnover and helps determine if you need to register for VAT (₦25M threshold).',
                icon: Icons.shopping_bag,
              ),
              CalculationInfoItem(
                label: 'Output VAT',
                value: CurrencyFormatter.formatCurrency(result!.outputVat),
                explanation:
                    'Output VAT is the VAT you charge customers on taxable supplies. This is what you collect on behalf of FIRS.',
                howCalculated:
                    'Output VAT = Standard-Rated Sales × 7.5%. Zero-rated and exempt sales generate no output VAT.',
                why:
                    'This represents your VAT liability before claiming back input VAT. You must remit this (minus recoverable input VAT) to FIRS.',
                icon: Icons.attach_money,
                color: Colors.orange,
              ),
              CalculationInfoItem(
                label: 'Total Input VAT',
                value: CurrencyFormatter.formatCurrency(
                    result!.recoverableInput +
                        result!.netPayable -
                        result!.outputVat),
                explanation:
                    'Total Input VAT is all VAT paid on your business purchases and expenses.',
                howCalculated:
                    'This is the amount you enter from your purchase invoices and import documents.',
                why:
                    'Input VAT reduces your net VAT liability. Keeping accurate records maximizes your recoverable amount.',
                icon: Icons.receipt,
              ),
              CalculationInfoItem(
                label: 'Recoverable Input VAT',
                value:
                    CurrencyFormatter.formatCurrency(result!.recoverableInput),
                explanation:
                    'Recoverable Input VAT is the portion of input VAT you can claim back from FIRS.',
                howCalculated:
                    'Recoverable Input VAT = Total Input VAT - Exempt Input VAT. Only VAT on taxable supplies is recoverable.',
                why:
                    'This is the amount that offsets your output VAT, reducing what you owe to FIRS.',
                icon: Icons.money_off,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              CalculationInfoItem(
                label: 'Net VAT Payable',
                value: CurrencyFormatter.formatCurrency(result!.netPayable),
                explanation:
                    'Net VAT Payable is the final amount you must pay to (or can reclaim from) FIRS.',
                howCalculated:
                    'Net VAT = Output VAT - Recoverable Input VAT. Positive means payment due; negative means refund claimable.',
                why:
                    'This is your bottom-line VAT obligation. Must be filed monthly (turnover >₦100M) or bi-monthly (≤₦100M).',
                icon: Icons.account_balance_wallet,
                color: result!.netPayable >= 0 ? Colors.red : Colors.green,
                isHighlight: true,
              ),
              if (result!.netPayable >= 0) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showPaymentDialog(context),
                        icon: const Icon(Icons.receipt_long),
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
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
      bottomNavigationBar: result != null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                ],
              ),
            )
          : null,
    );
  }
}
