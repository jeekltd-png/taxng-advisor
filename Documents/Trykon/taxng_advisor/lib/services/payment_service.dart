import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

/// Payment model for storing payment records
class PaymentRecord {
  final String id;
  final String userId;
  final String taxType;
  final double amount;
  final String email;
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

  /// Government tax agent accounts
  static List<GovTaxAccount> get govTaxAccounts => [
        GovTaxAccount(
          bankName: 'First Bank of Nigeria',
          accountName: 'Federal Board of Inland Revenue',
          accountNumber: '1234567890',
          bankCode: '011',
          description: 'Federal tax payments (CIT, VAT, WHT)',
        ),
        GovTaxAccount(
          bankName: 'GTBank',
          accountName: 'Federal Board of Inland Revenue',
          accountNumber: '0987654321',
          bankCode: '058',
          description: 'Federal tax payments (CIT, VAT, WHT)',
        ),
        GovTaxAccount(
          bankName: 'Zenith Bank',
          accountName: 'State Internal Revenue Service',
          accountNumber: '1111222233',
          bankCode: '057',
          description: 'State PIT and Stamp Duty payments',
        ),
      ];

  static Future<Box> _openPaymentsBox() async {
    if (!Hive.isBoxOpen(_paymentsBox)) return await Hive.openBox(_paymentsBox);
    return Hive.box(_paymentsBox);
  }

  static Future<void> init() async {
    await _openPaymentsBox();
  }

  static Future<void> savePayment({
    required String userId,
    required String taxType,
    required double amount,
    required String email,
    String paymentMethod = 'bank_transfer',
    String? referenceId,
    GovTaxAccount? taxAccount,
  }) async {
    final box = await _openPaymentsBox();
    final id = 'pay_${DateTime.now().millisecondsSinceEpoch}';

    final record = {
      'id': id,
      'userId': userId,
      'taxType': taxType,
      'amount': amount,
      'email': email,
      'currency': 'NGN',
      'paymentMethod': paymentMethod,
      'status': 'success',
      'paidAt': DateTime.now().toIso8601String(),
      'referenceId': referenceId,
      'bankAccount': taxAccount?.accountNumber,
      'bankName': taxAccount?.bankName,
    };

    await box.put(id, record);
    await sendConfirmationEmail(email: email, taxType: taxType, amount: amount);
  }

  static Future<void> sendConfirmationEmail({
    required String email,
    required String taxType,
    required double amount,
  }) async {
    final subject = Uri.encodeComponent('Tax Payment Confirmation - $taxType');
    final body = Uri.encodeComponent(
        'This confirms that a payment of ₦${amount.toStringAsFixed(2)} for $taxType has been recorded in TaxNG Advisor.\n\nPlease retain this confirmation for your records.');
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
}
