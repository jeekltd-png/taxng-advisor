import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart' as crypto;

class EncryptionService {
  static const String _keyPrefix = 'taxng_';
  static const String _encKeyStorageKey = '${_keyPrefix}enc_key';
  static const _storage = FlutterSecureStorage();

  static late encrypt.Key _key;
  static late encrypt.Encrypter _encrypter;
  static bool _initialized = false;

  /// Generate a cryptographically secure random string of given byte length.
  static String _generateSecureRandom(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Generate a random IV for each encryption operation
  static encrypt.IV _generateRandomIV() {
    final random = Random.secure();
    final ivBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return encrypt.IV(Uint8List.fromList(ivBytes));
  }

  /// Initialize encryption service.
  /// Persists only the key in flutter_secure_storage (IV is per-operation).
  static Future<void> initialize() async {
    try {
      String? storedKey = await _storage.read(key: _encKeyStorageKey);

      if (storedKey == null) {
        // First run — generate and persist key
        final keyBytes = _generateSecureRandom(32);
        await _storage.write(key: _encKeyStorageKey, value: keyBytes);
        storedKey = keyBytes;
      }

      _key = encrypt.Key.fromBase64(storedKey);
      _encrypter = encrypt.Encrypter(encrypt.AES(_key));
      _initialized = true;
      debugPrint('✅ Encryption service initialized');
    } catch (e) {
      debugPrint('⚠️ Encryption service init failed: $e');
      // Fallback — generate ephemeral key (data won't persist across restarts)
      _key = encrypt.Key.fromLength(32);
      _encrypter = encrypt.Encrypter(encrypt.AES(_key));
      _initialized = true;
    }
  }

  /// Encrypt sensitive data with a random IV prepended to the ciphertext.
  /// Format: base64(IV) + ':' + base64(ciphertext)
  static String encryptData(String data) {
    if (!_initialized) {
      throw StateError(
          'EncryptionService not initialized. Call initialize() first.');
    }
    try {
      final iv = _generateRandomIV();
      final encrypted = _encrypter.encrypt(data, iv: iv);
      // Prepend the IV so decryption can extract it
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      debugPrint('❌ Encryption failed: $e');
      rethrow; // Never silently return plaintext
    }
  }

  /// Decrypt data. Supports both new format (iv:ciphertext) and legacy format.
  static String decryptData(String encryptedData) {
    if (!_initialized) {
      throw StateError(
          'EncryptionService not initialized. Call initialize() first.');
    }
    try {
      if (encryptedData.contains(':')) {
        // New format: iv:ciphertext
        final parts = encryptedData.split(':');
        final iv = encrypt.IV.fromBase64(parts[0]);
        final ciphertext = parts.sublist(1).join(':');
        return _encrypter.decrypt64(ciphertext, iv: iv);
      } else {
        // Legacy format — try with a zero IV for backward compatibility
        final legacyIv = encrypt.IV.fromLength(16);
        return _encrypter.decrypt64(encryptedData, iv: legacyIv);
      }
    } catch (e) {
      debugPrint('❌ Decryption failed: $e');
      return '';
    }
  }

  /// Store encrypted token securely
  static Future<void> storeAuthToken(String token) async {
    try {
      await _storage.write(
        key: '${_keyPrefix}auth_token',
        value: encryptData(token),
      );
      debugPrint('✅ Auth token stored securely');
    } catch (e) {
      debugPrint('❌ Failed to store auth token: $e');
    }
  }

  /// Retrieve encrypted token
  static Future<String?> getAuthToken() async {
    try {
      final encrypted = await _storage.read(key: '${_keyPrefix}auth_token');
      return encrypted != null ? decryptData(encrypted) : null;
    } catch (e) {
      debugPrint('❌ Failed to retrieve auth token: $e');
      return null;
    }
  }

  /// Store encrypted business data
  static Future<void> storeBusinessData(
      String businessId, Map<String, dynamic> data) async {
    try {
      final jsonString = data.toString();
      final encrypted = encryptData(jsonString);
      await _storage.write(
        key: '${_keyPrefix}business_$businessId',
        value: encrypted,
      );
      debugPrint('✅ Business data encrypted and stored');
    } catch (e) {
      debugPrint('❌ Failed to store business data: $e');
    }
  }

  /// Retrieve encrypted business data
  static Future<Map<String, dynamic>?> getBusinessData(
      String businessId) async {
    try {
      final encrypted =
          await _storage.read(key: '${_keyPrefix}business_$businessId');
      if (encrypted == null) return null;

      final decrypted = decryptData(encrypted);
      // Parse the decrypted data back to map if needed
      return {'data': decrypted};
    } catch (e) {
      debugPrint('❌ Failed to retrieve business data: $e');
      return null;
    }
  }

  /// Store encrypted calculation result
  static Future<void> storeCalculationResult(
      String resultId, Map<String, dynamic> result) async {
    try {
      final jsonString = result.toString();
      final encrypted = encryptData(jsonString);
      await _storage.write(
        key: '${_keyPrefix}result_$resultId',
        value: encrypted,
      );
      debugPrint('✅ Calculation result encrypted and stored');
    } catch (e) {
      debugPrint('❌ Failed to store calculation result: $e');
    }
  }

  /// Delete sensitive data
  static Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: '${_keyPrefix}auth_token');
      debugPrint('✅ Auth token deleted');
    } catch (e) {
      debugPrint('❌ Failed to delete auth token: $e');
    }
  }

  /// Clear all encrypted data
  static Future<void> clearAllEncryptedData() async {
    try {
      await _storage.deleteAll();
      debugPrint('✅ All encrypted data cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear encrypted data: $e');
    }
  }

  /// Hash sensitive data using SHA-256 (one-way, for comparison)
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify hashed data
  static bool verifyHashedData(String originalData, String hash) {
    try {
      final newHash = hashData(originalData);
      return newHash == hash;
    } catch (e) {
      return false;
    }
  }
}
