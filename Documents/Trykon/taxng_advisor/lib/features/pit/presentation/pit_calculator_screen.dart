import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/pit/data/pit_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';

/// PIT Calculator Screen
class PitCalculatorScreen extends StatefulWidget {
  const PitCalculatorScreen({super.key});

  @override
  State<PitCalculatorScreen> createState() => _PitCalculatorScreenState();
}

class _PitCalculatorScreenState extends State<PitCalculatorScreen> {
  late final PitResult result;

  @override
  void initState() {
    super.initState();
    // Calculate with dummy data - Employed professional with rent paid
    result = PitCalculator.calculate(
      grossIncome: 5000000, // ₦5M annual gross
      otherDeductions: [200000], // ₦200K other deductions
      annualRentPaid: 1200000, // ₦1.2M annual rent
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

    final controller =
        TextEditingController(text: result.totalTax.toStringAsFixed(2));
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
      final amt = double.tryParse(controller.text) ?? result.totalTax;

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
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          taxType: 'PIT',
          taxAmount: result.totalTax,
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
        title: const Text('PIT Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Income Tax (PIT)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Gross Income (Annual)',
              value: CurrencyFormatter.formatCurrency(result.grossIncome),
            ),
            _ResultCard(
              label: 'Other Deductions',
              value: CurrencyFormatter.formatCurrency(
                  result.totalDeductions - result.rentRelief),
            ),
            if (result.rentRelief > 0)
              _ResultCard(
                label: 'Rent Relief',
                value: CurrencyFormatter.formatCurrency(result.rentRelief),
                color: Colors.green,
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Chargeable Income',
              value: CurrencyFormatter.formatCurrency(result.chargeableIncome),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tax by Bands:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...result.breakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
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
              );
            }).toList(),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Total PIT',
              value: CurrencyFormatter.formatCurrency(result.totalTax),
              color: Colors.red,
              isBold: true,
              isHighlight: true,
            ),
            _ResultCard(
              label: 'Effective Tax Rate',
              value: CurrencyFormatter.formatPercentage(result.effectiveRate),
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
