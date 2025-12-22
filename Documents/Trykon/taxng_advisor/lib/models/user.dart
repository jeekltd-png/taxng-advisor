class UserProfile {
  final String id;
  final String username;
  final String email;
  final bool isBusiness;
  final String? businessName;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isAdmin; // Admin can access developer documentation

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.isBusiness,
    this.businessName,
    required this.createdAt,
    required this.modifiedAt,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'isBusiness': isBusiness,
      'businessName': businessName,
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
      isAdmin: m['isAdmin'] as bool? ?? false,
      createdAt: DateTime.parse(m['createdAt'] as String),
      modifiedAt: DateTime.parse(m['modifiedAt'] as String),
    );
  }
}
