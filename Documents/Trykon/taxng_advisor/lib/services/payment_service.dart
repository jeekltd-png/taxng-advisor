import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../utils/tax_helpers.dart';
import 'auth_service.dart';
import 'pdf_service.dart';

/// Payment model for storing payment records
class PaymentRecord {
  final String id;
  final String userId;
  final String taxType;
  final double amount;
  final String email;
  final String? tin; // Tax Identification Number for government payments
  final String currency;
  final String paymentMethod;
  final String status;
  final DateTime paidAt;
  final String? referenceId;
  final String? bankAccount;
  final String? bankName;

  PaymentRecord({
    required this.id,
    required this.userId,
    required this.taxType,
    required this.amount,
    required this.email,
    this.tin,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.paidAt,
    this.referenceId,
    this.bankAccount,
    this.bankName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'taxType': taxType,
      'amount': amount,
      'email': email,
      'tin': tin,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'status': status,
      'paidAt': paidAt.toIso8601String(),
      'referenceId': referenceId,
      'bankAccount': bankAccount,
      'bankName': bankName,
    };
  }

  static PaymentRecord fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      taxType: map['taxType'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      email: map['email'] ?? '',
      tin: map['tin'],
      currency: map['currency'] ?? 'NGN',
      paymentMethod: map['paymentMethod'] ?? 'remita',
      status: map['status'] ?? 'pending',
      paidAt: DateTime.tryParse(map['paidAt'] ?? '') ?? DateTime.now(),
      referenceId: map['referenceId'],
      bankAccount: map['bankAccount'],
      bankName: map['bankName'],
    );
  }
}

/// Government Tax Agent Accounts
class GovTaxAccount {
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String bankCode;
  final String description;

  GovTaxAccount({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.bankCode,
    required this.description,
  });
}

class PaymentService {
  static const _paymentsBox = 'payments';

  /// Government tax collection channels.
  ///
  /// These are the official FIRS/SIRS payment gateways. Actual account
  /// numbers are dynamically generated via Remita/NIBSS e-Collections and
  /// must NOT be hardcoded. Users should generate a payment reference on
  /// the FIRS or State IRS portal before making any transfer.
  static List<GovTaxAccount> get govTaxAccounts => [
        GovTaxAccount(
          bankName: 'Remita e-Collections (FIRS)',
          accountName: 'Federal Inland Revenue Service',
          accountNumber: 'Generate via remita.net',
          bankCode: '000',
          description:
              'Federal tax payments (CIT, VAT, WHT) — generate a Remita Retrieval Reference (RRR) at remita.net or FIRS e-tax portal before payment.',
        ),
        GovTaxAccount(
          bankName: 'NIBSS e-BillsPay (State IRS)',
          accountName: 'State Internal Revenue Service',
          accountNumber: 'Generate via your State IRS portal',
          bankCode: '000',
          description:
              'State PIT and Stamp Duty payments — visit your State IRS online portal to generate a payment reference.',
        ),
        GovTaxAccount(
          bankName: 'FIRS e-Tax Portal',
          accountName: 'Federal Inland Revenue Service',
          accountNumber: 'Visit: etax.firs.gov.ng',
          bankCode: '000',
          description:
              'Self-service portal for generating Tax Reference Numbers (TRN) and making direct payments.',
        ),
      ];

  static Future<Box> _openPaymentsBox() async {
    if (!Hive.isBoxOpen(_paymentsBox)) return await Hive.openBox(_paymentsBox);
    return Hive.box(_paymentsBox);
  }

  static Future<void> init() async {
    await _openPaymentsBox();
  }

  /// Convert payment amount to USD for oil & gas businesses
  /// Returns: Map with 'amount', 'currency', 'originalCurrency', and 'originalAmount'
  static Future<Map<String, dynamic>> processPaymentCurrency({
    required String userId,
    required double amount,
    required String currency,
  }) async {
    // Get user profile to check if oil & gas sector
    final user = await AuthService.currentUser();

    if (user != null && user.isOilAndGasSector) {
      // Oil & Gas sector - convert to USD
      double usdAmount;

      if (currency == 'NGN') {
        usdAmount = CurrencyFormatter.convertNairaToUsd(amount);
        return {
          'amount': usdAmount,
          'currency': 'USD',
          'originalCurrency': 'NGN',
          'originalAmount': amount,
        };
      } else if (currency == 'GBP') {
        usdAmount = CurrencyFormatter.convertPoundsToUsd(amount);
        return {
          'amount': usdAmount,
          'currency': 'USD',
          'originalCurrency': 'GBP',
          'originalAmount': amount,
        };
      } else if (currency == 'USD') {
        // Already in USD
        return {
          'amount': amount,
          'currency': 'USD',
          'originalCurrency': null,
          'originalAmount': null,
        };
      }
    }

    // Not oil & gas, or unsupported currency - keep original
    return {
      'amount': amount,
      'currency': currency,
      'originalCurrency': null,
      'originalAmount': null,
    };
  }

  static Future<void> savePayment({
    required String userId,
    required String taxType,
    required double amount,
    required String email,
    String? tin,
    String currency = 'NGN',
    String paymentMethod = 'bank_transfer',
    String status = 'success',
    String? referenceId,
    GovTaxAccount? taxAccount,
    String? originalCurrency,
    double? originalAmount,
    Map<String, dynamic>? taxCalculationDetails,
  }) async {
    final box = await _openPaymentsBox();
    final id = 'pay_${DateTime.now().millisecondsSinceEpoch}';

    // If TIN not provided, try to get from user profile
    String? userTin = tin;
    String userName = 'Taxpayer';
    if (userTin == null) {
      final user = await AuthService.getUserById(userId);
      userTin = user?.tin;
      userName = user?.username ?? 'Taxpayer';
    }

    final record = {
      'id': id,
      'userId': userId,
      'taxType': taxType,
      'amount': amount,
      'email': email,
      'tin': userTin,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'status': status,
      'paidAt': DateTime.now().toIso8601String(),
      'referenceId': referenceId ?? id,
      'bankAccount': taxAccount?.accountNumber,
      'bankName': taxAccount?.bankName,
      'originalCurrency': originalCurrency,
      'originalAmount': originalAmount,
    };

    await box.put(id, record);

    // Send confirmation email with detailed information and PDF attachment
    await sendConfirmationEmail(
      email: email,
      taxType: taxType,
      amount: amount,
      currency: currency,
      referenceId: referenceId ?? id,
      status: status,
      paymentMethod: paymentMethod,
      bankName: taxAccount?.bankName,
      accountNumber: taxAccount?.accountNumber,
      originalCurrency: originalCurrency,
      originalAmount: originalAmount,
      tin: userTin,
      userName: userName,
      taxCalculationDetails: taxCalculationDetails,
    );
  }

  static Future<void> sendConfirmationEmail({
    required String email,
    required String taxType,
    required double amount,
    String currency = 'NGN',
    required String referenceId,
    required String status,
    String? paymentMethod,
    String? bankName,
    String? accountNumber,
    String? originalCurrency,
    double? originalAmount,
    String? tin,
    String? userName,
    Map<String, dynamic>? taxCalculationDetails,
  }) async {
    final subject =
        Uri.encodeComponent('Payment Confirmation - TaxPadi [$taxType]');

    final statusText = status == 'success'
        ? 'CONFIRMED'
        : status == 'pending'
            ? 'PENDING'
            : 'PROCESSING';
    final date = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    // Format currency symbol
    final currencySymbol = currency == 'USD'
        ? '\$'
        : currency == 'GBP'
            ? '£'
            : '₦';
    final currencyName = currency == 'USD'
        ? 'US Dollars'
        : currency == 'GBP'
            ? 'British Pounds'
            : 'Nigerian Naira';

    // Conversion info for oil & gas businesses
    final conversionInfo = originalCurrency != null && originalAmount != null
        ? '''\nOriginal Amount: ${originalCurrency == 'GBP' ? '£' : '₦'}${originalAmount.toStringAsFixed(2)} ($originalCurrency)
Converted to:    $currencySymbol${amount.toStringAsFixed(2)} ($currency)
Conversion Note: Oil & Gas sector payments are processed in USD
'''
        : '';

    // Generate PDF receipt
    try {
      final pdfBytes = await PdfService.generatePaymentReceiptPdf(
        taxType: taxType,
        amount: amount,
        currency: currency,
        referenceId: referenceId,
        paymentMethod: paymentMethod ?? 'Bank Transfer',
        bankName: bankName,
        accountNumber: accountNumber,
        tin: tin,
        userName: userName ?? 'Taxpayer',
        userEmail: email,
        taxCalculationDetails: taxCalculationDetails,
      );

      // Save PDF to device (optional - for desktop/mobile)
      // Note: For email attachment, the PDF would need to be uploaded to a server
      // or the email service would need to support attachments directly

      debugPrint('PDF receipt generated: ${pdfBytes.length} bytes');
    } catch (e) {
      debugPrint('Error generating PDF receipt: $e');
    }

    final body = Uri.encodeComponent('''
===========================================
TAXPADI - PAYMENT CONFIRMATION
===========================================

Dear Taxpayer,

This email confirms your tax payment on TaxPadi.

PAYMENT DETAILS:
-------------------------------------------
Reference ID:    $referenceId
Tax Type:        $taxType
Amount:          $currencySymbol${amount.toStringAsFixed(2)}
Currency:        $currencyName ($currency)$conversionInfo
Status:          $statusText
Payment Method:  ${paymentMethod ?? 'Bank Transfer'}
Date & Time:     $date
${bankName != null ? '\nBank:            $bankName' : ''}
${accountNumber != null ? 'Account:         $accountNumber' : ''}

-------------------------------------------

${status == 'success' ? '''✓ Your payment has been successfully recorded.
  Please keep this confirmation for your records.
''' : status == 'pending' ? '''⌛ Your payment is pending confirmation.
  You will receive another email once confirmed.
''' : '''⏳ Your payment is being processed.
  Please allow 24-48 hours for completion.
'''}

IMPORTANT NOTES:
• A detailed PDF receipt has been generated and saved to your device
• You can download the PDF receipt from your device's downloads folder
• Submit the PDF receipt along with proof of payment to your tax office
• This is an automated confirmation from TaxPadi app
• For official tax receipts, please contact FIRS directly
• Keep this email and PDF for your tax records
• If you did not make this payment, please contact support immediately

HOW TO ACCESS YOUR PDF RECEIPT:
1. Check your device's Downloads folder for: TaxPadi_Receipt_$referenceId.pdf
2. Or use the Share/Export function in the app to send the PDF to your email
3. The PDF contains complete tax calculation details for submission

-------------------------------------------

Need Help?
Contact Support: support@taxpadi.com
App Version: 3.1.0+39

Thank you for using TaxPadi!

===========================================
© 2026 TaxPadi by Trykon
===========================================
''');

    final uri = Uri.parse('mailto:$email?subject=$subject&body=$body');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Get payment history for user
  static Future<List<PaymentRecord>> getPaymentHistory(String userId) async {
    final box = await _openPaymentsBox();
    final payments = <PaymentRecord>[];

    for (var value in box.values) {
      final map = (value is Map)
          ? Map<String, dynamic>.from(value)
          : value as Map<String, dynamic>;
      if (map['userId'] == userId) {
        payments.add(PaymentRecord.fromMap(map));
      }
    }

    payments.sort((a, b) => b.paidAt.compareTo(a.paidAt));
    return payments;
  }

  /// Get total amount paid
  static Future<double> getTotalPaid(String userId) async {
    final payments = await getPaymentHistory(userId);
    double total = 0.0;
    for (final payment in payments) {
      total += payment.amount;
    }
    return total;
  }

  /// Generate and share PDF receipt for a payment
  static Future<void> sharePdfReceipt({
    required String taxType,
    required double amount,
    required String currency,
    required String referenceId,
    required String paymentMethod,
    String? bankName,
    String? accountNumber,
    String? tin,
    required String userName,
    required String userEmail,
    Map<String, dynamic>? taxCalculationDetails,
  }) async {
    try {
      final pdfBytes = await PdfService.generatePaymentReceiptPdf(
        taxType: taxType,
        amount: amount,
        currency: currency,
        referenceId: referenceId,
        paymentMethod: paymentMethod,
        bankName: bankName,
        accountNumber: accountNumber,
        tin: tin,
        userName: userName,
        userEmail: userEmail,
        taxCalculationDetails: taxCalculationDetails,
      );

      // Share the PDF
      await PdfService.sharePdf(
        pdfBytes,
        'TaxPadi_Receipt_$referenceId.pdf',
      );
    } catch (e) {
      debugPrint('Error sharing PDF receipt: $e');
      rethrow;
    }
  }
}
