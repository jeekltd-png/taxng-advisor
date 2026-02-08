import 'package:hive_flutter/hive_flutter.dart';
import '../models/email_notification.dart';
import '../models/user.dart';

/// Email Notification Service
///
/// This is a placeholder service that simulates email sending.
/// In production, integrate with actual email providers like:
/// - SendGrid
/// - AWS SES
/// - Mailgun
/// - Firebase Cloud Functions with Nodemailer
class EmailNotificationService {
  static const String _boxName = 'email_notifications';

  /// Send a notification (currently simulated)
  static Future<bool> sendNotification({
    required String recipientEmail,
    required String recipientName,
    required String subject,
    required String body,
    required String notificationType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final box = await Hive.openBox<EmailNotification>(_boxName);

      final notification = EmailNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recipientEmail: recipientEmail,
        recipientName: recipientName,
        subject: subject,
        body: body,
        notificationType: notificationType,
        sentAt: DateTime.now(),
        sent: true, // Simulated success
        metadata: metadata ?? {},
      );

      await box.add(notification);

      // TODO: In production, integrate with actual email service here
      // Example:
      // await sendGridClient.send(notification);

      return true;
    } catch (e) {
      print('Error sending notification: $e');

      // Store failed notification
      try {
        final box = await Hive.openBox<EmailNotification>(_boxName);
        final notification = EmailNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          recipientEmail: recipientEmail,
          recipientName: recipientName,
          subject: subject,
          body: body,
          notificationType: notificationType,
          sentAt: DateTime.now(),
          sent: false,
          errorMessage: e.toString(),
          metadata: metadata ?? {},
        );
        await box.add(notification);
      } catch (_) {}

      return false;
    }
  }

  /// Send subscription approval notification
  static Future<bool> sendSubscriptionApprovalNotification({
    required User user,
    required String tier,
  }) async {
    return await sendNotification(
      recipientEmail: user.email,
      recipientName: user.username,
      subject:
          '🎉 Subscription Approved - Welcome to ${tier.toUpperCase()} Tier!',
      body: '''
Hello ${user.username},

Great news! Your subscription request has been approved.

Subscription Details:
- Tier: ${tier.toUpperCase()}
- Status: Active
- Approved Date: ${DateTime.now().toString().split('.')[0]}

You now have access to all $tier tier features:
${_getTierFeatures(tier)}

Thank you for upgrading to TaxPadi ${tier.toUpperCase()}!

Best regards,
TaxPadi Team
      ''',
      notificationType: 'subscription_approved',
      metadata: {
        'user_id': user.id,
        'subscription_tier': tier,
      },
    );
  }

  /// Send subscription rejection notification
  static Future<bool> sendSubscriptionRejectionNotification({
    required User user,
    required String tier,
    String? reason,
  }) async {
    return await sendNotification(
      recipientEmail: user.email,
      recipientName: user.username,
      subject: 'Subscription Request Update',
      body: '''
Hello ${user.username},

We have reviewed your subscription request for the ${tier.toUpperCase()} tier.

Unfortunately, we are unable to approve your request at this time.

${reason != null ? 'Reason: $reason\n\n' : ''}Please contact our support team if you have any questions or would like to discuss this further.

Best regards,
TaxPadi Team
      ''',
      notificationType: 'subscription_rejected',
      metadata: {
        'user_id': user.id,
        'subscription_tier': tier,
        'reason': reason,
      },
    );
  }

  /// Send support ticket update notification
  static Future<bool> sendTicketUpdateNotification({
    required User user,
    required String ticketId,
    required String subject,
    required String updateType, // 'response', 'status_change', 'escalated'
    String? message,
  }) async {
    final String bodyPrefix;
    switch (updateType) {
      case 'response':
        bodyPrefix =
            'Your support ticket has received a new response from our team.';
        break;
      case 'status_change':
        bodyPrefix = 'Your support ticket status has been updated.';
        break;
      case 'escalated':
        bodyPrefix =
            'Your support ticket has been escalated to a senior admin for priority handling.';
        break;
      default:
        bodyPrefix = 'Your support ticket has been updated.';
    }

    return await sendNotification(
      recipientEmail: user.email,
      recipientName: user.username,
      subject: 'Support Ticket Update: $subject',
      body: '''
Hello ${user.username},

$bodyPrefix

Ticket Details:
- Ticket ID: ${ticketId.substring(0, 8)}
- Subject: $subject

${message != null ? 'Message:\n$message\n\n' : ''}You can view the full ticket details and conversation history in the TaxPadi app under Contact Support.

Best regards,
TaxPadi Support Team
      ''',
      notificationType: 'ticket_update',
      metadata: {
        'user_id': user.id,
        'ticket_id': ticketId,
        'update_type': updateType,
      },
    );
  }

  /// Send admin notification for new subscription request
  static Future<bool> sendAdminSubscriptionRequestNotification({
    required User admin,
    required String username,
    required String tier,
  }) async {
    return await sendNotification(
      recipientEmail: admin.email,
      recipientName: admin.username,
      subject: '[ADMIN] New Subscription Request',
      body: '''
Hello ${admin.username},

A new subscription request requires your attention.

Request Details:
- User: $username
- Requested Tier: ${tier.toUpperCase()}
- Date: ${DateTime.now().toString().split('.')[0]}

Please review this request in the Admin Subscription Approvals section.

TaxPadi Admin System
      ''',
      notificationType: 'admin_subscription_request',
      metadata: {
        'admin_id': admin.id,
        'subscription_tier': tier,
      },
    );
  }

  /// Send admin notification for new support ticket
  static Future<bool> sendAdminTicketNotification({
    required User admin,
    required String username,
    required String ticketId,
    required String subject,
    required String priority,
  }) async {
    return await sendNotification(
      recipientEmail: admin.email,
      recipientName: admin.username,
      subject:
          '[ADMIN] New Support Ticket ${priority == 'high' ? '⚠️ HIGH PRIORITY' : ''}',
      body: '''
Hello ${admin.username},

A new support ticket has been created.

Ticket Details:
- From: $username
- Ticket ID: ${ticketId.substring(0, 8)}
- Subject: $subject
- Priority: ${priority.toUpperCase()}
- Date: ${DateTime.now().toString().split('.')[0]}

Please review this ticket in the Admin Support Tickets section.

TaxPadi Admin System
      ''',
      notificationType: 'admin_ticket_notification',
      metadata: {
        'admin_id': admin.id,
        'ticket_id': ticketId,
        'priority': priority,
      },
    );
  }

  /// Get all notifications
  static Future<List<EmailNotification>> getAllNotifications() async {
    final box = await Hive.openBox<EmailNotification>(_boxName);
    return box.values.toList();
  }

  /// Get notifications by type
  static Future<List<EmailNotification>> getNotificationsByType(
      String type) async {
    final box = await Hive.openBox<EmailNotification>(_boxName);
    return box.values.where((n) => n.notificationType == type).toList();
  }

  /// Get notification statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final box = await Hive.openBox<EmailNotification>(_boxName);
    final notifications = box.values.toList();

    final sent = notifications.where((n) => n.sent).length;
    final failed = notifications.where((n) => !n.sent).length;

    final typeCounts = <String, int>{};
    for (final notification in notifications) {
      typeCounts[notification.notificationType] =
          (typeCounts[notification.notificationType] ?? 0) + 1;
    }

    return {
      'total': notifications.length,
      'sent': sent,
      'failed': failed,
      'typeCounts': typeCounts,
    };
  }

  /// Helper to get tier features description
  static String _getTierFeatures(String tier) {
    switch (tier.toLowerCase()) {
      case 'business':
        return '''
✅ Unlimited tax calculations
✅ Multi-user team access
✅ Document vault
✅ Custom data entry
✅ Priority support
✅ Advanced reporting
✅ API access
        ''';
      case 'pro':
        return '''
✅ Unlimited tax calculations
✅ Custom data entry
✅ Priority support
✅ Advanced reporting
        ''';
      default:
        return '✅ All standard features';
    }
  }
}
