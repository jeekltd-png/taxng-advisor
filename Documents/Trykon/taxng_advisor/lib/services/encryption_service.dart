import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const String _keyPrefix = 'taxng_';
  static final _storage = FlutterSecureStorage();

  // Initialize encryption key - in production, derive from secure source
  static final _key = encrypt.Key.fromLength(32);
  static final _iv = encrypt.IV.fromLength(16);
  static late encrypt.Encrypter _encrypter;

  /// Initialize encryption service
  static void initialize() {
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
    print('✅ Encryption service initialized');
  }

  /// Encrypt sensitive data
  static String encryptData(String data) {
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('❌ Encryption failed: $e');
      return data; // Return unencrypted if encryption fails
    }
  }

  /// Decrypt data
  static String decryptData(String encryptedData) {
    try {
      final decrypted = _encrypter.decrypt64(encryptedData, iv: _iv);
      return decrypted;
    } catch (e) {
      print('❌ Decryption failed: $e');
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
      print('✅ Auth token stored securely');
    } catch (e) {
      print('❌ Failed to store auth token: $e');
    }
  }

  /// Retrieve encrypted token
  static Future<String?> getAuthToken() async {
    try {
      final encrypted = await _storage.read(key: '${_keyPrefix}auth_token');
      return encrypted != null ? decryptData(encrypted) : null;
    } catch (e) {
      print('❌ Failed to retrieve auth token: $e');
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
      print('✅ Business data encrypted and stored');
    } catch (e) {
      print('❌ Failed to store business data: $e');
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
      print('❌ Failed to retrieve business data: $e');
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
      print('✅ Calculation result encrypted and stored');
    } catch (e) {
      print('❌ Failed to store calculation result: $e');
    }
  }

  /// Delete sensitive data
  static Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: '${_keyPrefix}auth_token');
      print('✅ Auth token deleted');
    } catch (e) {
      print('❌ Failed to delete auth token: $e');
    }
  }

  /// Clear all encrypted data
  static Future<void> clearAllEncryptedData() async {
    try {
      await _storage.deleteAll();
      print('✅ All encrypted data cleared');
    } catch (e) {
      print('❌ Failed to clear encrypted data: $e');
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
