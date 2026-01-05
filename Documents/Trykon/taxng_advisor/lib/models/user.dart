class UserProfile {
  final String id;
  final String username;
  final String email;
  final bool isBusiness;
  final String? businessName;
  final String?
      tin; // Tax Identification Number (required for government payments)
  final String?
      cacNumber; // CAC Registration Number (RC Number) - Required for registered businesses
  final String? bvn; // Bank Verification Number - Required for individuals
  final String?
      vatNumber; // VAT Registration Number - Required if turnover > ₦25M
  final String? payeRef; // PAYE Reference Number - For employers with staff
  final String? phoneNumber; // Phone number - Required by FIRS
  final String? address; // Physical address - Required by FIRS
  final String?
      taxOffice; // FIRS Tax Office/Station (e.g., "Lagos Island", "Abuja Wuse")
  final DateTime? tccExpiryDate; // Tax Clearance Certificate expiry date
  final String? industrySector; // Industry sector (e.g., 'oil_and_gas')
  final String
      subscriptionTier; // Subscription tier: 'free', 'basic', 'pro', 'business'
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isAdmin; // Admin can access developer documentation

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.isBusiness,
    this.businessName,
    this.tin,
    this.cacNumber,
    this.bvn,
    this.vatNumber,
    this.payeRef,
    this.phoneNumber,
    this.address,
    this.taxOffice,
    this.tccExpiryDate,
    this.industrySector,
    this.subscriptionTier = 'free',
    required this.createdAt,
    required this.modifiedAt,
    this.isAdmin = false,
  });

  /// Check if business is in oil and gas sector (requires USD payments)
  bool get isOilAndGasSector => industrySector == 'oil_and_gas';

  /// Check if user can access pro features
  bool get isPro => subscriptionTier == 'pro' || subscriptionTier == 'business';

  /// Check if user can access business features
  bool get isBusiness_Tier => subscriptionTier == 'business';

  /// Get reminder limit based on subscription tier
  int get reminderLimit {
    switch (subscriptionTier) {
      case 'free':
        return 3;
      case 'basic':
        return 10;
      default: // pro, business
        return -1; // unlimited
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'isBusiness': isBusiness,
      'businessName': businessName,
      'tin': tin,
      'cacNumber': cacNumber,
      'bvn': bvn,
      'vatNumber': vatNumber,
      'payeRef': payeRef,
      'phoneNumber': phoneNumber,
      'address': address,
      'taxOffice': taxOffice,
      'tccExpiryDate': tccExpiryDate?.toIso8601String(),
      'industrySector': industrySector,
      'subscriptionTier': subscriptionTier,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> m) {
    return UserProfile(
      id: m['id'] as String,
      username: m['username'] as String,
      email: m['email'] as String,
      isBusiness: m['isBusiness'] as bool? ?? false,
      businessName: m['businessName'] as String?,
      tin: m['tin'] as String?,
      cacNumber: m['cacNumber'] as String?,
      bvn: m['bvn'] as String?,
      vatNumber: m['vatNumber'] as String?,
      payeRef: m['payeRef'] as String?,
      phoneNumber: m['phoneNumber'] as String?,
      address: m['address'] as String?,
      taxOffice: m['taxOffice'] as String?,
      tccExpiryDate: m['tccExpiryDate'] != null
          ? DateTime.tryParse(m['tccExpiryDate'] as String)
          : null,
      industrySector: m['industrySector'] as String?,
      subscriptionTier: m['subscriptionTier'] as String? ?? 'free',
      isAdmin: m['isAdmin'] as bool? ?? false,
      createdAt: DateTime.parse(m['createdAt'] as String),
      modifiedAt: DateTime.parse(m['modifiedAt'] as String),
    );
  }
}
