import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/usage_tracker.dart';

/// Mixin that adds free-plan usage checking to calculator State classes.
///
/// Before performing a calculation with real (custom) data, call
/// [checkFreeUsageAndProceed]. It shows pre/post notifications and blocks
/// the user when they exceed [UsageTracker.maxFreeUses].
mixin FreeUsageGateMixin<T extends StatefulWidget> on State<T> {
  /// Returns `true` if the calculation should proceed.
  /// [calculatorType] — e.g. 'VAT', 'CIT', 'PIT'.
  /// [isExampleData] — pass `true` when the user chose the example/dummy data path.
  Future<bool> checkFreeUsageAndProceed(
    String calculatorType, {
    required bool isExampleData,
  }) async {
    // Example-data uses are always allowed.
    if (isExampleData) return true;

    final user = await AuthService.currentUser();
    if (user == null) return true; // shouldn't happen, but don't block
    if (user.subscriptionTier != 'free') return true; // paid users pass

    final userId = user.id;

    // Already exhausted?
    if (!UsageTracker.hasRemainingUses(userId, calculatorType)) {
      if (mounted) _showUpgradeBlockDialog();
      return false;
    }

    // Pre-notification: tell user how many remain
    final remaining = UsageTracker.remainingUses(userId, calculatorType);
    if (remaining <= UsageTracker.maxFreeUses) {
      // Show a SnackBar before calculation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Free plan: $remaining calculation${remaining == 1 ? '' : 's'} remaining with real data'),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    // Record usage
    final newCount = await UsageTracker.recordUsage(userId, calculatorType);

    // Post-notification: if last use, show warning dialog
    if (newCount >= UsageTracker.maxFreeUses && mounted) {
      // Show after a slight delay so the result renders first
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _showPostLimitDialog();
      });
    }

    return true;
  }

  void _showUpgradeBlockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock, color: Colors.orange, size: 40),
        title: const Text('Free Limit Reached'),
        content: const Text(
          'You have used all free real-data calculations.\n\n'
          'Upgrade your plan for unlimited calculations, PDF export, '
          'save & share features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/subscription/upgrade');
            },
            icon: const Icon(Icons.upgrade),
            label: const Text('Upgrade Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showPostLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.orange, size: 40),
        title: const Text('Free Calculations Used Up'),
        content: const Text(
          'You have now used all your free real-data calculations.\n\n'
          'You can still explore with Example Data. '
          'Upgrade for unlimited access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/subscription/upgrade');
            },
            icon: const Icon(Icons.upgrade),
            label: const Text('Upgrade Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
