import 'package:flutter/material.dart';

/// Banner widget to show subscription restrictions to free users
class SubscriptionRestrictionBanner extends StatelessWidget {
  final bool showBanner;
  final VoidCallback onUpgrade;

  const SubscriptionRestrictionBanner({
    super.key,
    required this.showBanner,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBanner) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[50]!, Colors.orange[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.orange[900], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Plan - View Only',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can only use "Example Data" to explore the calculator',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Custom data entry, PDF export, Share, and Save features require upgrading',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
