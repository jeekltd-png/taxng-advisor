import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/hive_service.dart';

/// Backend Service — Abstraction layer for remote API communication.
///
/// This service provides a clean interface for all backend operations.
/// Currently uses local Hive storage as a fallback while the backend
/// is being provisioned. Replace the implementation methods with
/// real API calls when your backend is ready.
///
/// Production backend requirements:
/// 1. Firebase / Supabase / Custom REST API
/// 2. Server-side auth token validation
/// 3. Paystack webhook verification endpoint
/// 4. Subscription status enforcement
/// 5. Rate data push/pull
class BackendService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'taxng_backend_token';
  static const String _refreshTokenKey = 'taxng_refresh_token';

  // TODO: Replace with your production API URL
  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://api.taxpadi.com',
  );

  static bool _isConfigured = false;
  static String? _authToken;

  /// Initialize the backend service
  static Future<void> initialize() async {
    try {
      _authToken = await _storage.read(key: _tokenKey);
      _isConfigured = _authToken != null;
      debugPrint(_isConfigured
          ? '✅ Backend service initialized with auth token'
          : '⚠️ Backend service: no auth token — running in offline mode');
    } catch (e) {
      debugPrint('⚠️ Backend service init error: $e');
      _isConfigured = false;
    }
  }

  /// Check if backend is configured and reachable
  static bool get isConfigured => _isConfigured;

  /// Get the base URL (for debug display)
  static String get baseUrl => _baseUrl;

  // ──────────────────────────────────────────────
  // AUTH
  // ──────────────────────────────────────────────

  /// Authenticate with backend and get a session token
  /// Returns the auth token on success, null on failure.
  static Future<String?> authenticateWithBackend({
    required String username,
    required String passwordHash,
  }) async {
    // TODO: Implement real API call
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/auth/login'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'username': username, 'passwordHash': passwordHash}),
    // );
    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body);
    //   _authToken = data['token'];
    //   await _storage.write(key: _tokenKey, value: _authToken);
    //   await _storage.write(key: _refreshTokenKey, value: data['refreshToken']);
    //   _isConfigured = true;
    //   return _authToken;
    // }
    debugPrint('⚠️ Backend auth not yet implemented — offline mode');
    return null;
  }

  /// Refresh the auth token
  static Future<String?> refreshAuthToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return null;

      // TODO: Implement real API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/refresh'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'refreshToken': refreshToken}),
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   _authToken = data['token'];
      //   await _storage.write(key: _tokenKey, value: _authToken);
      //   return _authToken;
      // }
      return null;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return null;
    }
  }

  /// Clear stored tokens on logout
  static Future<void> clearTokens() async {
    _authToken = null;
    _isConfigured = false;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // ──────────────────────────────────────────────
  // PAYMENT VERIFICATION
  // ──────────────────────────────────────────────

  /// Verify a Paystack payment on the backend.
  /// The backend should call Paystack's verify endpoint with the SECRET key.
  /// NEVER verify payments client-side in production.
  static Future<PaymentVerificationResult> verifyPayment(
      String reference) async {
    if (!_isConfigured) {
      debugPrint('⚠️ Backend not configured — cannot verify payment');
      return PaymentVerificationResult(
        verified: false,
        message: 'Backend service unavailable. Payment verification pending.',
        requiresManualReview: true,
      );
    }

    try {
      // TODO: Implement real API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/payments/verify/$reference'),
      //   headers: {
      //     'Authorization': 'Bearer $_authToken',
      //     'Content-Type': 'application/json',
      //   },
      // ).timeout(const Duration(seconds: 30));
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return PaymentVerificationResult(
      //     verified: data['status'] == 'success',
      //     message: data['message'] ?? 'Verified',
      //     amount: (data['amount'] as num?)?.toDouble(),
      //     currency: data['currency'],
      //   );
      // }

      return PaymentVerificationResult(
        verified: false,
        message: 'Payment verification endpoint not yet configured.',
        requiresManualReview: true,
      );
    } catch (e) {
      debugPrint('Payment verification error: $e');
      return PaymentVerificationResult(
        verified: false,
        message: 'Verification failed: $e',
        requiresManualReview: true,
      );
    }
  }

  // ──────────────────────────────────────────────
  // SUBSCRIPTION MANAGEMENT
  // ──────────────────────────────────────────────

  /// Check subscription status from backend
  static Future<SubscriptionStatus> checkSubscriptionStatus(
      String userId) async {
    if (!_isConfigured) {
      // Fallback to local check
      return _getLocalSubscriptionStatus(userId);
    }

    try {
      // TODO: Implement real API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/subscriptions/$userId/status'),
      //   headers: {'Authorization': 'Bearer $_authToken'},
      // ).timeout(const Duration(seconds: 10));
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   // Cache the result locally
      //   await _cacheSubscriptionStatus(userId, data);
      //   return SubscriptionStatus.fromJson(data);
      // }

      return _getLocalSubscriptionStatus(userId);
    } catch (e) {
      debugPrint('Subscription check error: $e');
      return _getLocalSubscriptionStatus(userId);
    }
  }

  static Future<SubscriptionStatus> _getLocalSubscriptionStatus(
      String userId) async {
    try {
      final box = HiveService.getUsersBox();
      final userMap = box.values.cast<Map>().firstWhere(
            (u) => u['id'] == userId,
            orElse: () => {},
          );
      if (userMap.isEmpty) {
        return SubscriptionStatus(tier: 'free', isActive: false);
      }
      return SubscriptionStatus(
        tier: userMap['subscriptionTier'] as String? ?? 'free',
        isActive: true,
      );
    } catch (e) {
      return SubscriptionStatus(tier: 'free', isActive: false);
    }
  }

  // ──────────────────────────────────────────────
  // TAX RATE UPDATES
  // ──────────────────────────────────────────────

  /// Fetch latest tax rates from backend
  static Future<Map<String, dynamic>?> fetchLatestTaxRates() async {
    if (!_isConfigured) return null;

    try {
      // TODO: Implement real API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/tax-rates/ng/latest'),
      //   headers: {'Authorization': 'Bearer $_authToken'},
      // ).timeout(const Duration(seconds: 10));
      //
      // if (response.statusCode == 200) {
      //   return jsonDecode(response.body) as Map<String, dynamic>;
      // }
      return null;
    } catch (e) {
      debugPrint('Tax rate fetch error: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // DATA SYNC
  // ──────────────────────────────────────────────

  /// Upload a tax calculation record to the backend
  static Future<bool> uploadTaxRecord(Map<String, dynamic> record) async {
    if (!_isConfigured) return false;

    try {
      // TODO: Implement real API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/tax-records'),
      //   headers: {
      //     'Authorization': 'Bearer $_authToken',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode(record),
      // ).timeout(const Duration(seconds: 30));
      //
      // return response.statusCode == 200 || response.statusCode == 201;
      return false;
    } catch (e) {
      debugPrint('Record upload error: $e');
      return false;
    }
  }

  /// Pull all tax records from backend for a user
  static Future<List<Map<String, dynamic>>?> pullTaxRecords(
      String userId) async {
    if (!_isConfigured) return null;

    try {
      // TODO: Implement real API call
      return null;
    } catch (e) {
      debugPrint('Record pull error: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // BANK ACCOUNT CONFIG (from backend, not hardcoded)
  // ──────────────────────────────────────────────

  /// Fetch bank account details from backend (never hardcode in client)
  static Future<List<Map<String, String>>?> fetchBankAccounts() async {
    if (!_isConfigured) return null;

    try {
      // TODO: Implement real API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/config/bank-accounts'),
      //   headers: {'Authorization': 'Bearer $_authToken'},
      // ).timeout(const Duration(seconds: 10));
      //
      // if (response.statusCode == 200) {
      //   final list = jsonDecode(response.body) as List;
      //   return list.map((e) => Map<String, String>.from(e)).toList();
      // }
      return null;
    } catch (e) {
      debugPrint('Bank account fetch error: $e');
      return null;
    }
  }
}

/// Result of a payment verification attempt
class PaymentVerificationResult {
  final bool verified;
  final String message;
  final double? amount;
  final String? currency;
  final bool requiresManualReview;

  PaymentVerificationResult({
    required this.verified,
    required this.message,
    this.amount,
    this.currency,
    this.requiresManualReview = false,
  });
}

/// Subscription status from backend
class SubscriptionStatus {
  final String tier;
  final bool isActive;
  final DateTime? expiresAt;
  final bool isTrialing;

  SubscriptionStatus({
    required this.tier,
    required this.isActive,
    this.expiresAt,
    this.isTrialing = false,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      tier: json['tier'] as String? ?? 'free',
      isActive: json['isActive'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      isTrialing: json['isTrialing'] as bool? ?? false,
    );
  }
}
