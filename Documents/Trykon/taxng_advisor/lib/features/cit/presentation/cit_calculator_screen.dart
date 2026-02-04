import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/cit/data/cit_calculator.dart';
import 'package:taxng_advisor/features/cit/services/cit_storage_service.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';
import 'package:taxng_advisor/widgets/supporting_documents_widget.dart';
import 'package:taxng_advisor/models/calculation_attachment.dart';
// TODO: Uncomment after `flutter pub get` completes
// import 'package:taxng_advisor/services/hive_service.dart';
// import 'package:taxng_advisor/services/sync_service.dart';

/// CIT Calculator Screen with Input and Results
class CitCalculatorScreen extends StatefulWidget {
  const CitCalculatorScreen({super.key});

  @override
  State<CitCalculatorScreen> createState() => _CitCalculatorScreenState();
}

class _CitCalculatorScreenState extends State<CitCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _turnoverController = TextEditingController(text: '75000000');
  final _profitController = TextEditingController(text: '15000000');

  CitResult? result;
  bool _showResults = false;
  List<CalculationAttachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    // If opened with route arguments (imported data), prefill and calculate.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null &&
          (args['turnover'] != null || args['profit'] != null)) {
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

  void _calculateWithDummyData() {
    result = CitCalculator.calculate(
      turnover: 75000000,
      profit: 15000000,
    );
  }

  void _calculateCIT() {
    if (_formKey.currentState!.validate()) {
      final turnover = double.parse(_turnoverController.text);
      final profit = double.parse(_profitController.text);

      setState(() {
        result = CitCalculator.calculate(turnover: turnover, profit: profit);
        _showResults = true;
      });

      // Save to local storage (legacy service)
      CitStorageService.saveEstimate(result!);
      // TODO: Uncomment after `flutter pub get` completes
      // HiveService.saveCIT(result!.toMap());

      _showSyncStatus();
    }
  }

  Future<void> _showSyncStatus() async {
    // TODO: Uncomment after `flutter pub get` completes
    // final isOnline = await SyncService.isOnline();
    final message = '💾 Saved';
    // isOnline
    // ? '✅ Saved and syncing to server...'
    // : '💾 Saved offline - will sync when online';

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
      appBar: AppBar(
        title: const Text('CIT Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Corporate Income Tax (CIT) 2025',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your business financial details',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),

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
                      TextFormField(
                        controller: _turnoverController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Annual Business Turnover (₦)',
                          hintText: 'e.g., 75000000',
                          prefixIcon: const Icon(Icons.trending_up),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter turnover';
                          }
                          if (double.tryParse(value!) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _profitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Chargeable Profit (₦)',
                          hintText: 'e.g., 15000000',
                          prefixIcon: const Icon(Icons.pie_chart),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter profit';
                          }
                          if (double.tryParse(value!) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
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
                color: Colors.blue[50],
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
