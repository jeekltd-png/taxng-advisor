import 'package:flutter/material.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';

/// Widget to display tax amount in multiple currencies
class CurrencyConverterWidget extends StatefulWidget {
  final double nairaAmount;
  final String label;
  final Color? color;
  final bool isBold;

  const CurrencyConverterWidget({
    super.key,
    required this.nairaAmount,
    this.label = 'Tax Amount',
    this.color,
    this.isBold = false,
  });

  @override
  State<CurrencyConverterWidget> createState() =>
      _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  bool _showConversion = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main amount in Naira
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        widget.isBold ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatCurrency(widget.nairaAmount),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        widget.isBold ? FontWeight.bold : FontWeight.w500,
                    color: widget.color,
                  ),
                ),
              ],
            ),
            // Expandable conversion section
            if (_showConversion) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              const Text(
                'Currency Conversion:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              // USD from Naira
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Equivalent in USD (from NGN):',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    CurrencyFormatter.formatNairaToUsd(widget.nairaAmount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // USD from Pounds (conversion reference)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'If in GBP, USD equivalent would be:',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    CurrencyFormatter.formatPoundsToUsd(
                        widget.nairaAmount * 0.79), // NGN to GBP approximation
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Conversion rate info
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Exchange Rates: 1 NGN = \$0.00065 | 1 GBP = \$1.27',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
            // Toggle button
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () =>
                    setState(() => _showConversion = !_showConversion),
                icon: Icon(
                  _showConversion ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                label: Text(
                  _showConversion ? 'Hide Conversion' : 'Show Conversion',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple currency conversion card (non-expandable)
class CurrencyConversionCard extends StatelessWidget {
  final double nairaAmount;
  final String title;

  const CurrencyConversionCard({
    super.key,
    required this.nairaAmount,
    this.title = 'Tax Amount Conversion',
  });

  @override
  Widget build(BuildContext context) {
    final gbpEquivalent = nairaAmount * 0.79;
    final usdFromNGN = CurrencyFormatter.formatNairaToUsd(nairaAmount);
    final usdFromGBP = CurrencyFormatter.formatPoundsToUsd(gbpEquivalent);

    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            // NGN amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Amount (NGN):',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  CurrencyFormatter.formatCurrency(nairaAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            // USD from Naira
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'USD Equivalent (from NGN):',
                  style: TextStyle(fontSize: 13, color: Colors.blue),
                ),
                Text(
                  usdFromNGN,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // GBP equivalent reference
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GBP Equivalent (reference):',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '£${CurrencyFormatter.formatNumber(gbpEquivalent)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // USD from GBP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'USD Equivalent (if GBP):',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
                Text(
                  usdFromGBP,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '📌 Exchange Rates: 1 NGN = \$0.00065 | 1 GBP = \$1.27',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
