import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/payroll/data/payroll_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';

/// Payroll Calculator Screen
class PayrollCalculatorScreen extends StatefulWidget {
  const PayrollCalculatorScreen({super.key});

  @override
  State<PayrollCalculatorScreen> createState() =>
      _PayrollCalculatorScreenState();
}

class _PayrollCalculatorScreenState extends State<PayrollCalculatorScreen> {
  late final PayrollResult result;

  @override
  void initState() {
    super.initState();
    // Calculate with dummy data
    result = PayrollCalculator.calculateWithDeductions(
      monthlyGross: 250000,
      pensionRate: 0.08,
      nhfRate: 0.02,
      otherDeductions: 5000,
    );
  }

  Future<void> _showPaymentDialog(BuildContext context) async {
    final user = await AuthService.currentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    final taxAmount = result.monthlyPaye;
    final controller =
        TextEditingController(text: taxAmount.toStringAsFixed(2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payroll Payment'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
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
    final taxAmount = result.monthlyPaye;
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
        title: const Text('Payroll Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Payroll Calculation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Monthly Gross Salary',
              value: CurrencyFormatter.formatCurrency(result.monthlyGross),
            ),
            _ResultCard(
              label: 'Monthly PAYE Tax',
              value: CurrencyFormatter.formatCurrency(result.monthlyPaye),
              color: Colors.red,
              isHighlight: true,
              isBold: true,
            ),
            _ResultCard(
              label: 'Monthly Net Pay',
              value: CurrencyFormatter.formatCurrency(result.monthlyNet),
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Annual Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _ResultCard(
              label: 'Annual Gross',
              value: CurrencyFormatter.formatCurrency(result.annualGross),
            ),
            _ResultCard(
              label: 'Annual PAYE',
              value: CurrencyFormatter.formatCurrency(result.annualPaye),
              color: Colors.red,
              isHighlight: true,
              isBold: true,
            ),
            _ResultCard(
              label: 'Annual Net',
              value: CurrencyFormatter.formatCurrency(result.annualNet),
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Effective Tax Rate',
              value: CurrencyFormatter.formatPercentage(
                  result.effectiveAnnualRate),
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
            const SizedBox(height: 12),
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
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
