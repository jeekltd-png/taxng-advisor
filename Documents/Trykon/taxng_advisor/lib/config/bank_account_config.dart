/// Bank Account Configuration for Direct Transfer Payments
///
/// ⚠️ SECURITY: Bank account details are fetched from the backend API.
/// The placeholder values below are ONLY used as a fallback when the
/// backend is unavailable. In production, always fetch from the server.
///
/// IMPORTANT: Real bank account numbers must NEVER be hardcoded in
/// client-side code. They should be served by a secure backend API.
library;

import 'package:taxng_advisor/services/backend_service.dart';

class BankAccountConfig {
  /// Cached bank accounts from backend
  static List<Map<String, String>>? _cachedAccounts;

  /// Fetch bank accounts from backend, with local fallback
  static Future<List<Map<String, String>>> getBankAccounts() async {
    // Try to fetch from backend first
    if (_cachedAccounts == null) {
      final remoteAccounts = await BackendService.fetchBankAccounts();
      if (remoteAccounts != null && remoteAccounts.isNotEmpty) {
        _cachedAccounts = remoteAccounts;
        return _cachedAccounts!;
      }
    }

    if (_cachedAccounts != null) return _cachedAccounts!;

    // Fallback — placeholder accounts (replace via backend in production)
    return [
      {
        'bankName': 'Contact support for payment details',
        'accountNumber': '—',
        'accountName': 'TaxPadi Limited',
        'isPrimary': 'true',
      },
    ];
  }

  /// Clear cached accounts (force re-fetch)
  static void clearCache() {
    _cachedAccounts = null;
  }

  // --- Static convenience properties (for UI consumers) ---

  /// Support email (should eventually be fetched from backend)
  static const String supportEmail = 'support@taxpadi.com';

  /// Support phone (should eventually be fetched from backend)
  static const String supportPhone = '+234-XXX-XXXX';

  /// Primary account number placeholder
  static const String primaryAccountNumber = '—';

  /// Alternate account number placeholder
  static const String alternateAccountNumber = '—';

  /// Primary account name
  static const String primaryAccountName = 'TaxPadi Limited';

  /// Payment instructions
  static const String paymentInstructions =
      '1. Transfer the exact subscription amount to any account above.\n'
      '2. Use your username or email as the payment reference.\n'
      '3. After payment, upload your receipt in the app.\n'
      '4. Your subscription will be activated within 24 hours.';

  /// Important notes
  static const List<String> importantNotes = [
    'Ensure the payment reference matches your registered username or email.',
    'Payments are verified within 1-24 business hours.',
    'Contact support if your subscription is not activated within 24 hours.',
    'Screenshots or receipts are required for manual verification.',
  ];
}
