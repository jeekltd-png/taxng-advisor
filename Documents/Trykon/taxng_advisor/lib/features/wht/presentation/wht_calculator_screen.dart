import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/wht/data/wht_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';

/// WHT Calculator Screen
class WhtCalculatorScreen extends StatefulWidget {
  const WhtCalculatorScreen({super.key});

  @override
  State<WhtCalculatorScreen> createState() => _WhtCalculatorScreenState();
}

class _WhtCalculatorScreenState extends State<WhtCalculatorScreen> {
  late final WhtResult result;

  @override
  void initState() {
    super.initState();
    // Calculate with dummy data - Dividend payment
    result = WhtCalculator.calculate(
      amount: 5000000, // ₦5M dividend
      type: WhtType.dividends,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WHT Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Withholding Tax (WHT)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Payment Type',
              value: _getWhtTypeLabel(result.type),
              isHighlight: true,
            ),
            _ResultCard(
              label: 'Gross Amount',
              value: CurrencyFormatter.formatCurrency(result.amount),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'WHT Rate',
              value: CurrencyFormatter.formatPercentage(result.rate),
              color: Colors.blue,
            ),
            _ResultCard(
              label: 'WHT Calculated',
              value: CurrencyFormatter.formatCurrency(result.wht),
              color: Colors.red,
              isBold: true,
              isHighlight: true,
            ),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Net Amount (After WHT)',
              value: CurrencyFormatter.formatCurrency(result.netAmount),
              color: Colors.green,
              isBold: true,
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'WHT must be remitted to FIRS within 10 days of payment',
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

  String _getWhtTypeLabel(String typeString) {
    const labels = {
      'Dividends': 'Dividend Income',
      'Interest': 'Interest Income',
      'Rent': 'Rent Payment',
      'Royalties': 'Royalties',
      'Directors Fees': 'Directors Fees',
      'Professional Fees': 'Professional Fees',
      'Construction': 'Construction Services',
      'Contracts': 'Contract Payment',
      'Other': 'Other Payment',
    };
    return labels[typeString] ?? 'Unknown';
  }

  Future<void> _openPaymentGateway(BuildContext context) async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          taxType: 'WHT',
          taxAmount: result.wht,
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
