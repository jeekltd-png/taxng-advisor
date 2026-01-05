import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/stamp_duty/data/stamp_duty_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';

/// Stamp Duty Screen
class StampDutyScreen extends StatefulWidget {
  const StampDutyScreen({super.key});

  @override
  State<StampDutyScreen> createState() => _StampDutyScreenState();
}

class _StampDutyScreenState extends State<StampDutyScreen> {
  late final StampDutyResult result;

  @override
  void initState() {
    super.initState();
    // Calculate with dummy data - Property sale transaction
    result = StampDutyCalculator.calculate(
      amount: 50000000, // ₦50M property sale
      type: StampDutyType.sale,
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

    final taxAmount = result.duty;
    final controller =
        TextEditingController(text: taxAmount.toStringAsFixed(2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Stamp Duty Payment'),
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
    final taxAmount = result.duty;
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
      appBar: AppBar(
        title: const Text('Stamp Duty Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stamp Duty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Transaction Type',
              value: _getStampDutyTypeLabel(result.type.toString()),
              isHighlight: true,
            ),
            _ResultCard(
              label: 'Transaction Amount',
              value: CurrencyFormatter.formatCurrency(result.amount),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Stamp Duty Rate',
              value: _getStampDutyRate(result.type),
              color: Colors.blue,
            ),
            _ResultCard(
              label: 'Stamp Duty Payable',
              value: CurrencyFormatter.formatCurrency(result.duty),
              color: Colors.red,
              isBold: true,
              isHighlight: true,
            ),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Net Amount (After Stamp Duty)',
              value: CurrencyFormatter.formatCurrency(result.netAmount),
              color: Colors.green,
              isBold: true,
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stamp Duty Details:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStampDutyDescription(result.type),
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

  String _getStampDutyTypeLabel(String type) {
    const labels = {
      'Electronic Transfer': 'Electronic Transfer',
      'Cheque': 'Cheque Payment',
      'Agreement': 'Deed/Agreement',
      'Lease': 'Lease Agreement',
      'Mortgage': 'Mortgage',
      'Sale': 'Property Sale',
      'Power of Attorney': 'Power of Attorney',
      'Affidavit': 'Affidavit',
      'Other': 'Other Document',
    };
    return labels[type] ?? type;
  }

  String _getStampDutyRate(String type) {
    const rates = {
      'Electronic Transfer': '0.15%',
      'Cheque': 'Flat ₦20',
      'Agreement': '0.5%',
      'Lease': '1.0%',
      'Mortgage': '0.5%',
      'Sale': '0.5%',
      'Power of Attorney': '0.1%',
      'Affidavit': 'Flat ₦100',
      'Other': '0.5%',
    };
    return rates[type] ?? 'Varies';
  }

  String _getStampDutyDescription(String type) {
    const descriptions = {
      'Electronic Transfer':
          'Charged on electronic fund transfers at 0.15% of transaction amount.',
      'Cheque': 'Fixed stamp duty of ₦20 per cheque presented for payment.',
      'Agreement':
          'Deeds, bonds, and contracts are charged at 0.5% of consideration.',
      'Lease': 'Lease agreements are charged at 1.0% of total rental value.',
      'Mortgage':
          'Mortgage/charge on property is charged at 0.5% of loan amount.',
      'Sale':
          'Transfer of property ownership is charged at 0.5% of sale price.',
      'Power of Attorney':
          'Power of Attorney documents are charged at 0.1% of value.',
      'Affidavit': 'Affidavits carry a fixed stamp duty of ₦100 per document.',
      'Other': 'Other documents are charged at 0.5% where applicable.',
    };
    return descriptions[type] ?? 'Stamp duty rates apply as per regulations.';
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
