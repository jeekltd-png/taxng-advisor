import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:taxng_advisor/services/subscription_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/models/pricing_tier.dart';
import 'package:taxng_advisor/services/pricing_service.dart';
import 'package:taxng_advisor/services/paystack_service.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';

/// Screen for users to upgrade their subscription tier
class UpgradeRequestScreen extends StatefulWidget {
  const UpgradeRequestScreen({super.key});

  @override
  State<UpgradeRequestScreen> createState() => _UpgradeRequestScreenState();
}

class _UpgradeRequestScreenState extends State<UpgradeRequestScreen> {
  String? _selectedTier;
  BillingCycle _selectedCycle = BillingCycle.monthly;
  bool _isSubmitting = false;
  bool _hasPending = false;
  String _currentTier = 'free';
  List<PricingTier> _tiers = [];

  // Payment proof fields
  File? _paymentProofFile;
  String? _paymentProofPath;
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _amountPaidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await AuthService.currentUser();
    if (user == null) return;

    final hasPending = await SubscriptionService.hasPendingRequest(user.id);
    final tiers = PricingService.getTiers();

    setState(() {
      _currentTier = user.subscriptionTier;
      _hasPending = hasPending;
      _tiers = tiers;
    });
  }

  // TODO: Implement Paystack payment integration for instant upgrades
  // For now, manual payment workflow with proof upload is available

  Future<void> _pickPaymentProof() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _paymentProofPath = result.files.single.path;
          _paymentProofFile = File(result.files.single.path!);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('✅ Payment proof selected: ${result.files.single.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitManualRequest() async {
    if (_selectedTier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tier')),
      );
      return;
    }

    // Validate payment proof is provided
    if (_paymentProofPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please upload payment proof (receipt/screenshot)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate payment details
    if (_amountPaidController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter the amount you paid'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = await AuthService.currentUser();
      if (user == null) throw Exception('User not found');

      final amountPaid = double.tryParse(_amountPaidController.text);
      final billingCycleName = PricingTier.getCycleDisplayName(_selectedCycle);

      // Submit upgrade request with payment proof and billing cycle
      await SubscriptionService.submitUpgradeRequest(
        userId: user.id,
        currentTier: user.subscriptionTier,
        requestedTier: _selectedTier!,
        email: user.email,
        paymentReference: null, // No paystack reference
        paymentProofPath: _paymentProofPath,
        bankName: _bankNameController.text.isNotEmpty
            ? _bankNameController.text
            : null,
        accountNumber: _accountNumberController.text.isNotEmpty
            ? _accountNumberController.text
            : null,
        amountPaid: amountPaid,
        notes: _notesController.text.isNotEmpty
            ? '${_notesController.text}\n[Billing: $billingCycleName]'
            : '[Billing: $billingCycleName]',
        billingCycle: billingCycleName,
      );

      if (mounted) {
        final trialDays = PaystackService.getTrialDays(_selectedTier!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Request submitted! ${trialDays > 0 ? 'Your $trialDays-day free trial starts after admin approval. ' : ''}Admin will review and activate your subscription within 24-48 hours.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'individual':
        return Colors.blue;
      case 'business':
        return Colors.orange;
      case 'enterprise':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Format price with thousands separator
  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TaxNGAppBar(
        title: 'Upgrade Subscription',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current tier card
            Card(
              color: _getTierColor(_currentTier).withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: _getTierColor(_currentTier),
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Plan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            SubscriptionService.getTierDisplayName(
                                _currentTier),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getTierColor(_currentTier),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pending request notice
            if (_hasPending)
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.pending, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You have a pending upgrade request. Admin will review it shortly.',
                          style: TextStyle(color: Colors.orange[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_hasPending) ...[
              const Text(
                'Select Billing Cycle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Save up to 20% with longer billing cycles',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Billing Cycle Selector
              Row(
                children: BillingCycle.values.map((cycle) {
                  final isSelected = _selectedCycle == cycle;
                  final discount = cycle == BillingCycle.monthly
                      ? 0
                      : cycle == BillingCycle.quarterly
                          ? 10
                          : 20;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCycle = cycle),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green[700]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.green[900]!, width: 2)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                PricingTier.getCycleDisplayName(cycle),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              if (discount > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.green[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Save $discount%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              const Text(
                'Select Your New Plan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'All paid plans include a 14-day free trial',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Tier selection
              ..._tiers
                  .where((t) => t.name.toLowerCase() != _currentTier)
                  .map((tier) {
                final tierKey = tier.name.toLowerCase();
                final isSelected = _selectedTier == tierKey;
                final cyclePrice = PaystackService.calculatePriceForCycle(
                    tierKey, _selectedCycle);
                final savings =
                    PaystackService.getSavings(tierKey, _selectedCycle);
                final trialDays = PaystackService.getTrialDays(tierKey);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTier = tierKey),
                    child: Card(
                      elevation: isSelected ? 8 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? _getTierColor(tierKey)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  value: tierKey,
                                  groupValue: _selectedTier,
                                  onChanged: (value) =>
                                      setState(() => _selectedTier = value),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            tier.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: _getTierColor(tierKey),
                                            ),
                                          ),
                                          if (tier.isPopular) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getTierColor(tierKey),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'POPULAR',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (trialDays > 0) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[100],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '$trialDays-day trial',
                                                style: TextStyle(
                                                  color: Colors.blue[800],
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₦${_formatPrice(cyclePrice)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            PricingTier.getCyclePeriod(
                                                _selectedCycle),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (savings > 0) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Save ₦${_formatPrice(savings)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...tier.features.take(3).map((feature) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: _getTierColor(tierKey),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (tier.features.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '+ ${tier.features.length - 3} more features',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Payment Details Section
              const Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload payment proof after making the transfer',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Payment Proof Upload
              Card(
                elevation: _paymentProofFile != null ? 4 : 2,
                color: _paymentProofFile != null ? Colors.green[50] : null,
                child: InkWell(
                  onTap: _pickPaymentProof,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          _paymentProofFile != null
                              ? Icons.check_circle
                              : Icons.upload_file,
                          color: _paymentProofFile != null
                              ? Colors.green
                              : Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _paymentProofFile != null
                                    ? '✅ Payment Proof Uploaded'
                                    : 'Upload Payment Proof *',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _paymentProofFile != null
                                      ? Colors.green[900]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _paymentProofFile != null
                                    ? _paymentProofFile!.path.split('/').last
                                    : 'Receipt, screenshot, or bank confirmation',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Amount Paid
              TextField(
                controller: _amountPaidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount Paid (₦) *',
                  hintText: 'Enter amount you transferred',
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // Bank Name (Optional)
              TextField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name (Optional)',
                  hintText: 'e.g., Access Bank, GTBank',
                  prefixIcon: Icon(Icons.account_balance),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // Account Number last 4 digits (Optional)
              TextField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Account Number (Optional)',
                  hintText: 'Last 4 digits of your account',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 12),

              // Notes (Optional)
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'Any additional payment details...',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Payment option button (Manual payment only for now)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitManualRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.verified, size: 20),
                  label: const Text(
                    'Submit with Payment Proof',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Secure Payment Verification Process',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Make payment to the provided account\n'
                        '2. Upload payment proof (receipt/screenshot)\n'
                        '3. Admin verifies payment (24-48 hours)\n'
                        '4. Subscription activated immediately after verification\n\n'
                        '⚠️ Only submit after you\'ve made the payment!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
