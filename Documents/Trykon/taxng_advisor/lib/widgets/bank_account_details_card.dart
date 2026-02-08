import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/bank_account_config.dart';

/// Widget that displays TaxPadi bank account details for direct transfer payments
///
/// Shows all available bank accounts with copy-to-clipboard functionality
/// and payment instructions.
class BankAccountDetailsCard extends StatelessWidget {
  /// Optional callback when user copies account details
  final VoidCallback? onCopy;

  /// Whether to show payment instructions
  final bool showInstructions;

  /// Whether to show a compact view (less padding, smaller text)
  final bool compact;

  const BankAccountDetailsCard({
    super.key,
    this.onCopy,
    this.showInstructions = true,
    this.compact = false,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $label copied to clipboard'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    onCopy?.call();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = BankAccountConfig.getBankAccounts();
    final padding = compact ? 12.0 : 16.0;
    final titleSize = compact ? 16.0 : 18.0;
    final textSize = compact ? 13.0 : 14.0;

    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: Colors.green[700],
                  size: compact ? 28 : 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bank Transfer Details',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      if (!compact)
                        Text(
                          'Make payment to any account below',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bank Accounts
            ...accounts.map((account) => _buildAccountCard(
                  context,
                  bankName: account['bankName']!,
                  accountNumber: account['accountNumber']!,
                  accountName: account['accountName']!,
                  isPrimary: account['isPrimary'] == 'true',
                  textSize: textSize,
                )),

            if (showInstructions) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Payment Instructions
              Text(
                '📋 Payment Instructions',
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                BankAccountConfig.paymentInstructions,
                style: TextStyle(
                  fontSize: textSize - 1,
                  color: Colors.green[800],
                ),
              ),

              const SizedBox(height: 12),

              // Important Notes
              Text(
                '⚠️ Important',
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
              const SizedBox(height: 8),
              ...BankAccountConfig.importantNotes.map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: textSize,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: textSize - 1,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context, {
    required String bankName,
    required String accountNumber,
    required String accountName,
    required bool isPrimary,
    required double textSize,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? Colors.green : Colors.grey.shade300,
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank Name with Primary Badge
          Row(
            children: [
              Text(
                bankName,
                style: TextStyle(
                  fontSize: textSize + 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              if (isPrimary) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRIMARY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Account Number
          _buildCopyableField(
            context,
            label: 'Account Number',
            value: accountNumber,
            icon: Icons.credit_card,
            textSize: textSize,
          ),

          const SizedBox(height: 8),

          // Account Name
          _buildCopyableField(
            context,
            label: 'Account Name',
            value: accountName,
            icon: Icons.person,
            textSize: textSize,
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableField(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required double textSize,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: textSize - 2,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _copyToClipboard(context, value, label),
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copy $label',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
