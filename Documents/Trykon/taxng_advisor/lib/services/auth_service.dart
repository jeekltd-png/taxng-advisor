import 'dart:math';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const _usersBox = 'users';
  static const _currentUserKey = 'current_user_id';
  static final _secure = FlutterSecureStorage();

  // --- Rate Limiting ---
  static final Map<String, List<DateTime>> _loginAttempts = {};
  static const int _maxAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  /// Ensure users box is open
  static Future<Box> _openUsersBox() async {
    if (!Hive.isBoxOpen(_usersBox)) {
      return await Hive.openBox(_usersBox);
    }
    return Hive.box(_usersBox);
  }

  /// Expose openUsersBox for subscription service
  static Future<Box> openUsersBox() => _openUsersBox();

  /// Generate a cryptographically secure random salt
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  /// Hash password with salt using HMAC-SHA256 + multiple iterations.
  /// This provides significantly better protection than plain SHA-256.
  static String _hashPassword(String password, {String? salt}) {
    final passwordSalt = salt ?? _generateSalt();
    // Use PBKDF2-like iterative hashing for brute-force resistance
    var bytes = utf8.encode('$passwordSalt:$password');
    var digest = sha256.convert(bytes);
    // 10,000 iterations for key stretching
    for (int i = 0; i < 10000; i++) {
      final hmac = Hmac(sha256, utf8.encode(passwordSalt));
      digest = hmac.convert(digest.bytes);
    }
    // Store salt:hash so we can verify later
    return '$passwordSalt:${digest.toString()}';
  }

  /// Verify a password against a stored salted hash
  static bool _verifyPassword(String password, String storedHash) {
    // Legacy unsalted hash support (for existing users before migration)
    if (!storedHash.contains(':') || storedHash.length == 64) {
      final legacyHash = sha256.convert(utf8.encode(password)).toString();
      if (legacyHash == storedHash) return true;
      return false;
    }

    final parts = storedHash.split(':');
    if (parts.length < 2) return false;
    final salt = parts[0];
    final expectedHash = _hashPassword(password, salt: salt);
    return expectedHash == storedHash;
  }

  /// Check if a user is rate-limited
  static bool isRateLimited(String username) {
    final attempts = _loginAttempts[username];
    if (attempts == null) return false;

    // Remove old attempts outside the lockout window
    final cutoff = DateTime.now().subtract(_lockoutDuration);
    attempts.removeWhere((t) => t.isBefore(cutoff));

    return attempts.length >= _maxAttempts;
  }

  /// Record a failed login attempt
  static void _recordFailedAttempt(String username) {
    _loginAttempts.putIfAbsent(username, () => []);
    _loginAttempts[username]!.add(DateTime.now());
  }

  /// Clear login attempts on successful login
  static void _clearAttempts(String username) {
    _loginAttempts.remove(username);
  }

  /// Get remaining lockout time in seconds
  static int getRemainingLockoutSeconds(String username) {
    final attempts = _loginAttempts[username];
    if (attempts == null || attempts.isEmpty) return 0;

    final cutoff = DateTime.now().subtract(_lockoutDuration);
    attempts.removeWhere((t) => t.isBefore(cutoff));

    if (attempts.length < _maxAttempts) return 0;

    final oldestRelevant = attempts.first;
    final unlockTime = oldestRelevant.add(_lockoutDuration);
    final remaining = unlockTime.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Validate password strength
  static String? validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null; // Valid
  }

  static Future<UserProfile?> register({
    required String username,
    required String password,
    required String email,
    String? firstName,
    String? lastName,
    bool isBusiness = false,
    String? businessName,
    String? tin,
    String? cacNumber,
    String? bvn,
    String? vatNumber,
    String? payeRef,
    String? phoneNumber,
    String? address,
    String? taxOffice,
    String? industrySector,
  }) async {
    final box = await _openUsersBox();

    // Check unique username
    final exists = box.values.cast<Map>().any((u) => u['username'] == username);
    if (exists) return null;

    // Validate password strength
    final passwordError = validatePasswordStrength(password);
    if (passwordError != null) {
      debugPrint('Registration failed: $passwordError');
      return null;
    }

    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final userMap = {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'isBusiness': isBusiness,
      'businessName': businessName,
      'tin': tin,
      'cacNumber': cacNumber,
      'bvn': bvn,
      'vatNumber': vatNumber,
      'payeRef': payeRef,
      'phoneNumber': phoneNumber,
      'address': address,
      'taxOffice': taxOffice,
      'tccExpiryDate': null,
      'industrySector': industrySector,
      'subscriptionTier': 'free',
      'hashedPassword': _hashPassword(password),
      'createdAt': now.toIso8601String(),
      'modifiedAt': now.toIso8601String(),
    };

    await box.add(userMap);
    await _secure.write(key: _currentUserKey, value: id);

    return UserProfile.fromMap(userMap);
  }

  static Future<UserProfile?> login(String username, String password) async {
    // Check rate limiting
    if (isRateLimited(username)) {
      final remaining = getRemainingLockoutSeconds(username);
      debugPrint(
          'Account locked. Try again in ${remaining ~/ 60}m ${remaining % 60}s');
      return null;
    }

    final box = await _openUsersBox();

    // Find user by username first, then verify password separately
    final record = box.values.cast<Map>().firstWhere(
          (u) => u['username'] == username,
          orElse: () => {},
        );

    if (record.isEmpty) {
      _recordFailedAttempt(username);
      return null;
    }

    final storedHash = record['hashedPassword'] as String? ?? '';
    if (!_verifyPassword(password, storedHash)) {
      _recordFailedAttempt(username);
      return null;
    }

    // Successful login — clear attempts
    _clearAttempts(username);

    // Migrate legacy unsalted hash to salted hash on successful login
    if (!storedHash.contains(':') || storedHash.length == 64) {
      await _migratePasswordHash(box, record, password);
    }

    await _secure.write(key: _currentUserKey, value: record['id'] as String);
    return UserProfile.fromMap(record.cast<String, dynamic>());
  }

  /// Migrate a user's legacy unsalted hash to the new salted hash format
  static Future<void> _migratePasswordHash(
      Box box, Map record, String password) async {
    try {
      for (int i = 0; i < box.length; i++) {
        final r = box.getAt(i) as Map?;
        if (r != null && r['id'] == record['id']) {
          final updated = Map<String, dynamic>.from(r.cast<String, dynamic>());
          updated['hashedPassword'] = _hashPassword(password);
          updated['modifiedAt'] = DateTime.now().toIso8601String();
          await box.putAt(i, updated);
          debugPrint('✅ Migrated password hash for ${record['username']}');
          break;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to migrate password hash: $e');
    }
  }

  static Future<void> logout() async {
    await _secure.delete(key: _currentUserKey);
  }

  static Future<UserProfile?> currentUser() async {
    final id = await _secure.read(key: _currentUserKey);
    if (id == null) return null;
    final box = await _openUsersBox();
    final rec = box.values
        .cast<Map>()
        .firstWhere((u) => u['id'] == id, orElse: () => {});
    if (rec.isEmpty) return null;
    return UserProfile.fromMap(rec.cast<String, dynamic>());
  }

  /// Alias for currentUser for backward compatibility
  Future<UserProfile?> getCurrentUser() async {
    return AuthService.currentUser();
  }

  /// Get user by ID
  static Future<UserProfile?> getUserById(String userId) async {
    final box = await _openUsersBox();
    final rec = box.values
        .cast<Map>()
        .firstWhere((u) => u['id'] == userId, orElse: () => {});
    if (rec.isEmpty) return null;
    return UserProfile.fromMap(rec.cast<String, dynamic>());
  }

  /// Seed default users including admin on first launch.
  static Future<void> seedTestUsers() async {
    final box = await _openUsersBox();
    final existingUsernames =
        box.values.cast<Map>().map((u) => u['username']).toSet();

    final seeds = [
      {
        'username': 'admin',
        'password': 'Admin@123',
        'email': 'admin@taxpadi.com',
        'isBusiness': true,
        'businessName': 'TaxPadi Admin',
        'isAdmin': true,
        'subscriptionTier': 'business',
      },
      {
        'username': 'subadmin1',
        'password': 'SubAdmin1@123',
        'email': 'subadmin1@taxpadi.com',
        'isBusiness': true,
        'businessName': 'TaxPadi Support',
        'isAdmin': true,
        'subscriptionTier': 'business',
      },
      {
        'username': 'subadmin2',
        'password': 'SubAdmin2@123',
        'email': 'subadmin2@taxpadi.com',
        'isBusiness': true,
        'businessName': 'TaxPadi Support 2',
        'isAdmin': true,
        'subscriptionTier': 'business',
      },
      {
        'username': 'testuser',
        'password': 'Test@1234',
        'email': 'testuser@example.com',
        'isBusiness': false,
        'businessName': null,
      },
      {
        'username': 'business1',
        'password': 'Biz@12345',
        'email': 'biz1@example.com',
        'isBusiness': true,
        'businessName': 'Acme LLC',
      },
    ];

    for (final s in seeds) {
      final uname = s['username'] as String;
      if (existingUsernames.contains(uname)) continue;

      final id = 'user_${DateTime.now().millisecondsSinceEpoch}_$uname';
      final now = DateTime.now();
      final userMap = {
        'id': id,
        'username': uname,
        'email': s['email'],
        'isBusiness': s['isBusiness'],
        'businessName': s['businessName'],
        'industrySector': s['industrySector'],
        'subscriptionTier': s['subscriptionTier'] ?? 'free',
        'isAdmin': s['isAdmin'] ?? false,
        'hashedPassword': _hashPassword(s['password'] as String),
        'createdAt': now.toIso8601String(),
        'modifiedAt': now.toIso8601String(),
      };

      await box.add(userMap);
    }
  }

  /// Return all users currently stored (for debug/dev UI)
  static Future<List<UserProfile>> listUsers() async {
    final box = await _openUsersBox();
    final list = box.values.cast<Map>().map((m) {
      try {
        return UserProfile.fromMap(m.cast<String, dynamic>());
      } catch (_) {
        return UserProfile(
          id: m['id'] as String? ?? '',
          username: m['username'] as String? ?? '',
          email: m['email'] as String? ?? '',
          isBusiness: m['isBusiness'] as bool? ?? false,
          businessName: m['businessName'] as String?,
          industrySector: m['industrySector'] as String?,
          createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
              DateTime.now(),
          modifiedAt: DateTime.tryParse(m['modifiedAt'] as String? ?? '') ??
              DateTime.now(),
        );
      }
    }).toList();

    return list;
  }

  /// Verify user exists by username or email for password reset
  static Future<String?> verifyUserForPasswordReset(
      String usernameOrEmail) async {
    final box = await _openUsersBox();
    final input = usernameOrEmail.trim().toLowerCase();

    for (final userMap in box.values.cast<Map>()) {
      final username = (userMap['username'] as String?)?.toLowerCase();
      final email = (userMap['email'] as String?)?.toLowerCase();

      if (username == input || email == input) {
        return userMap['username'] as String;
      }
    }

    return null;
  }

  /// Reset password for a user
  static Future<bool> resetPassword(String username, String newPassword) async {
    // Validate new password strength
    final passwordError = validatePasswordStrength(newPassword);
    if (passwordError != null) {
      debugPrint('Password reset failed: $passwordError');
      return false;
    }

    final box = await _openUsersBox();

    int? userIndex;
    Map? userMap;
    for (int i = 0; i < box.length; i++) {
      final record = box.getAt(i) as Map?;
      if (record != null && record['username'] == username) {
        userIndex = i;
        userMap = record;
        break;
      }
    }

    if (userIndex == null || userMap == null) return false;

    final updatedMap =
        Map<String, dynamic>.from(userMap.cast<String, dynamic>());
    updatedMap['hashedPassword'] = _hashPassword(newPassword);
    updatedMap['modifiedAt'] = DateTime.now().toIso8601String();

    await box.putAt(userIndex, updatedMap);
    return true;
  }
}
