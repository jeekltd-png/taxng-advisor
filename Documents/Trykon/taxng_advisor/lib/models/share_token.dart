/// Share token model for secure sharing with CPAs/Accountants
library;

/// Permission levels for shared access
enum SharePermission {
  viewOnly,
  comment,
  edit,
}

/// Share token model
class ShareToken {
  final String id;
  final String ownerId;
  final String ownerUsername;
  final String? recipientEmail;
  final String? recipientName;
  final SharePermission permission;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isRevoked;
  final DateTime? revokedAt;
  final List<String> sharedCalculationIds;
  final String? sharedTaxTypes; // Comma-separated: 'VAT,CIT,PIT'
  final int accessCount;
  final DateTime? lastAccessedAt;
  final String? accessCode; // 6-digit code for quick access
  final Map<String, dynamic>? metadata;

  ShareToken({
    required this.id,
    required this.ownerId,
    required this.ownerUsername,
    this.recipientEmail,
    this.recipientName,
    required this.permission,
    required this.createdAt,
    required this.expiresAt,
    this.isRevoked = false,
    this.revokedAt,
    this.sharedCalculationIds = const [],
    this.sharedTaxTypes,
    this.accessCount = 0,
    this.lastAccessedAt,
    this.accessCode,
    this.metadata,
  });

  /// Check if token is valid (not expired and not revoked)
  bool get isValid => !isRevoked && DateTime.now().isBefore(expiresAt);

  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get days until expiry
  int get daysUntilExpiry {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inDays;
  }

  /// Get permission label
  String get permissionLabel {
    switch (permission) {
      case SharePermission.viewOnly:
        return 'View Only';
      case SharePermission.comment:
        return 'Can Comment';
      case SharePermission.edit:
        return 'Can Edit';
    }
  }

  /// Get status label
  String get statusLabel {
    if (isRevoked) return 'Revoked';
    if (isExpired) return 'Expired';
    return 'Active';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerUsername': ownerUsername,
      'recipientEmail': recipientEmail,
      'recipientName': recipientName,
      'permission': permission.index,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isRevoked': isRevoked,
      'revokedAt': revokedAt?.toIso8601String(),
      'sharedCalculationIds': sharedCalculationIds,
      'sharedTaxTypes': sharedTaxTypes,
      'accessCount': accessCount,
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'accessCode': accessCode,
      'metadata': metadata,
    };
  }

  factory ShareToken.fromMap(Map<String, dynamic> m) {
    return ShareToken(
      id: m['id'] as String,
      ownerId: m['ownerId'] as String,
      ownerUsername: m['ownerUsername'] as String,
      recipientEmail: m['recipientEmail'] as String?,
      recipientName: m['recipientName'] as String?,
      permission: SharePermission.values[m['permission'] as int? ?? 0],
      createdAt: DateTime.parse(m['createdAt'] as String),
      expiresAt: DateTime.parse(m['expiresAt'] as String),
      isRevoked: m['isRevoked'] as bool? ?? false,
      revokedAt: m['revokedAt'] != null
          ? DateTime.parse(m['revokedAt'] as String)
          : null,
      sharedCalculationIds:
          (m['sharedCalculationIds'] as List?)?.cast<String>() ?? [],
      sharedTaxTypes: m['sharedTaxTypes'] as String?,
      accessCount: m['accessCount'] as int? ?? 0,
      lastAccessedAt: m['lastAccessedAt'] != null
          ? DateTime.parse(m['lastAccessedAt'] as String)
          : null,
      accessCode: m['accessCode'] as String?,
      metadata: m['metadata'] as Map<String, dynamic>?,
    );
  }

  ShareToken copyWith({
    String? id,
    String? ownerId,
    String? ownerUsername,
    String? recipientEmail,
    String? recipientName,
    SharePermission? permission,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isRevoked,
    DateTime? revokedAt,
    List<String>? sharedCalculationIds,
    String? sharedTaxTypes,
    int? accessCount,
    DateTime? lastAccessedAt,
    String? accessCode,
    Map<String, dynamic>? metadata,
  }) {
    return ShareToken(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      permission: permission ?? this.permission,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt ?? this.revokedAt,
      sharedCalculationIds: sharedCalculationIds ?? this.sharedCalculationIds,
      sharedTaxTypes: sharedTaxTypes ?? this.sharedTaxTypes,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      accessCode: accessCode ?? this.accessCode,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Collaboration comment model
class CollaborationComment {
  final String id;
  final String shareTokenId;
  final String calculationId;
  final String authorEmail;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isInternal; // Internal notes vs public comments
  final String? parentCommentId; // For threaded replies
  final bool isResolved;

  CollaborationComment({
    required this.id,
    required this.shareTokenId,
    required this.calculationId,
    required this.authorEmail,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.editedAt,
    this.isInternal = false,
    this.parentCommentId,
    this.isResolved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shareTokenId': shareTokenId,
      'calculationId': calculationId,
      'authorEmail': authorEmail,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'isInternal': isInternal,
      'parentCommentId': parentCommentId,
      'isResolved': isResolved,
    };
  }

  factory CollaborationComment.fromMap(Map<String, dynamic> m) {
    return CollaborationComment(
      id: m['id'] as String,
      shareTokenId: m['shareTokenId'] as String,
      calculationId: m['calculationId'] as String,
      authorEmail: m['authorEmail'] as String,
      authorName: m['authorName'] as String,
      content: m['content'] as String,
      createdAt: DateTime.parse(m['createdAt'] as String),
      editedAt: m['editedAt'] != null
          ? DateTime.parse(m['editedAt'] as String)
          : null,
      isInternal: m['isInternal'] as bool? ?? false,
      parentCommentId: m['parentCommentId'] as String?,
      isResolved: m['isResolved'] as bool? ?? false,
    );
  }
}

/// CPA Client model for accountant dashboard
class CPAClient {
  final String id;
  final String userId;
  final String username;
  final String email;
  final String? businessName;
  final String? tin;
  final DateTime connectedAt;
  final SharePermission defaultPermission;
  final List<String> sharedTaxTypes;
  final bool isActive;
  final DateTime? lastActivityAt;
  final int pendingItems;
  final Map<String, dynamic>? notes;

  CPAClient({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    this.businessName,
    this.tin,
    required this.connectedAt,
    this.defaultPermission = SharePermission.viewOnly,
    this.sharedTaxTypes = const [],
    this.isActive = true,
    this.lastActivityAt,
    this.pendingItems = 0,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'email': email,
      'businessName': businessName,
      'tin': tin,
      'connectedAt': connectedAt.toIso8601String(),
      'defaultPermission': defaultPermission.index,
      'sharedTaxTypes': sharedTaxTypes,
      'isActive': isActive,
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'pendingItems': pendingItems,
      'notes': notes,
    };
  }

  factory CPAClient.fromMap(Map<String, dynamic> m) {
    return CPAClient(
      id: m['id'] as String,
      userId: m['userId'] as String,
      username: m['username'] as String,
      email: m['email'] as String,
      businessName: m['businessName'] as String?,
      tin: m['tin'] as String?,
      connectedAt: DateTime.parse(m['connectedAt'] as String),
      defaultPermission:
          SharePermission.values[m['defaultPermission'] as int? ?? 0],
      sharedTaxTypes: (m['sharedTaxTypes'] as List?)?.cast<String>() ?? [],
      isActive: m['isActive'] as bool? ?? true,
      lastActivityAt: m['lastActivityAt'] != null
          ? DateTime.parse(m['lastActivityAt'] as String)
          : null,
      pendingItems: m['pendingItems'] as int? ?? 0,
      notes: m['notes'] as Map<String, dynamic>?,
    );
  }
}

/// Access log entry for audit trail
class ShareAccessLog {
  final String id;
  final String shareTokenId;
  final String accessorEmail;
  final String accessorIp;
  final DateTime accessedAt;
  final String action; // 'view', 'download', 'comment', 'edit'
  final String? calculationId;
  final Map<String, dynamic>? details;

  ShareAccessLog({
    required this.id,
    required this.shareTokenId,
    required this.accessorEmail,
    required this.accessorIp,
    required this.accessedAt,
    required this.action,
    this.calculationId,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shareTokenId': shareTokenId,
      'accessorEmail': accessorEmail,
      'accessorIp': accessorIp,
      'accessedAt': accessedAt.toIso8601String(),
      'action': action,
      'calculationId': calculationId,
      'details': details,
    };
  }

  factory ShareAccessLog.fromMap(Map<String, dynamic> m) {
    return ShareAccessLog(
      id: m['id'] as String,
      shareTokenId: m['shareTokenId'] as String,
      accessorEmail: m['accessorEmail'] as String,
      accessorIp: m['accessorIp'] as String,
      accessedAt: DateTime.parse(m['accessedAt'] as String),
      action: m['action'] as String,
      calculationId: m['calculationId'] as String?,
      details: m['details'] as Map<String, dynamic>?,
    );
  }
}
