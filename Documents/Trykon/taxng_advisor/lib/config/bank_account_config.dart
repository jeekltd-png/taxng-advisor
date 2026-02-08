/// Bank Account Configuration for Direct Transfer Payments
///
/// ⚠️ ADMIN ONLY - This configuration contains sensitive bank account details
/// This file should be protected and only accessible to administrators.
///
/// SECURITY NOTES:
/// - Only display these details to authenticated users making payments
/// - Never expose this information in public APIs
/// - Regularly audit access to this configuration
/// - Update account details through secure admin panel only
///
/// This configuration contains TaxPadi's official bank account details
/// where users can make direct transfers for subscription payments.
class BankAccountConfig {
  /// Primary bank account for NGN payments
  static const String primaryBankName = 'Access Bank';
  static const String primaryAccountNumber = '0123456789';
  static const String primaryAccountName = 'TaxPadi Limited';

  /// Alternative bank account (optional)
  static const String alternateBankName = 'GTBank';
  static const String alternateAccountNumber = '0987654321';
  static const String alternateAccountName = 'TaxPadi Limited';

  /// Payment instructions
  static const String paymentInstructions =
      'Make a direct bank transfer to any of the accounts above. '
      'After payment, upload your payment receipt or screenshot for verification. '
      'Your subscription will be activated within 24-48 hours after admin verification.';

  /// Important notes
  static const List<String> importantNotes = [
    'Use your registered email as payment reference if possible',
    'Keep your payment receipt/confirmation for upload',
    'Contact support if payment is not reflected within 48 hours',
    'Ensure the amount matches your selected subscription tier',
  ];

  /// Payment verification timeframe
  static const String verificationTimeframe = '24-48 hours';

  /// Support contact
  static const String supportEmail = 'support@taxpadi.com';
  static const String supportPhone = '+234 XXX XXX XXXX';

  /// Get all bank accounts as a list
  ///
  /// ⚠️ ADMIN ACCESS RECOMMENDED
  /// This method returns sensitive bank account information.
  /// Should only be called in authenticated contexts where user is making payment.
  static List<Map<String, String>> getBankAccounts() {
    final accounts = <Map<String, String>>[];

    // Add primary account
    accounts.add({
      'bankName': primaryBankName,
      'accountNumber': primaryAccountNumber,
      'accountName': primaryAccountName,
      'isPrimary': 'true',
    });

    // Add alternate account if exists
    if (alternateAccountNumber != null) {
      accounts.add({
        'bankName': alternateBankName,
        'accountNumber': alternateAccountNumber,
        'accountName': alternateAccountName,
        'isPrimary': 'false',
      });
    }

    return accounts;
  }
}
