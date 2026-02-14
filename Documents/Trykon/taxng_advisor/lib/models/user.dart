/// Type alias for backward compatibility with code using 'User'
typedef User = UserProfile;

class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
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
      subscriptionTier; // Subscription tier: 'free', 'individual', 'business', 'enterprise'
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isAdmin; // Admin can access developer documentation
  final String?
      adminRole; // 'main_admin', 'sub_admin', 'sub_admin1', 'sub_admin2', null for regular users
  final bool isActive; // Whether the user account is active
  final String? suspensionReason; // Reason for suspension if isActive is false
  final String? createdBy; // ID of admin who created this user
  final int
      adminHierarchyLevel; // 0=main, 1=sub_admin, 2=sub_admin2, 99=regular user

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
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
    this.adminRole,
    this.isActive = true,
    this.suspensionReason,
    this.createdBy,
    this.adminHierarchyLevel = 99,
  });

  /// Check if user is main admin (highest privileges)
  bool get isMainAdmin => adminRole == 'main_admin';

  /// Check if user is sub admin level 1
  bool get isSubAdmin1 => adminRole == 'sub_admin' || adminRole == 'sub_admin1';

  /// Check if user is sub admin level 2
  bool get isSubAdmin2 => adminRole == 'sub_admin2';

  /// Check if user is any type of admin
  bool get isAnyAdmin => isAdmin || adminRole != null;

  /// Get user's full name (firstName + lastName), or username if not available
  String get fullName {
    final parts = <String>[];
    if (firstName != null && firstName!.isNotEmpty) parts.add(firstName!);
    if (lastName != null && lastName!.isNotEmpty) parts.add(lastName!);
    return parts.isNotEmpty ? parts.join(' ') : username;
  }

  /// Get display name (firstName if available, else username)
  String get displayName => firstName ?? username;

  /// Check if business is in oil and gas sector (requires USD payments)
  bool get isOilAndGasSector => industrySector == 'oil_and_gas';

  /// Check if user can access pro/paid features.
  /// Matches actual tiers: free, individual, business, enterprise.
  bool get isPro =>
      subscriptionTier == 'individual' ||
      subscriptionTier == 'business' ||
      subscriptionTier == 'enterprise';

  /// Check if user can access business-tier features
  bool get isBusinessTier =>
      subscriptionTier == 'business' || subscriptionTier == 'enterprise';

  /// Get reminder limit based on subscription tier
  int get reminderLimit {
    switch (subscriptionTier) {
      case 'free':
        return 3;
      case 'individual':
        return 10;
      default: // business, enterprise
        return -1; // unlimited
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
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
      'adminRole': adminRole,
      'isActive': isActive,
      'suspensionReason': suspensionReason,
      'createdBy': createdBy,
      'adminHierarchyLevel': adminHierarchyLevel,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> m) {
    return UserProfile(
      id: m['id'] as String,
      username: m['username'] as String,
      email: m['email'] as String,
      firstName: m['firstName'] as String?,
      lastName: m['lastName'] as String?,
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
      adminRole: m['adminRole'] as String?,
      isActive: m['isActive'] as bool? ?? true,
      suspensionReason: m['suspensionReason'] as String?,
      createdBy: m['createdBy'] as String?,
      adminHierarchyLevel: m['adminHierarchyLevel'] as int? ?? 99,
      createdAt: DateTime.parse(m['createdAt'] as String),
      modifiedAt: DateTime.parse(m['modifiedAt'] as String),
    );
  }

  /// Create a copy of this user with some properties changed
  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? isBusiness,
    String? businessName,
    String? tin,
    String? cacNumber,
    String? bvn,
    String? vatNumber,
    String? payeRef,
    String? phoneNumber,
    String? address,
    String? taxOffice,
    DateTime? tccExpiryDate,
    String? industrySector,
    String? subscriptionTier,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? isAdmin,
    String? adminRole,
    bool? isActive,
    String? suspensionReason,
    String? createdBy,
    int? adminHierarchyLevel,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isBusiness: isBusiness ?? this.isBusiness,
      businessName: businessName ?? this.businessName,
      tin: tin ?? this.tin,
      cacNumber: cacNumber ?? this.cacNumber,
      bvn: bvn ?? this.bvn,
      vatNumber: vatNumber ?? this.vatNumber,
      payeRef: payeRef ?? this.payeRef,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      taxOffice: taxOffice ?? this.taxOffice,
      tccExpiryDate: tccExpiryDate ?? this.tccExpiryDate,
      industrySector: industrySector ?? this.industrySector,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isAdmin: isAdmin ?? this.isAdmin,
      adminRole: adminRole ?? this.adminRole,
      isActive: isActive ?? this.isActive,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      createdBy: createdBy ?? this.createdBy,
      adminHierarchyLevel: adminHierarchyLevel ?? this.adminHierarchyLevel,
    );
  }
}
