/// Email Notification Model
class EmailNotification {
  final String id;
  final String recipientEmail;
  final String recipientName;
  final String subject;
  final String body;
  final String notificationType; // 'subscription_approved', 'subscription_rejected', 'ticket_update', etc.
  final DateTime sentAt;
  final bool sent;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  EmailNotification({
    required this.id,
    required this.recipientEmail,
    required this.recipientName,
    required this.subject,
    required this.body,
    required this.notificationType,
    required this.sentAt,
    this.sent = false,
    this.errorMessage,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientEmail': recipientEmail,
      'recipientName': recipientName,
      'subject': subject,
      'body': body,
      'notificationType': notificationType,
      'sentAt': sentAt.toIso8601String(),
      'sent': sent,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory EmailNotification.fromMap(Map<String, dynamic> map) {
    return EmailNotification(
      id: map['id'] as String,
      recipientEmail: map['recipientEmail'] as String,
      recipientName: map['recipientName'] as String,
      subject: map['subject'] as String,
      body: map['body'] as String,
      notificationType: map['notificationType'] as String,
      sentAt: DateTime.parse(map['sentAt'] as String),
      sent: map['sent'] as bool? ?? false,
      errorMessage: map['errorMessage'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  EmailNotification copyWith({
    bool? sent,
    String? errorMessage,
  }) {
    return EmailNotification(
      id: id,
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      subject: subject,
      body: body,
      notificationType: notificationType,
      sentAt: sentAt,
      sent: sent ?? this.sent,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata,
    );
  }
}
