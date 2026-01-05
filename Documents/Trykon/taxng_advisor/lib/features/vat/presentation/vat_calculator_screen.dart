import 'package:flutter/material.dart';
import 'package:taxng_advisor/features/vat/data/vat_calculator.dart';
import 'package:taxng_advisor/models/tax_result.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/payment/payment_gateway_screen.dart';

/// VAT Calculator Screen
class VatCalculatorScreen extends StatefulWidget {
  const VatCalculatorScreen({super.key});

  @override
  State<VatCalculatorScreen> createState() => _VatCalculatorScreenState();
}

class _VatCalculatorScreenState extends State<VatCalculatorScreen> {
  late final VatResult result;

  @override
  void initState() {
    super.initState();
    // Calculate with dummy data - Mix of standard, zero-rated, and exempt supplies
    final supplies = [
      VatSupply(
          description: 'Taxable Goods',
          amount: 5000000,
          type: SupplyType.standard),
      VatSupply(
          description: 'Taxable Services',
          amount: 2000000,
          type: SupplyType.standard),
      VatSupply(
          description: 'Exported Goods',
          amount: 3000000,
          type: SupplyType.zeroRated),
      VatSupply(
          description: 'Medical Services',
          amount: 1500000,
          type: SupplyType.exempt),
    ];

    result = VatCalculator.calculate(
      supplies: supplies,
      totalInputVat: 850000, // Total VAT paid on purchases
      exemptInputVat: 0, // VAT on exempt supply inputs (non-recoverable)
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

    final taxAmount = result.netPayable.abs();
    final controller =
        TextEditingController(text: taxAmount.toStringAsFixed(2));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record VAT Payment'),
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
    final taxAmount = result.netPayable.abs();
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
      appBar: AppBar(
        title: const Text('VAT Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Value Added Tax (VAT)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Taxable Sales (7.5%)',
              value: CurrencyFormatter.formatCurrency(result.vatableSales),
            ),
            _ResultCard(
              label: 'Zero-Rated Sales',
              value: CurrencyFormatter.formatCurrency(result.zeroRatedSales),
              color: Colors.green,
            ),
            _ResultCard(
              label: 'Exempt Sales',
              value: CurrencyFormatter.formatCurrency(result.exemptSales),
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Total Sales',
              value: CurrencyFormatter.formatCurrency(result.totalSales),
              isHighlight: true,
            ),
            const SizedBox(height: 16),
            _ResultCard(
              label: 'Output VAT (7.5%)',
              value: CurrencyFormatter.formatCurrency(result.outputVat),
              color: Colors.blue,
            ),
            _ResultCard(
              label: 'Recoverable Input VAT',
              value: CurrencyFormatter.formatCurrency(result.recoverableInput),
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (result.netPayable >= 0)
              _ResultCard(
                label: 'VAT Payable',
                value: CurrencyFormatter.formatCurrency(result.netPayable),
                color: Colors.red,
                isBold: true,
                isHighlight: true,
              )
            else
              _ResultCard(
                label: 'VAT Refund Due',
                value:
                    CurrencyFormatter.formatCurrency(result.netPayable.abs()),
                color: Colors.green,
                isBold: true,
                isHighlight: true,
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
