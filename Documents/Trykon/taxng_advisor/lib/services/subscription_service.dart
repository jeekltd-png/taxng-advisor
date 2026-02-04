import 'package:taxng_advisor/services/hive_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/models/user.dart';

/// Service for managing user subscriptions and tier upgrades
class SubscriptionService {
  /// Upgrade request status
  static const String statusPending = 'pending'; // Initial request
  static const String statusPaymentProofSubmitted =
      'proof_submitted'; // User uploaded payment proof
  static const String statusUnderReview = 'under_review'; // Admin is reviewing
  static const String statusApproved =
      'approved'; // Payment verified and approved
  static const String statusRejected = 'rejected'; // Payment rejected/invalid

  /// Submit an upgrade request with payment
  static Future<void> submitUpgradeRequest({
    required String userId,
    required String currentTier,
    required String requestedTier,
    required String email,
    String? paymentReference,
    String? paymentProofPath, // Path to uploaded payment receipt/screenshot
    String? bankName, // Bank used for payment
    String? accountNumber, // Account number (last 4 digits)
    double? amountPaid, // Amount paid by user
    String? notes, // Additional notes from user
    String? billingCycle, // Monthly, Quarterly, or Annual
  }) async {
    final box = HiveService.getUpgradeRequestsBox();
    final now = DateTime.now();

    // Determine initial status based on proof submission
    String initialStatus;
    if (paymentReference != null) {
      // Auto-approved (from Paystack/automated payment)
      initialStatus = statusApproved;
    } else if (paymentProofPath != null) {
      // Manual payment with proof - needs admin review
      initialStatus = statusPaymentProofSubmitted;
    } else {
      // No payment yet - just a request
      initialStatus = statusPending;
    }

    final request = {
      'id': 'upgrade_${now.millisecondsSinceEpoch}',
      'userId': userId,
      'email': email,
      'currentTier': currentTier,
      'requestedTier': requestedTier,
      'status': initialStatus,
      'requestedAt': now.toIso8601String(),
      'processedAt': paymentReference != null ? now.toIso8601String() : null,
      'processedBy': paymentReference != null ? 'auto_payment' : null,
      'paymentReference': paymentReference,
      'paymentProofPath': paymentProofPath,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'amountPaid': amountPaid,
      'notes': notes,
      'billingCycle': billingCycle ?? 'Monthly',
      'proofSubmittedAt':
          paymentProofPath != null ? now.toIso8601String() : null,
    };

    await box.add(request);

    // If payment was made via Paystack, auto-approve and upgrade tier
    if (paymentReference != null) {
      await updateUserTier(userId, requestedTier);
    }
  }

  /// Get all upgrade requests (admin only)
  static Future<List<Map<String, dynamic>>> getUpgradeRequests({
    String? status,
  }) async {
    final box = HiveService.getUpgradeRequestsBox();
    var requests = box.values
        .cast<Map>()
        .map((r) => Map<String, dynamic>.from(r))
        .toList();

    if (status != null) {
      requests = requests.where((r) => r['status'] == status).toList();
    }

    // Sort by date, newest first
    requests.sort((a, b) {
      final aDate = DateTime.parse(a['requestedAt'] as String);
      final bDate = DateTime.parse(b['requestedAt'] as String);
      return bDate.compareTo(aDate);
    });

    return requests;
  }

  /// Submit payment proof for an existing request
  static Future<void> submitPaymentProof({
    required String requestId,
    required String paymentProofPath,
    String? paymentReference,
    String? bankName,
    String? accountNumber,
    double? amountPaid,
    String? notes,
  }) async {
    final box = HiveService.getUpgradeRequestsBox();

    for (int i = 0; i < box.length; i++) {
      final request = box.getAt(i) as Map;
      if (request['id'] == requestId) {
        final updatedRequest = Map<String, dynamic>.from(request);
        updatedRequest['status'] = statusPaymentProofSubmitted;
        updatedRequest['paymentProofPath'] = paymentProofPath;
        updatedRequest['paymentReference'] = paymentReference;
        updatedRequest['bankName'] = bankName;
        updatedRequest['accountNumber'] = accountNumber;
        updatedRequest['amountPaid'] = amountPaid;
        updatedRequest['notes'] = notes;
        updatedRequest['proofSubmittedAt'] = DateTime.now().toIso8601String();

        await box.putAt(i, updatedRequest);
        break;
      }
    }
  }

  /// Approve upgrade request (admin only)
  static Future<void> approveUpgradeRequest(
    String requestId,
    String adminUserId, {
    String? adminNotes,
  }) async {
    final box = HiveService.getUpgradeRequestsBox();

    // Find and update request
    for (int i = 0; i < box.length; i++) {
      final request = box.getAt(i) as Map;
      if (request['id'] == requestId) {
        final updatedRequest = Map<String, dynamic>.from(request);
        updatedRequest['status'] = statusApproved;
        updatedRequest['processedAt'] = DateTime.now().toIso8601String();
        updatedRequest['processedBy'] = adminUserId;
        updatedRequest['adminNotes'] = adminNotes;

        await box.putAt(i, updatedRequest);

        // Update user's subscription tier
        await updateUserTier(
          updatedRequest['userId'] as String,
          updatedRequest['requestedTier'] as String,
        );
        break;
      }
    }
  }

  /// Reject upgrade request (admin only)
  static Future<void> rejectUpgradeRequest(
    String requestId,
    String adminUserId, {
    String? rejectionReason,
  }) async {
    final box = HiveService.getUpgradeRequestsBox();

    for (int i = 0; i < box.length; i++) {
      final request = box.getAt(i) as Map;
      if (request['id'] == requestId) {
        final updatedRequest = Map<String, dynamic>.from(request);
        updatedRequest['status'] = statusRejected;
        updatedRequest['processedAt'] = DateTime.now().toIso8601String();
        updatedRequest['processedBy'] = adminUserId;
        updatedRequest['rejectionReason'] = rejectionReason;

        await box.putAt(i, updatedRequest);
        break;
      }
    }
  }

  /// Update user's subscription tier (admin only)
  static Future<void> updateUserTier(String userId, String newTier) async {
    final users = await AuthService.listUsers();
    // Find the user to verify they exist
    users.firstWhere((u) => u.id == userId);

    final box = await AuthService.openUsersBox();

    // Find user in box and update
    for (int i = 0; i < box.length; i++) {
      final userMap = box.getAt(i) as Map;
      if (userMap['id'] == userId) {
        final updatedUser = Map<String, dynamic>.from(userMap);
        updatedUser['subscriptionTier'] = newTier;
        updatedUser['modifiedAt'] = DateTime.now().toIso8601String();
        await box.putAt(i, updatedUser);
        break;
      }
    }
  }

  /// Check if user can access a feature based on tier
  static bool canAccessFeature(UserProfile user, String feature) {
    switch (feature) {
      case 'csv_export':
        return ['individual', 'business', 'enterprise']
            .contains(user.subscriptionTier);
      case 'pdf_export':
        return ['individual', 'business', 'enterprise']
            .contains(user.subscriptionTier);
      case 'official_pdf':
        return ['business', 'enterprise'].contains(user.subscriptionTier);
      case 'payment_links':
        return ['business', 'enterprise'].contains(user.subscriptionTier);
      case 'multi_user':
        return ['business', 'enterprise'].contains(user.subscriptionTier);
      case 'team_roles':
        return ['business', 'enterprise'].contains(user.subscriptionTier);
      case 'api_access':
        return user.subscriptionTier == 'enterprise';
      case 'white_label':
        return user.subscriptionTier == 'enterprise';
      default:
        return true; // Free features
    }
  }

  /// Get tier display name
  static String getTierDisplayName(String tier) {
    switch (tier) {
      case 'free':
        return 'Free';
      case 'individual':
        return 'Individual';
      case 'business':
        return 'Business';
      case 'enterprise':
        return 'Enterprise';
      default:
        return tier;
    }
  }

  /// Get tier color
  static String getTierColor(String tier) {
    switch (tier) {
      case 'free':
        return 'grey';
      case 'individual':
        return 'blue';
      case 'business':
        return 'orange';
      case 'enterprise':
        return 'purple';
      default:
        return 'grey';
    }
  }

  /// Mark request as under review (admin action)
  static Future<void> markUnderReview(
    String requestId,
    String adminUserId,
  ) async {
    final box = HiveService.getUpgradeRequestsBox();

    for (int i = 0; i < box.length; i++) {
      final request = box.getAt(i) as Map;
      if (request['id'] == requestId) {
        final updatedRequest = Map<String, dynamic>.from(request);
        updatedRequest['status'] = statusUnderReview;
        updatedRequest['reviewStartedAt'] = DateTime.now().toIso8601String();
        updatedRequest['reviewedBy'] = adminUserId;

        await box.putAt(i, updatedRequest);
        break;
      }
    }
  }

  /// Get status display name
  static String getStatusDisplayName(String status) {
    switch (status) {
      case statusPending:
        return 'Awaiting Payment';
      case statusPaymentProofSubmitted:
        return 'Payment Proof Submitted';
      case statusUnderReview:
        return 'Under Admin Review';
      case statusApproved:
        return 'Approved & Activated';
      case statusRejected:
        return 'Rejected';
      default:
        return status;
    }
  }

  /// Get status color
  static String getStatusColor(String status) {
    switch (status) {
      case statusPending:
        return 'orange';
      case statusPaymentProofSubmitted:
        return 'blue';
      case statusUnderReview:
        return 'purple';
      case statusApproved:
        return 'green';
      case statusRejected:
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Check if user has any active request (pending, proof submitted, or under review)
  static Future<bool> hasPendingRequest(String userId) async {
    final allRequests = await getUpgradeRequests();
    return allRequests.any((r) =>
        r['userId'] == userId &&
        [statusPending, statusPaymentProofSubmitted, statusUnderReview]
            .contains(r['status']));
  }

  /// Get user's latest request
  static Future<Map<String, dynamic>?> getLatestUserRequest(
      String userId) async {
    final allRequests = await getUpgradeRequests();
    final userRequests =
        allRequests.where((r) => r['userId'] == userId).toList();
    return userRequests.isNotEmpty ? userRequests.first : null;
  }
}
