/// Admin Activity Log for audit trail
class AdminActivityLog {
  final String id;
  final String adminId;
  final String adminUsername;
  final String
      action; // 'user_created', 'subscription_approved', 'ticket_responded', etc.
  final String targetUserId;
  final String? targetUsername;
  final Map<String, dynamic> details;
  final String ipAddress;
  final DateTime timestamp;

  AdminActivityLog({
    required this.id,
    required this.adminId,
    required this.adminUsername,
    required this.action,
    required this.targetUserId,
    this.targetUsername,
    required this.details,
    required this.ipAddress,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'adminUsername': adminUsername,
      'action': action,
      'targetUserId': targetUserId,
      'targetUsername': targetUsername,
      'details': details,
      'ipAddress': ipAddress,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AdminActivityLog.fromMap(Map<String, dynamic> map) {
    return AdminActivityLog(
      id: map['id'] as String,
      adminId: map['adminId'] as String,
      adminUsername: map['adminUsername'] as String,
      action: map['action'] as String,
      targetUserId: map['targetUserId'] as String,
      targetUsername: map['targetUsername'] as String?,
      details: Map<String, dynamic>.from(map['details'] as Map),
      ipAddress: map['ipAddress'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  String getActionDescription() {
    switch (action) {
      case 'user_created':
        return 'Created new user account';
      case 'user_edited':
        return 'Updated user information';
      case 'user_suspended':
        return 'Suspended user account';
      case 'user_activated':
        return 'Activated user account';
      case 'subscription_approved':
        return 'Approved subscription request';
      case 'subscription_rejected':
        return 'Rejected subscription request';
      case 'subscription_reviewed':
        return 'Reviewed subscription request';
      case 'ticket_created':
        return 'Created support ticket';
      case 'ticket_responded':
        return 'Responded to support ticket';
      case 'ticket_assigned':
        return 'Assigned support ticket';
      case 'ticket_escalated':
        return 'Escalated support ticket';
      case 'ticket_closed':
        return 'Closed support ticket';
      case 'admin_created':
        return 'Created new admin account';
      case 'admin_permission_changed':
        return 'Modified admin permissions';
      case 'login':
        return 'Logged in';
      case 'logout':
        return 'Logged out';
      case 'failed_login':
        return 'Failed login attempt';
      default:
        return action.replaceAll('_', ' ');
    }
  }
}
