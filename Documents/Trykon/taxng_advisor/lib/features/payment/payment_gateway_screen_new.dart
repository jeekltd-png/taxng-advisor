import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';

/// Payment Gateway Screen - Choose payment method and process payment
class PaymentGatewayScreen extends StatefulWidget {
  final String taxType;
  final double taxAmount;
  final String currency;

  const PaymentGatewayScreen({
    super.key,
    required this.taxType,
    required this.taxAmount,
    required this.currency,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  String _selectedPaymentMethod = 'bank_transfer';
  GovTaxAccount? _selectedTaxAccount;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (PaymentService.govTaxAccounts.isNotEmpty) {
      _selectedTaxAccount = PaymentService.govTaxAccounts.first;
    }
  }

  String _getTaxDescription() {
    switch (widget.taxType) {
      case 'PIT':
        return 'Personal Income Tax (PIT) is a mandatory tax on personal income earned from employment, business, or other sources. It funds government services and infrastructure development.';
      case 'CIT':
        return 'Corporate Income Tax (CIT) is a tax levied on the profits of companies. It supports government revenue for public services while encouraging business investment.';
      case 'VAT':
        return 'Value Added Tax (VAT) is charged on goods and services at each stage of production. It ensures fairness in the tax system and funds public programs.';
      case 'WHT':
        return 'Withholding Tax (WHT) is tax withheld at source from payments like dividends, interests, and professional fees. It ensures tax compliance and regular government revenue.';
      case 'Payroll':
        return 'Payroll tax (PAYE) is deducted directly from employees\' salaries. It finances social security and government services that benefit workers.';
      case 'StampDuty':
        return 'Stamp Duty is a tax on legal documents and transactions like property sales and agreements. It provides revenue for government administrative functions.';
      default:
        return 'Tax payment supporting government services and infrastructure development.';
    }
  }

  String _getTaxTitle() {
    switch (widget.taxType) {
      case 'PIT':
        return 'Personal Income Tax';
      case 'CIT':
        return 'Corporate Income Tax';
      case 'VAT':
        return 'Value Added Tax';
      case 'WHT':
        return 'Withholding Tax';
      case 'Payroll':
        return 'Payroll Tax (PAYE)';
      case 'StampDuty':
        return 'Stamp Duty';
      default:
        return 'Tax Payment';
    }
  }

  Future<void> _processPayment() async {
    if (_selectedTaxAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tax account')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final user = await AuthService.currentUser();
      if (user == null) {
        throw Exception('User not found');
      }

      // Process payment based on selected method
      switch (_selectedPaymentMethod) {
        case 'bank_transfer':
          await _processBankTransfer(user.email);
          break;
        case 'remita':
          await _processRemita(user.email);
          break;
        case 'flutterwave':
          await _processFlutterwave(user.email);
          break;
        case 'paystack':
          await _processPaystack(user.email);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Payment recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processBankTransfer(String email) async {
    final user = await AuthService.currentUser();
    if (user != null) {
      await PaymentService.savePayment(
        userId: user.id,
        taxType: widget.taxType,
        amount: widget.taxAmount,
        email: email,
        paymentMethod: 'bank_transfer',
        taxAccount: _selectedTaxAccount,
      );
    }
  }

  Future<void> _processRemita(String email) async {
    final user = await AuthService.currentUser();
    if (user != null) {
      // Remita integration would go here
      await PaymentService.savePayment(
        userId: user.id,
        taxType: widget.taxType,
        amount: widget.taxAmount,
        email: email,
        paymentMethod: 'remita',
        taxAccount: _selectedTaxAccount,
      );
    }
  }

  Future<void> _processFlutterwave(String email) async {
    final user = await AuthService.currentUser();
    if (user != null) {
      // Flutterwave integration would go here
      await PaymentService.savePayment(
        userId: user.id,
        taxType: widget.taxType,
        amount: widget.taxAmount,
        email: email,
        paymentMethod: 'flutterwave',
        taxAccount: _selectedTaxAccount,
      );
    }
  }

  Future<void> _processPaystack(String email) async {
    final user = await AuthService.currentUser();
    if (user != null) {
      // Paystack integration would go here
      await PaymentService.savePayment(
        userId: user.id,
        taxType: widget.taxType,
        amount: widget.taxAmount,
        email: email,
        paymentMethod: 'paystack',
        taxAccount: _selectedTaxAccount,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay ${widget.taxType} Tax'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount summary
            Card(
              color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tax Amount',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₦${widget.taxAmount.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tax information
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTaxTitle(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTaxDescription(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tax account selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Government Tax Account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            ...PaymentService.govTaxAccounts.map((account) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: RadioListTile<GovTaxAccount>(
                  value: account,
                  groupValue: _selectedTaxAccount,
                  onChanged: (value) {
                    setState(() => _selectedTaxAccount = value);
                  },
                  title: Text(account.bankName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.accountName),
                      Text(
                        account.accountNumber,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Payment method selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            RadioListTile(
              value: 'bank_transfer',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value as String);
              },
              title: const Text('Direct Bank Transfer'),
              subtitle: const Text('Transfer to government account directly'),
            ),
            RadioListTile(
              value: 'remita',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value as String);
              },
              title: const Text('Remita'),
              subtitle: const Text('Pay via Remita platform'),
            ),
            RadioListTile(
              value: 'flutterwave',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value as String);
              },
              title: const Text('Flutterwave'),
              subtitle: const Text('Multiple payment options'),
            ),
            RadioListTile(
              value: 'paystack',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value as String);
              },
              title: const Text('Paystack'),
              subtitle: const Text('Card, bank transfer, USSD'),
            ),
            const SizedBox(height: 24),

            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple,
                border: Border.all(color: Colors.purple[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment Information',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• A confirmation email will be sent to your registered email\n'
                    '• Keep the payment confirmation for your records\n'
                    '• Payment may take 1-2 business days to reflect\n'
                    '• For disputes, contact the relevant tax authority',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.payment),
                label:
                    Text(_isProcessing ? 'Processing...' : 'Confirm Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
