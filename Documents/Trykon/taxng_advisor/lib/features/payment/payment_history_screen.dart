import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/payment_service.dart';
import 'package:intl/intl.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';

/// Payment History Screen - View all past payments
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late Future<List<PaymentRecord>> _paymentsFuture;
  String _selectedFilter = 'all'; // all, success, pending, failed

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    _paymentsFuture = _getPayments();
  }

  Future<List<PaymentRecord>> _getPayments() async {
    final user = await AuthService.currentUser();
    if (user == null) return [];
    final allPayments = await PaymentService.getPaymentHistory(user.id);

    // Apply filter
    if (_selectedFilter == 'all') return allPayments;
    return allPayments.where((p) => p.status == _selectedFilter).toList();
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'remita':
        return 'Remita';
      case 'flutterwave':
        return 'Flutterwave';
      case 'paystack':
        return 'Paystack';
      default:
        return method;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.hourglass_top;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TaxNGAppBar(
        title: 'Payment History',
        additionalActions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
                _loadPayments();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Payments')),
              const PopupMenuItem(value: 'success', child: Text('✓ Success')),
              const PopupMenuItem(value: 'pending', child: Text('⌛ Pending')),
              const PopupMenuItem(value: 'failed', child: Text('✗ Failed')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<PaymentRecord>>(
        future: _paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No payments yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculate a tax and pay to see payment history',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          // Calculate total paid
          final totalPaid = payments
              .where((p) => p.status == 'success')
              .fold(0.0, (sum, p) => sum + p.amount);

          return CustomScrollView(
            slivers: [
              // Summary card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.deepPurple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Paid',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₦${totalPaid.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${payments.where((p) => p.status == 'success').length} successful payment(s)',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Payment list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final payment = payments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            _getStatusIcon(payment.status),
                            color: _getStatusColor(payment.status),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                payment.taxType,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                '₦${payment.amount.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                _getPaymentMethodLabel(payment.paymentMethod),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a')
                                    .format(payment.paidAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              if (payment.status != 'success')
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Chip(
                                    label: Text(payment.status.toUpperCase()),
                                    backgroundColor:
                                        _getStatusColor(payment.status)
                                            .withValues(alpha: 0.2),
                                    labelStyle: TextStyle(
                                      color: _getStatusColor(payment.status),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            _showPaymentDetails(context, payment);
                          },
                        ),
                      ),
                    );
                  },
                  childCount: payments.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPaymentDetails(BuildContext context, PaymentRecord payment) async {
    final user = await AuthService.currentUser();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow('Tax Type', payment.taxType),
              _buildDetailRow(
                'Amount',
                '₦${payment.amount.toStringAsFixed(2)}',
                isHighlight: true,
              ),
              _buildDetailRow(
                  'Method', _getPaymentMethodLabel(payment.paymentMethod)),
              _buildDetailRow(
                'Status',
                payment.status.toUpperCase(),
                color: _getStatusColor(payment.status),
              ),
              _buildDetailRow(
                'Date',
                DateFormat('MMMM dd, yyyy • hh:mm a').format(payment.paidAt),
              ),
              if (payment.bankName != null)
                _buildDetailRow('Bank', payment.bankName!),
              if (payment.bankAccount != null)
                _buildDetailRow('Account', payment.bankAccount!),
              if (payment.referenceId != null)
                _buildDetailRow('Reference ID', payment.referenceId!),
              const SizedBox(height: 16),

              // Download/Share PDF button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      Navigator.pop(context); // Close modal first

                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Generating PDF receipt...'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      await PaymentService.sharePdfReceipt(
                        taxType: payment.taxType,
                        amount: payment.amount,
                        currency: payment.currency,
                        referenceId: payment.referenceId ?? payment.id,
                        paymentMethod:
                            _getPaymentMethodLabel(payment.paymentMethod),
                        bankName: payment.bankName,
                        accountNumber: payment.bankAccount,
                        tin: payment.tin,
                        userName: user?.username ?? 'Taxpayer',
                        userEmail: payment.email,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ PDF receipt ready to share!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error generating PDF: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Download PDF Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlight = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
