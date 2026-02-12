/// WhatsApp integration service for notifications and bot interactions
library;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:taxng_advisor/models/user.dart';

/// WhatsApp message type
enum WhatsAppMessageType {
  deadlineReminder,
  paymentConfirmation,
  documentRequest,
  supportResponse,
  calculationSummary,
  generalNotification,
}

/// WhatsApp notification model
class WhatsAppNotification {
  final String id;
  final String userId;
  final String phoneNumber;
  final WhatsAppMessageType type;
  final String message;
  final DateTime createdAt;
  final DateTime? sentAt;
  final bool sent;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  WhatsAppNotification({
    required this.id,
    required this.userId,
    required this.phoneNumber,
    required this.type,
    required this.message,
    required this.createdAt,
    this.sentAt,
    this.sent = false,
    this.errorMessage,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'type': type.index,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'sent': sent,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory WhatsAppNotification.fromMap(Map<String, dynamic> m) {
    return WhatsAppNotification(
      id: m['id'] as String,
      userId: m['userId'] as String,
      phoneNumber: m['phoneNumber'] as String,
      type: WhatsAppMessageType.values[m['type'] as int? ?? 0],
      message: m['message'] as String,
      createdAt: DateTime.parse(m['createdAt'] as String),
      sentAt:
          m['sentAt'] != null ? DateTime.parse(m['sentAt'] as String) : null,
      sent: m['sent'] as bool? ?? false,
      errorMessage: m['errorMessage'] as String?,
      metadata: m['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// WhatsApp bot command
class WhatsAppBotCommand {
  final String command;
  final String description;
  final String response;
  final List<String> aliases;

  const WhatsAppBotCommand({
    required this.command,
    required this.description,
    required this.response,
    this.aliases = const [],
  });
}

class WhatsAppService {
  static const String _notificationsBox = 'whatsapp_notifications';
  static const String _settingsBox = 'whatsapp_settings';

  // Business WhatsApp number (replace with actual number in production)
  static const String _businessNumber = '+2349000000000';

  // Bot commands
  static const List<WhatsAppBotCommand> botCommands = [
    WhatsAppBotCommand(
      command: 'help',
      description: 'Show available commands',
      response: '''
🤖 *TaxNG Bot Commands*

📊 *Tax Calculations*
• latest - Show your latest calculation
• summary - Get your tax summary
• deadline - Check next deadline

📋 *Account*
• profile - View your profile
• subscription - Check subscription status

💬 *Support*
• support - Contact support team
• faq - View FAQs

Type any command to get started!
''',
      aliases: ['?', 'commands', 'menu'],
    ),
    WhatsAppBotCommand(
      command: 'latest',
      description: 'Show latest calculation',
      response: '''
📊 *Your Latest Calculation*

{calculation_type}: {calculation_date}

💰 *Amount:* {gross_amount}
📉 *Tax:* {tax_amount}
✅ *Net:* {net_amount}

_Reply "export" to get PDF_
''',
      aliases: ['last', 'recent'],
    ),
    WhatsAppBotCommand(
      command: 'summary',
      description: 'Get tax summary',
      response: '''
📈 *Your Tax Summary*

*This Month:*
• VAT: {vat_total}
• WHT: {wht_total}
• PAYE: {paye_total}

*Total Tax Liability:* {total_liability}

*Year to Date:* {ytd_total}

_Use TaxNG app for detailed report_
''',
      aliases: ['stats', 'total'],
    ),
    WhatsAppBotCommand(
      command: 'deadline',
      description: 'Check next deadline',
      response: '''
⏰ *Upcoming Deadlines*

1️⃣ {deadline_1_name}
   📅 {deadline_1_date}
   ⏳ {deadline_1_days} days left

2️⃣ {deadline_2_name}
   📅 {deadline_2_date}
   ⏳ {deadline_2_days} days left

_Set reminders in TaxNG app_
''',
      aliases: ['deadlines', 'due', 'next'],
    ),
    WhatsAppBotCommand(
      command: 'support',
      description: 'Contact support',
      response: '''
💬 *TaxNG Support*

For assistance, you can:

📧 Email: support@taxng.app
📞 Call: 0800-TAX-HELP
💬 Live Chat: Open TaxNG app

Or describe your issue here and we'll respond shortly.

_Support hours: Mon-Fri 8AM-6PM_
''',
      aliases: ['contact', 'help me'],
    ),
  ];

  static Future<void> _ensureBoxOpen(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  // ==================== NOTIFICATION METHODS ====================

  /// Send WhatsApp message via URL scheme
  static Future<bool> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Format phone number (remove + and spaces)
      final formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      // Encode message for URL
      final encodedMessage = Uri.encodeComponent(message);

      // Try WhatsApp Business first, then regular WhatsApp
      final whatsappUrl =
          Uri.parse('https://wa.me/$formattedNumber?text=$encodedMessage');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('WhatsApp error: $e');
      return false;
    }
  }

  /// Create and queue a notification
  static Future<WhatsAppNotification> createNotification({
    required UserProfile user,
    required WhatsAppMessageType type,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureBoxOpen(_notificationsBox);
    final box = Hive.box(_notificationsBox);

    final notification = WhatsAppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      phoneNumber: user.phoneNumber ?? '',
      type: type,
      message: message,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    await box.put(notification.id, notification.toMap());
    return notification;
  }

  /// Send deadline reminder
  static Future<bool> sendDeadlineReminder({
    required UserProfile user,
    required String deadlineName,
    required DateTime dueDate,
    required int daysUntilDue,
  }) async {
    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
      return false;
    }

    final message = '''
⏰ *TaxNG Deadline Reminder*

Hello ${user.username}! 👋

You have an upcoming tax deadline:

📋 *$deadlineName*
📅 Due: ${_formatDate(dueDate)}
⏳ $daysUntilDue days remaining

Don't miss it! Open TaxNG app to prepare your filing.

_This is an automated reminder from TaxNG_
''';

    await createNotification(
      user: user,
      type: WhatsAppMessageType.deadlineReminder,
      message: message,
      metadata: {
        'deadline_name': deadlineName,
        'due_date': dueDate.toIso8601String(),
        'days_until_due': daysUntilDue,
      },
    );

    return await sendWhatsAppMessage(
      phoneNumber: user.phoneNumber!,
      message: message,
    );
  }

  /// Send payment confirmation
  static Future<bool> sendPaymentConfirmation({
    required UserProfile user,
    required String transactionRef,
    required double amount,
    required String taxType,
  }) async {
    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
      return false;
    }

    final message = '''
✅ *TaxNG Payment Confirmation*

Hello ${user.username}! 👋

Your payment has been received:

💰 *Amount:* ₦${_formatAmount(amount)}
📋 *Tax Type:* $taxType
🔖 *Reference:* $transactionRef
📅 *Date:* ${_formatDate(DateTime.now())}

Thank you for using TaxNG! 🙏

_Keep this message for your records_
''';

    await createNotification(
      user: user,
      type: WhatsAppMessageType.paymentConfirmation,
      message: message,
      metadata: {
        'transaction_ref': transactionRef,
        'amount': amount,
        'tax_type': taxType,
      },
    );

    return await sendWhatsAppMessage(
      phoneNumber: user.phoneNumber!,
      message: message,
    );
  }

  /// Send calculation summary
  static Future<bool> sendCalculationSummary({
    required UserProfile user,
    required String taxType,
    required double grossAmount,
    required double taxAmount,
    required double netAmount,
  }) async {
    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
      return false;
    }

    final message = '''
📊 *TaxNG Calculation Summary*

Hello ${user.username}! 👋

Here's your $taxType calculation:

💵 *Gross Amount:* ₦${_formatAmount(grossAmount)}
📉 *Tax Amount:* ₦${_formatAmount(taxAmount)}
✅ *Net Amount:* ₦${_formatAmount(netAmount)}

📅 Calculated: ${_formatDate(DateTime.now())}

Open TaxNG app to save, export, or share this calculation.

_Powered by TaxNG_
''';

    await createNotification(
      user: user,
      type: WhatsAppMessageType.calculationSummary,
      message: message,
      metadata: {
        'tax_type': taxType,
        'gross_amount': grossAmount,
        'tax_amount': taxAmount,
        'net_amount': netAmount,
      },
    );

    return await sendWhatsAppMessage(
      phoneNumber: user.phoneNumber!,
      message: message,
    );
  }

  /// Send support response
  static Future<bool> sendSupportResponse({
    required UserProfile user,
    required String ticketId,
    required String responseMessage,
  }) async {
    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
      return false;
    }

    final message = '''
💬 *TaxNG Support Response*

Hello ${user.username}! 👋

We've responded to your support ticket:

🎫 *Ticket:* #$ticketId

📝 *Our Response:*
$responseMessage

Reply to this message or open TaxNG app to continue the conversation.

_TaxNG Support Team_
''';

    await createNotification(
      user: user,
      type: WhatsAppMessageType.supportResponse,
      message: message,
      metadata: {
        'ticket_id': ticketId,
        'response': responseMessage,
      },
    );

    return await sendWhatsAppMessage(
      phoneNumber: user.phoneNumber!,
      message: message,
    );
  }

  /// Send document request
  static Future<bool> sendDocumentRequest({
    required UserProfile user,
    required String documentName,
    required String purpose,
  }) async {
    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
      return false;
    }

    final message = '''
📄 *TaxNG Document Request*

Hello ${user.username}! 👋

We need the following document:

📋 *Document:* $documentName
📌 *Purpose:* $purpose

You can upload this document through the TaxNG app or reply to this message with a photo.

Need help? Reply "support" to contact us.

_TaxNG_
''';

    await createNotification(
      user: user,
      type: WhatsAppMessageType.documentRequest,
      message: message,
      metadata: {
        'document_name': documentName,
        'purpose': purpose,
      },
    );

    return await sendWhatsAppMessage(
      phoneNumber: user.phoneNumber!,
      message: message,
    );
  }

  // ==================== BOT METHODS ====================

  /// Process bot command
  static String processBotCommand(String input) {
    final command = input.toLowerCase().trim();

    for (var cmd in botCommands) {
      if (cmd.command == command || cmd.aliases.contains(command)) {
        return cmd.response;
      }
    }

    // Default response for unknown commands
    return '''
🤖 *TaxNG Bot*

I didn't understand that command.

Type *help* to see available commands.

Or describe what you need and I'll try to help!
''';
  }

  /// Get bot command help
  static String getBotHelp() {
    return botCommands.firstWhere((c) => c.command == 'help').response;
  }

  // ==================== HISTORY METHODS ====================

  /// Get notification history
  static Future<List<WhatsAppNotification>> getNotificationHistory(
      String userId) async {
    await _ensureBoxOpen(_notificationsBox);
    final box = Hive.box(_notificationsBox);

    final notifications = <WhatsAppNotification>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['userId'] == userId) {
          notifications.add(WhatsAppNotification.fromMap(map));
        }
      }
    }

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  /// Get all notifications (admin)
  static Future<List<WhatsAppNotification>> getAllNotifications() async {
    await _ensureBoxOpen(_notificationsBox);
    final box = Hive.box(_notificationsBox);

    final notifications = <WhatsAppNotification>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        notifications.add(WhatsAppNotification.fromMap(
          Map<String, dynamic>.from(data as Map),
        ));
      }
    }

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  /// Get notification statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final all = await getAllNotifications();

    final byType = <WhatsAppMessageType, int>{};
    var sent = 0;
    var failed = 0;

    for (var n in all) {
      byType[n.type] = (byType[n.type] ?? 0) + 1;
      if (n.sent) {
        sent++;
      } else {
        failed++;
      }
    }

    final last7Days = all
        .where((n) => n.createdAt
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .length;

    return {
      'total': all.length,
      'sent': sent,
      'failed': failed,
      'last7Days': last7Days,
      'byType': byType.map((k, v) => MapEntry(k.name, v)),
    };
  }

  // ==================== SETTINGS ====================

  /// Enable/disable WhatsApp notifications
  static Future<void> setNotificationsEnabled(
      String userId, bool enabled) async {
    await _ensureBoxOpen(_settingsBox);
    final box = Hive.box(_settingsBox);
    await box.put('${userId}_enabled', enabled);
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled(String userId) async {
    await _ensureBoxOpen(_settingsBox);
    final box = Hive.box(_settingsBox);
    return box.get('${userId}_enabled', defaultValue: true) as bool;
  }

  /// Set notification preferences
  static Future<void> setNotificationPreferences(
    String userId,
    Map<WhatsAppMessageType, bool> preferences,
  ) async {
    await _ensureBoxOpen(_settingsBox);
    final box = Hive.box(_settingsBox);
    await box.put(
      '${userId}_preferences',
      preferences.map((k, v) => MapEntry(k.index.toString(), v)),
    );
  }

  /// Get notification preferences
  static Future<Map<WhatsAppMessageType, bool>> getNotificationPreferences(
      String userId) async {
    await _ensureBoxOpen(_settingsBox);
    final box = Hive.box(_settingsBox);

    final saved = box.get('${userId}_preferences') as Map?;
    if (saved == null) {
      // Default all enabled
      return {for (var type in WhatsAppMessageType.values) type: true};
    }

    return Map.fromEntries(
      saved.entries.map((e) => MapEntry(
            WhatsAppMessageType.values[int.parse(e.key.toString())],
            e.value as bool,
          )),
    );
  }

  // ==================== HELPERS ====================

  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Open WhatsApp Business for support
  static Future<void> openWhatsAppSupport() async {
    await sendWhatsAppMessage(
      phoneNumber: _businessNumber,
      message: 'Hello! I need help with TaxNG app.',
    );
  }

  /// Check if WhatsApp is available
  static Future<bool> isWhatsAppAvailable() async {
    final url = Uri.parse('https://wa.me/');
    return await canLaunchUrl(url);
  }
}
