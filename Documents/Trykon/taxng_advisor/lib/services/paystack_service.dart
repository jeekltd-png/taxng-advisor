import 'package:flutter/material.dart';
// import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:taxng_advisor/models/user.dart';

/// Service for handling Paystack payment processing
/// CURRENTLY DISABLED - Using manual payment only due to package compatibility issues
class PaystackService {
  // TODO: Replace with your actual Paystack public key from dashboard
  static const String _publicKey = 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

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

  /// Verify payment transaction on backend
  /// In production, this should call your backend API to verify with Paystack
  static Future<bool> verifyTransaction(String reference) async {
    try {
      // TODO: In production, call your backend API:
      // final response = await http.get(
      //   Uri.parse('https://your-backend.com/verify-payment/$reference'),
      // );
      // return response.statusCode == 200 && json.decode(response.body)['status'] == 'success';

      // For now, assume payment is verified if we have a reference
      // This is NOT secure for production - must verify on backend!
      return reference.isNotEmpty;
    } catch (e) {
      debugPrint('Payment verification error: $e');
      return false;
    }
  }

  /// Generate unique payment reference
  static String _generateReference(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TAXNG_${userId}_$timestamp';
  }

  /// Get tier price in Naira
  static double getTierPrice(String tierName) {
    switch (tierName.toLowerCase()) {
      case 'basic':
        return 500.0;
      case 'pro':
        return 2000.0;
      case 'business':
        return 8000.0;
      default:
        return 0.0;
    }
  }

  /// Calculate monthly price (for annual plans, divide by 12)
  static double calculateMonthlyPrice(String tierName,
      {bool isAnnual = false}) {
    final basePrice = getTierPrice(tierName);
    if (isAnnual) {
      // Offer 20% discount for annual payment
      return (basePrice * 12 * 0.8);
    }
    return basePrice;
  }
}
