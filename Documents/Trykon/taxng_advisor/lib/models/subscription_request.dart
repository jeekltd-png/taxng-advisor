/// Payment method enum for subscription payments
enum PaymentMethod {
  paystack, // Online payment via Paystack
  bankTransfer, // Direct bank transfer
  unknown // Legacy or unknown payment method
}

/// Subscription Request Model for Business Tier Upgrades
class SubscriptionRequest {
  final String id;
  final String userId;
  String username; // Added for display
  String email; // Added for display
  final String requestedTier; // 'business'
  String
      status; // 'pending', 'under_review', 'recommended', 'approved', 'rejected', 'on_hold'
  final double amount;
  final String? paymentReference;
  final PaymentMethod paymentMethod; // How user paid
  final String? bankName; // Bank used for transfer (if bank transfer)
  final String? accountNumber; // User's account number (last 4 digits)
  final DateTime createdAt; // Renamed from requestDate for consistency
  String? reviewedBy; // Sub Admin who reviewed (subadmin1)
  String? approvedBy; // Sub Admin who approved (subadmin2 or admin)
  DateTime? reviewedAt;
  DateTime? approvedAt;
  final String? rejectionReason;
  String? subAdmin1Notes;
  String? subAdmin2Notes;
  final List<String> attachments; // Payment proof file names

  SubscriptionRequest({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.requestedTier,
    required this.status,
    required this.amount,
    this.paymentReference,
    this.paymentMethod = PaymentMethod.unknown,
    this.bankName,
    this.accountNumber,
    required this.createdAt,
    this.reviewedBy,
    this.approvedBy,
    this.reviewedAt,
    this.approvedAt,
    this.rejectionReason,
    this.subAdmin1Notes,
    this.subAdmin2Notes,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'email': email,
      'requestedTier': requestedTier,
      'status': status,
      'amount': amount,
      'paymentReference': paymentReference,
      'paymentMethod': paymentMethod.name,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'createdAt': createdAt.toIso8601String(),
      'reviewedBy': reviewedBy,
      'approvedBy': approvedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'subAdmin1Notes': subAdmin1Notes,
      'subAdmin2Notes': subAdmin2Notes,
      'attachments': attachments,
    };
  }

  factory SubscriptionRequest.fromMap(Map<String, dynamic> map) {
    // Parse payment method
    PaymentMethod method = PaymentMethod.unknown;
    if (map['paymentMethod'] != null) {
      final methodStr = map['paymentMethod'] as String;
      try {
        method = PaymentMethod.values.firstWhere(
          (e) => e.name == methodStr,
          orElse: () => PaymentMethod.unknown,
        );
      } catch (_) {
        method = PaymentMethod.unknown;
      }
    }

    return SubscriptionRequest(
      id: map['id'] as String,
      userId: map['userId'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      requestedTier: map['requestedTier'] as String,
      status: map['status'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentReference: map['paymentReference'] as String?,
      paymentMethod: method,
      bankName: map['bankName'] as String?,
      accountNumber: map['accountNumber'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      reviewedBy: map['reviewedBy'] as String?,
      approvedBy: map['approvedBy'] as String?,
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.parse(map['reviewedAt'] as String)
          : null,
      approvedAt: map['approvedAt'] != null
          ? DateTime.parse(map['approvedAt'] as String)
          : null,
      rejectionReason: map['rejectionReason'] as String?,
      subAdmin1Notes: map['subAdmin1Notes'] as String?,
      subAdmin2Notes: map['subAdmin2Notes'] as String?,
      attachments: (map['attachments'] as List?)?.cast<String>() ?? [],
    );
  }

  SubscriptionRequest copyWith({
    String? status,
    String? reviewedBy,
    String? approvedBy,
    DateTime? reviewedAt,
    DateTime? approvedAt,
    String? rejectionReason,
    String? subAdmin1Notes,
    String? subAdmin2Notes,
  }) {
    return SubscriptionRequest(
      id: id,
      userId: userId,
      username: username,
      email: email,
      requestedTier: requestedTier,
      status: status ?? this.status,
      amount: amount,
      paymentReference: paymentReference,
      paymentMethod: paymentMethod,
      bankName: bankName,
      accountNumber: accountNumber,
      createdAt: createdAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      subAdmin1Notes: subAdmin1Notes ?? this.subAdmin1Notes,
      subAdmin2Notes: subAdmin2Notes ?? this.subAdmin2Notes,
      attachments: attachments,
    );
  }
}
