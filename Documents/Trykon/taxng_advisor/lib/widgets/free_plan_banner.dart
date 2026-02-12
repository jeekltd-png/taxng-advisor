import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/usage_tracker.dart';

/// Displays a "Free Plan – View Only" banner at the top of each calculator
/// screen when the logged-in user is on the free tier (or not logged in).
///
/// Shows remaining real-data uses and an Upgrade button.
class FreePlanBanner extends StatefulWidget {
  final String calculatorType; // e.g. 'VAT', 'CIT', 'PIT'

  const FreePlanBanner({super.key, required this.calculatorType});

  @override
  State<FreePlanBanner> createState() => _FreePlanBannerState();
}

class _FreePlanBannerState extends State<FreePlanBanner> {
  String? _tier;
  String? _userId;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await AuthService.currentUser();
      if (!mounted) return;
      setState(() {
        _tier = user?.subscriptionTier ?? 'free';
        _userId = user?.id ?? 'anonymous';
        _loaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tier = 'free';
        _userId = 'anonymous';
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    if (_tier != 'free') return const SizedBox.shrink();

    final remaining =
        UsageTracker.remainingUses(_userId!, widget.calculatorType);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(Icons.lock_outline,
                    color: Colors.orange.shade800, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Free Plan - View Only',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              remaining > 0
                  ? 'You can try $remaining more calculation${remaining == 1 ? '' : 's'} with real data. '
                      'Use "Example Data" to explore the calculator.'
                  : 'You have used all free calculations. '
                      'Use "Example Data" to explore or upgrade for unlimited use.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Custom data entry, PDF export, Share, and Save features require upgrading',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Upgrade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/subscription/upgrade'),
                icon: const Icon(Icons.upgrade, size: 20),
                label: const Text('Upgrade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
