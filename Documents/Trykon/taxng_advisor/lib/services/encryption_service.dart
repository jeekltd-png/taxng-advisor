import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const String _keyPrefix = 'taxng_';
  static const String _encKeyStorageKey = '${_keyPrefix}enc_key';
  static const String _encIvStorageKey = '${_keyPrefix}enc_iv';
  static const _storage = FlutterSecureStorage();

  static late encrypt.Key _key;
  static late encrypt.IV _iv;
  static late encrypt.Encrypter _encrypter;
  static bool _initialized = false;

  /// Generate a cryptographically secure random string of given byte length.
  static String _generateSecureRandom(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Initialize encryption service.
  /// Persists the key/IV in flutter_secure_storage so they survive restarts.
  static Future<void> initialize() async {
    try {
      // Try to load existing key & IV from secure storage
      String? storedKey = await _storage.read(key: _encKeyStorageKey);
      String? storedIv = await _storage.read(key: _encIvStorageKey);

      if (storedKey == null || storedIv == null) {
        // First run — generate and persist key + IV
        final keyBytes = _generateSecureRandom(32);
        final ivBytes = _generateSecureRandom(16);
        await _storage.write(key: _encKeyStorageKey, value: keyBytes);
        await _storage.write(key: _encIvStorageKey, value: ivBytes);
        storedKey = keyBytes;
        storedIv = ivBytes;
      }

      _key = encrypt.Key.fromBase64(storedKey);
      _iv = encrypt.IV.fromBase64(storedIv);
      _encrypter = encrypt.Encrypter(encrypt.AES(_key));
      _initialized = true;
      debugPrint('✅ Encryption service initialized');
    } catch (e) {
      debugPrint('⚠️ Encryption service init failed: $e');
      // Fallback — generate ephemeral key (data won't persist across restarts)
      _key = encrypt.Key.fromLength(32);
      _iv = encrypt.IV.fromLength(16);
      _encrypter = encrypt.Encrypter(encrypt.AES(_key));
      _initialized = true;
    }
  }

  /// Encrypt sensitive data
  static String encryptData(String data) {
    if (!_initialized) {
      debugPrint('⚠️ EncryptionService not initialized, returning data as-is');
      return data;
    }
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      debugPrint('❌ Encryption failed: $e');
      return data; // Return unencrypted if encryption fails
    }
  }

  /// Decrypt data
  static String decryptData(String encryptedData) {
    if (!_initialized) {
      return '';
    }
    try {
      final decrypted = _encrypter.decrypt64(encryptedData, iv: _iv);
      return decrypted;
    } catch (e) {
      debugPrint('❌ Decryption failed: $e');
      return ''; // Return empty if decryption fails
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

  /// Hash sensitive data (for comparison without storing plaintext)
  static String hashData(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
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
