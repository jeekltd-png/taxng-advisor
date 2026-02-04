/// Sharing service for CPA/Accountant integration
library;

import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taxng_advisor/models/share_token.dart';
import 'package:taxng_advisor/models/user.dart';

class SharingService {
  static const String _shareTokensBox = 'share_tokens';
  static const String _commentsBox = 'collaboration_comments';
  static const String _accessLogsBox = 'share_access_logs';
  static const String _cpaClientsBox = 'cpa_clients';

  static Future<void> _ensureBoxOpen(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  // ==================== SHARE TOKEN METHODS ====================

  /// Generate a unique access code (6 digits)
  static String _generateAccessCode() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  /// Generate a unique token ID
  static String _generateTokenId() {
    final random = Random.secure();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a new share token
  static Future<ShareToken> createShareToken({
    required UserProfile owner,
    String? recipientEmail,
    String? recipientName,
    required SharePermission permission,
    required int expiryDays,
    List<String> calculationIds = const [],
    String? taxTypes,
  }) async {
    await _ensureBoxOpen(_shareTokensBox);
    final box = Hive.box(_shareTokensBox);

    final token = ShareToken(
      id: _generateTokenId(),
      ownerId: owner.id,
      ownerUsername: owner.username,
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      permission: permission,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: expiryDays)),
      sharedCalculationIds: calculationIds,
      sharedTaxTypes: taxTypes,
      accessCode: _generateAccessCode(),
    );

    await box.put(token.id, token.toMap());
    return token;
  }

  /// Get all share tokens for a user
  static Future<List<ShareToken>> getUserShareTokens(String userId) async {
    await _ensureBoxOpen(_shareTokensBox);
    final box = Hive.box(_shareTokensBox);

    final tokens = <ShareToken>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['ownerId'] == userId) {
          tokens.add(ShareToken.fromMap(map));
        }
      }
    }

    tokens.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tokens;
  }

  /// Get share token by ID
  static Future<ShareToken?> getShareToken(String tokenId) async {
    await _ensureBoxOpen(_shareTokensBox);
    final box = Hive.box(_shareTokensBox);

    final data = box.get(tokenId);
    if (data == null) return null;

    return ShareToken.fromMap(Map<String, dynamic>.from(data as Map));
  }

  /// Get share token by access code
  static Future<ShareToken?> getShareTokenByCode(String accessCode) async {
    await _ensureBoxOpen(_shareTokensBox);
    final box = Hive.box(_shareTokensBox);

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['accessCode'] == accessCode) {
          return ShareToken.fromMap(map);
        }
      }
    }
    return null;
  }

  /// Revoke a share token
  static Future<void> revokeShareToken(String tokenId) async {
    await _ensureBoxOpen(_shareTokensBox);
    final box = Hive.box(_shareTokensBox);

    final data = box.get(tokenId);
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      final token = ShareToken.fromMap(map);
      final revokedToken = token.copyWith(
        isRevoked: true,
        revokedAt: DateTime.now(),
      );
      await box.put(tokenId, revokedToken.toMap());
    }
  }

  /// Update token access count
  static Future<void> recordTokenAccess(
      String tokenId, String accessorEmail) async {
    await _ensureBoxOpen(_shareTokensBox);
    final box = Hive.box(_shareTokensBox);

    final data = box.get(tokenId);
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      final token = ShareToken.fromMap(map);
      final updatedToken = token.copyWith(
        accessCount: token.accessCount + 1,
        lastAccessedAt: DateTime.now(),
      );
      await box.put(tokenId, updatedToken.toMap());

      // Log access
      await logAccess(
        shareTokenId: tokenId,
        accessorEmail: accessorEmail,
        action: 'view',
      );
    }
  }

  /// Delete a share token
  static Future<void> deleteShareToken(String tokenId) async {
    await _ensureBoxOpen(_shareTokensBox);
    final box = Hive.box(_shareTokensBox);
    await box.delete(tokenId);
  }

  /// Get active tokens count
  static Future<int> getActiveTokensCount(String userId) async {
    final tokens = await getUserShareTokens(userId);
    return tokens.where((t) => t.isValid).length;
  }

  // ==================== COMMENT METHODS ====================

  /// Add a comment
  static Future<CollaborationComment> addComment({
    required String shareTokenId,
    required String calculationId,
    required String authorEmail,
    required String authorName,
    required String content,
    bool isInternal = false,
    String? parentCommentId,
  }) async {
    await _ensureBoxOpen(_commentsBox);
    final box = Hive.box(_commentsBox);

    final comment = CollaborationComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      shareTokenId: shareTokenId,
      calculationId: calculationId,
      authorEmail: authorEmail,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      isInternal: isInternal,
      parentCommentId: parentCommentId,
    );

    await box.put(comment.id, comment.toMap());
    return comment;
  }

  /// Get comments for a calculation
  static Future<List<CollaborationComment>> getComments({
    required String calculationId,
    bool includeInternal = false,
  }) async {
    await _ensureBoxOpen(_commentsBox);
    final box = Hive.box(_commentsBox);

    final comments = <CollaborationComment>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['calculationId'] == calculationId) {
          final comment = CollaborationComment.fromMap(map);
          if (includeInternal || !comment.isInternal) {
            comments.add(comment);
          }
        }
      }
    }

    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  /// Delete a comment
  static Future<void> deleteComment(String commentId) async {
    await _ensureBoxOpen(_commentsBox);
    final box = Hive.box(_commentsBox);
    await box.delete(commentId);
  }

  /// Mark comment as resolved
  static Future<void> resolveComment(String commentId) async {
    await _ensureBoxOpen(_commentsBox);
    final box = Hive.box(_commentsBox);

    final data = box.get(commentId);
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      map['isResolved'] = true;
      await box.put(commentId, map);
    }
  }

  // ==================== ACCESS LOG METHODS ====================

  /// Log an access event
  static Future<void> logAccess({
    required String shareTokenId,
    required String accessorEmail,
    required String action,
    String? calculationId,
    Map<String, dynamic>? details,
  }) async {
    await _ensureBoxOpen(_accessLogsBox);
    final box = Hive.box(_accessLogsBox);

    final log = ShareAccessLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      shareTokenId: shareTokenId,
      accessorEmail: accessorEmail,
      accessorIp: '127.0.0.1', // In production, get actual IP
      accessedAt: DateTime.now(),
      action: action,
      calculationId: calculationId,
      details: details,
    );

    await box.put(log.id, log.toMap());
  }

  /// Get access logs for a token
  static Future<List<ShareAccessLog>> getAccessLogs(String shareTokenId) async {
    await _ensureBoxOpen(_accessLogsBox);
    final box = Hive.box(_accessLogsBox);

    final logs = <ShareAccessLog>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['shareTokenId'] == shareTokenId) {
          logs.add(ShareAccessLog.fromMap(map));
        }
      }
    }

    logs.sort((a, b) => b.accessedAt.compareTo(a.accessedAt));
    return logs;
  }

  /// Get all access logs for a user's tokens
  static Future<List<ShareAccessLog>> getUserAccessLogs(String userId) async {
    final tokens = await getUserShareTokens(userId);
    final tokenIds = tokens.map((t) => t.id).toSet();

    await _ensureBoxOpen(_accessLogsBox);
    final box = Hive.box(_accessLogsBox);

    final logs = <ShareAccessLog>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (tokenIds.contains(map['shareTokenId'])) {
          logs.add(ShareAccessLog.fromMap(map));
        }
      }
    }

    logs.sort((a, b) => b.accessedAt.compareTo(a.accessedAt));
    return logs;
  }

  // ==================== CPA CLIENT METHODS ====================

  /// Add a CPA client
  static Future<CPAClient> addCPAClient({
    required String cpaUserId,
    required UserProfile client,
    SharePermission defaultPermission = SharePermission.viewOnly,
    List<String> sharedTaxTypes = const [],
  }) async {
    await _ensureBoxOpen(_cpaClientsBox);
    final box = Hive.box(_cpaClientsBox);

    final cpaClient = CPAClient(
      id: '${cpaUserId}_${client.id}',
      userId: client.id,
      username: client.username,
      email: client.email,
      businessName: client.businessName,
      tin: client.tin,
      connectedAt: DateTime.now(),
      defaultPermission: defaultPermission,
      sharedTaxTypes: sharedTaxTypes,
    );

    await box.put(cpaClient.id, cpaClient.toMap());
    return cpaClient;
  }

  /// Get CPA's clients
  static Future<List<CPAClient>> getCPAClients(String cpaUserId) async {
    await _ensureBoxOpen(_cpaClientsBox);
    final box = Hive.box(_cpaClientsBox);

    final clients = <CPAClient>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if ((key as String).startsWith('${cpaUserId}_')) {
          clients.add(CPAClient.fromMap(map));
        }
      }
    }

    clients.sort((a, b) => b.connectedAt.compareTo(a.connectedAt));
    return clients;
  }

  /// Remove CPA client
  static Future<void> removeCPAClient(String cpaUserId, String clientId) async {
    await _ensureBoxOpen(_cpaClientsBox);
    final box = Hive.box(_cpaClientsBox);
    await box.delete('${cpaUserId}_$clientId');
  }

  /// Get sharing statistics
  static Future<Map<String, dynamic>> getSharingStatistics(
      String userId) async {
    final tokens = await getUserShareTokens(userId);
    final accessLogs = await getUserAccessLogs(userId);

    final activeTokens = tokens.where((t) => t.isValid).length;
    final expiredTokens =
        tokens.where((t) => t.isExpired && !t.isRevoked).length;
    final revokedTokens = tokens.where((t) => t.isRevoked).length;
    final totalAccess = accessLogs.length;
    final last7DaysAccess = accessLogs
        .where((l) => l.accessedAt
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .length;

    return {
      'totalTokens': tokens.length,
      'activeTokens': activeTokens,
      'expiredTokens': expiredTokens,
      'revokedTokens': revokedTokens,
      'totalAccess': totalAccess,
      'last7DaysAccess': last7DaysAccess,
      'mostAccessedToken': tokens.isNotEmpty
          ? tokens.reduce((a, b) => a.accessCount > b.accessCount ? a : b).id
          : null,
    };
  }

  /// Validate access code and get token
  static Future<ShareToken?> validateAccessCode(String code) async {
    final token = await getShareTokenByCode(code);
    if (token == null) return null;
    if (!token.isValid) return null;
    return token;
  }

  /// Generate shareable link
  static String generateShareableLink(ShareToken token) {
    // In production, this would be a real URL
    return 'https://taxng.app/share/${token.id}?code=${token.accessCode}';
  }
}
