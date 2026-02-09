import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:taxng_advisor/features/help/payment_guide_screen.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';

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
        return 'Personal Income Tax (PIT)\n• What: Tax on income from salaries, business profits, and side gigs.\n• Why: Funds state services (roads, health, education) and keeps you compliant.\n• Pay when: You earn income in the current year (PAYE, self-employed).';
      case 'CIT':
        return 'Corporate Income Tax (CIT)\n• What: Tax on company profits.\n• Why: Supports federal revenue for infrastructure and public services.\n• Pay when: Your company makes profit in the accounting year.';
      case 'VAT':
        return 'Value Added Tax (VAT)\n• What: Consumption tax on goods and services at each stage.\n• Why: Ensures broad-based revenue and fair sharing across the value chain.\n• Pay when: You supply taxable goods/services and invoice customers.';
      case 'WHT':
        return 'Withholding Tax (WHT)\n• What: Tax withheld at source on payments like fees, dividends, rent.\n• Why: Enforces compliance early and credits your final tax.\n• Pay when: You make eligible payments and must deduct at source.';
      case 'Payroll':
        return 'Payroll Tax (PAYE)\n• What: Monthly tax deducted from employee salaries.\n• Why: Funds social services and keeps employer/employee compliant.\n• Pay when: You run payroll and remit on behalf of staff.';
      case 'StampDuty':
        return 'Stamp Duty\n• What: Tax on legal instruments (property sales, agreements, transfers).\n• Why: Supports government admin and record-keeping.\n• Pay when: You execute stamped documents or qualifying transfers.';
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

  void _openPaymentGuide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentGuideScreen(),
      ),
    );
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

  Widget _buildPaymentMethodTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isSelected ? color : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TaxNGAppBar(
        title: 'Pay ${widget.taxType} Tax',
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _getTaxTitle(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                      Tooltip(
                        message: 'Open payment guide',
                        child: IconButton(
                          icon: const Icon(Icons.help_outline,
                              color: Colors.white),
                          onPressed: _openPaymentGuide,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Government Tax Account',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...PaymentService.govTaxAccounts.map((account) {
              final isSelected = _selectedTaxAccount == account;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTaxAccount = account),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        // Radio indicator
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        // Account details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.bankName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: isSelected
                                      ? const Color(0xFF1B5E20)
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                account.accountName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                account.accountNumber,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Payment method selection
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              value: 'bank_transfer',
              title: 'Direct Bank Transfer',
              subtitle: 'Transfer to government account directly',
              icon: Icons.account_balance,
              color: const Color(0xFF4CAF50),
            ),
            _buildPaymentMethodTile(
              value: 'remita',
              title: 'Remita',
              subtitle: 'Pay via Remita platform',
              icon: Icons.payment,
              color: const Color(0xFF1565C0),
            ),
            _buildPaymentMethodTile(
              value: 'flutterwave',
              title: 'Flutterwave',
              subtitle: 'Multiple payment options',
              icon: Icons.flash_on,
              color: const Color(0xFFF57C00),
            ),
            _buildPaymentMethodTile(
              value: 'paystack',
              title: 'Paystack',
              subtitle: 'Card, bank transfer, USSD',
              icon: Icons.credit_card,
              color: const Color(0xFF00897B),
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
                  backgroundColor: Colors.green,
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
