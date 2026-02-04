/// Support Ticket Model
class SupportTicket {
  final String id;
  final String userId;
  String username; // Added for display
  final String userEmail;
  final String subject;
  final String description;
  String priority; // 'high', 'medium', 'low'
  String status; // 'open', 'in_progress', 'resolved', 'closed'
  String? assignedTo; // Sub Admin ID
  final DateTime createdAt;
  DateTime lastUpdated; // Track last update
  DateTime? resolvedAt;
  List<TicketMessage> messages;
  String? escalatedTo; // Higher admin if escalated
  final String category; // 'technical', 'billing', 'account', 'other'

  SupportTicket({
    required this.id,
    required this.userId,
    required this.username,
    required this.userEmail,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    this.assignedTo,
    required this.createdAt,
    required this.lastUpdated,
    this.resolvedAt,
    this.messages = const [],
    this.escalatedTo,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userEmail': userEmail,
      'subject': subject,
      'description': description,
      'priority': priority,
      'status': status,
      'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'messages': messages.map((m) => m.toMap()).toList(),
      'escalatedTo': escalatedTo,
      'category': category,
    };
  }

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'] as String,
      userId: map['userId'] as String,
      username: map['username'] as String,
      userEmail: map['userEmail'] as String,
      subject: map['subject'] as String,
      description: map['description'] as String,
      priority: map['priority'] as String,
      status: map['status'] as String,
      assignedTo: map['assignedTo'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'] as String)
          : null,
      messages: (map['messages'] as List?)
              ?.map((m) => TicketMessage.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      escalatedTo: map['escalatedTo'] as String?,
      category: map['category'] as String,
    );
  }
}

/// Individual message in a support ticket
class TicketMessage {
  final String id;
  final String senderId; // User ID or Admin ID
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isAdminResponse;
  final bool isInternalNote; // Only visible to admins

  TicketMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isAdminResponse,
    this.isInternalNote = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isAdminResponse': isAdminResponse,
      'isInternalNote': isInternalNote,
    };
  }

  factory TicketMessage.fromMap(Map<String, dynamic> map) {
    return TicketMessage(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      message: map['message'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isAdminResponse: map['isAdminResponse'] as bool,
      isInternalNote: (map['isInternalNote'] as bool?) ?? false,
    );
  }
}
