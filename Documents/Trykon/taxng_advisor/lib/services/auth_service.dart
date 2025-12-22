import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const _usersBox = 'users';
  static const _currentUserKey = 'current_user_id';
  static final _secure = FlutterSecureStorage();

  /// Ensure users box is open
  static Future<Box> _openUsersBox() async {
    if (!Hive.isBoxOpen(_usersBox)) {
      return await Hive.openBox(_usersBox);
    }
    return Hive.box(_usersBox);
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<UserProfile?> register({
    required String username,
    required String password,
    required String email,
    bool isBusiness = false,
    String? businessName,
  }) async {
    final box = await _openUsersBox();

    // check unique username
    final exists = box.values.cast<Map>().any((u) => u['username'] == username);
    if (exists) return null;

    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final userMap = {
      'id': id,
      'username': username,
      'email': email,
      'isBusiness': isBusiness,
      'businessName': businessName,
      'hashedPassword': _hashPassword(password),
      'createdAt': now.toIso8601String(),
      'modifiedAt': now.toIso8601String(),
    };

    await box.add(userMap);
    await _secure.write(key: _currentUserKey, value: id);

    return UserProfile.fromMap(userMap);
  }

  static Future<UserProfile?> login(String username, String password) async {
    final box = await _openUsersBox();
    final hashed = _hashPassword(password);

    final record = box.values.cast<Map>().firstWhere(
          (u) => u['username'] == username && u['hashedPassword'] == hashed,
          orElse: () => {},
        );

    if (record.isEmpty) return null;

    await _secure.write(key: _currentUserKey, value: record['id'] as String);
    return UserProfile.fromMap(record.cast<String, dynamic>());
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

  /// Seed a few test users for local development if they don't exist.
  static Future<void> seedTestUsers() async {
    final box = await _openUsersBox();

    final existingUsernames =
        box.values.cast<Map>().map((u) => u['username']).toSet();

    final seeds = [
      {
        'username': 'testuser',
        'password': 'Test@1234',
        'email': 'testuser@example.com',
        'isBusiness': false,
        'businessName': null,
      },
      {
        'username': 'business1',
        'password': 'Biz@1234',
        'email': 'biz1@example.com',
        'isBusiness': true,
        'businessName': 'Acme LLC',
      },
      {
        'username': 'admin',
        'password': 'Admin@123',
        'email': 'admin@example.com',
        'isBusiness': false,
        'businessName': null,
        'isAdmin': true,
      },
    ];

    for (final s in seeds) {
      final uname = s['username'] as String;
      if (existingUsernames.contains(uname)) continue;

      final id = 'user_${DateTime.now().millisecondsSinceEpoch}_${uname}';
      final now = DateTime.now();
      final userMap = {
        'id': id,
        'username': uname,
        'email': s['email'],
        'isBusiness': s['isBusiness'],
        'businessName': s['businessName'],
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
          createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
              DateTime.now(),
          modifiedAt: DateTime.tryParse(m['modifiedAt'] as String? ?? '') ??
              DateTime.now(),
        );
      }
    }).toList();

    return list;
  }
}
