import 'package:flutter/material.dart';
import 'package:taxng_advisor/models/user.dart';
import 'package:taxng_advisor/models/pricing_tier.dart';
import 'package:taxng_advisor/services/backend_service.dart';

/// Service for handling Paystack payment processing.
///
/// IMPORTANT: The Paystack SECRET key must NEVER be in client code.
/// All payment verification MUST go through the backend server.
class PaystackService {
  // Paystack public key from environment variable (set at build time)
  // Usage: flutter build --dart-define=PAYSTACK_PUBLIC_KEY=pk_live_xxx
  static const String _publicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: '',
  );

  /// Check if Paystack is configured for production
  static bool get isConfigured =>
      _publicKey.isNotEmpty && _publicKey.startsWith('pk_live_');

  /// Initialize Paystack with public key
  static Future<void> initialize() async {
    // PaystackPayManager().initialize(publicKey: _publicKey);
  }

  /// Process subscription payment
  /// Returns transaction reference if successful, null if failed/cancelled
  static Future<String?> processSubscriptionPayment({
    required BuildContext context,
    required UserProfile user,
    required String tierName,
    required double amount,
  }) async {
    // Paystack integration disabled - using manual payment flow
    return null;
    /*
    try {
      final reference = _generateReference(user.id);
      
      final response = await PaystackPayManager().checkout(
        context,
        charge: ChargeCard(
          email: user.email,
          amount: (amount * 100).toInt(), // Convert to kobo
          reference: reference,
          currency: Currency.ngn,
          metadata: {
            'userId': user.id,
            'currentTier': user.subscriptionTier,
            'requestedTier': tierName,
            'custom_fields': [
              {
                'display_name': 'User ID',
                'variable_name': 'user_id',
                'value': user.id,
              },
              {
                'display_name': 'Subscription Tier',
                'variable_name': 'tier',
                'value': tierName,
              },
            ],
          },
        ),
        method: CheckoutMethod.card,
        fullscreen: false,
        logo: Container(
          height: 60,
          child: Image.asset('assets/icon.png'),
        ),
      );
    } catch (e) {
      debugPrint('Paystack payment error: $e');
      return null;
    }
    */
  }

  /// Verify payment transaction via backend server.
  /// The backend calls Paystack's verify endpoint using the SECRET key.
  /// NEVER verify payments client-side — always use server-side verification.
  static Future<PaymentVerificationResult> verifyTransaction(
      String reference) async {
    if (reference.isEmpty) {
      return PaymentVerificationResult(
        verified: false,
        message: 'No payment reference provided',
      );
    }

    try {
      final result = await BackendService.verifyPayment(reference);
      return result;
    } catch (e) {
      debugPrint('Payment verification error: $e');
      return PaymentVerificationResult(
        verified: false,
        message: 'Verification failed: $e',
        requiresManualReview: true,
      );
    }
  }

  /// Generate unique payment reference
  static String generateReference(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TAXNG_${userId}_$timestamp';
  }

  /// Get tier base monthly price in Naira
  static double getTierPrice(String tierName) {
    switch (tierName.toLowerCase()) {
      case 'individual':
        return 2000.0; // Reduced from ₦3,000 for Nigerian market
      case 'business':
        return 12000.0;
      case 'enterprise':
        return 50000.0;
      default:
        return 0.0;
    }
  }

  /// Calculate price based on billing cycle
  /// - Monthly: Full price
  /// - Quarterly: 10% discount
  /// - Annual: 20% discount
  static double calculatePriceForCycle(String tierName, BillingCycle cycle) {
    final basePrice = getTierPrice(tierName);
    switch (cycle) {
      case BillingCycle.monthly:
        return basePrice;
      case BillingCycle.quarterly:
        return basePrice * 3 * 0.90; // 10% discount
      case BillingCycle.annual:
        return basePrice * 12 * 0.80; // 20% discount
    }
  }

  /// Get savings for a billing cycle
  static double getSavings(String tierName, BillingCycle cycle) {
    final basePrice = getTierPrice(tierName);
    final months = cycle == BillingCycle.monthly
        ? 1
        : cycle == BillingCycle.quarterly
            ? 3
            : 12;
    final fullPrice = basePrice * months;
    final discountedPrice = calculatePriceForCycle(tierName, cycle);
    return fullPrice - discountedPrice;
  }

  /// Calculate monthly price (for annual plans, divide by 12)
  static double calculateMonthlyPrice(String tierName,
      {bool isAnnual = false}) {
    final basePrice = getTierPrice(tierName);
    if (isAnnual) {
      // 20% off for annual = effective monthly rate
      return basePrice * 0.80;
    }
    return basePrice;
  }

  /// Get free trial days for a tier
  static int getTrialDays(String tierName) {
    switch (tierName.toLowerCase()) {
      case 'individual':
      case 'business':
      case 'enterprise':
        return 14; // 14-day free trial for all paid tiers
      default:
        return 0;
    }
  }
}
