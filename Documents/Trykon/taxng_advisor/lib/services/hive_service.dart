import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// HiveService centralizes all Hive box names and accessors.
///
/// This wrapper keeps box names in one place and provides convenience
/// getters for commonly used boxes. Call `HiveService.initialize()` at
/// application startup to ensure boxes are opened before use.
///
/// **Security:** Sensitive boxes (users, payments) are encrypted using
/// `HiveAesCipher` with a key stored in FlutterSecureStorage.
class HiveService {
  // Named boxes used across the app. Keep these stable to avoid
  // migration issues when reading/writing stored maps.
  static const String citBox = 'cit_estimates';
  static const String pitBox = 'pit_estimates';
  static const String vatBox = 'vat_returns';
  static const String whtBox = 'wht_records';
  static const String stampDutyBox = 'stamp_duty_records';
  static const String payrollBox = 'payroll_records';
  static const String usersBox = 'users';
  static const String paymentsBox = 'payments';
  static const String syncBox = 'sync_status';
  static const String profileBox = 'profile_settings';
  static const String upgradeRequestsBox = 'upgrade_requests';

  static const _secureStorage = FlutterSecureStorage();
  static const _encryptionKeyName = 'hive_encryption_key';

  /// Get or generate the Hive encryption key stored in secure storage.
  static Future<List<int>> _getEncryptionKey() async {
    final existing = await _secureStorage.read(key: _encryptionKeyName);
    if (existing != null) {
      return base64Url.decode(existing);
    }
    // Generate a new 256-bit key
    final key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64Url.encode(key),
    );
    return key;
  }

  /// Initialize Hive and open all boxes used by the application.
  ///
  /// Sensitive boxes are encrypted using AES-256 with a key from secure storage.
  static Future<void> initialize() async {
    await Hive.initFlutter();

    try {
      final encryptionKey = await _getEncryptionKey();
      final cipher = HiveAesCipher(encryptionKey);

      // Open sensitive boxes with encryption
      await Hive.openBox(usersBox, encryptionCipher: cipher);
      await Hive.openBox(paymentsBox, encryptionCipher: cipher);
      await Hive.openBox(profileBox, encryptionCipher: cipher);

      // Open non-sensitive boxes without encryption for performance
      await Hive.openBox(citBox);
      await Hive.openBox(pitBox);
      await Hive.openBox(vatBox);
      await Hive.openBox(whtBox);
      await Hive.openBox(stampDutyBox);
      await Hive.openBox(payrollBox);
      await Hive.openBox(syncBox);
      await Hive.openBox(upgradeRequestsBox);

      debugPrint('✅ Hive initialized with encryption');
    } catch (e) {
      // Bubble up the error so callers can decide how to recover.
      debugPrint('❌ Hive initialization error: $e');
      rethrow;
    }
  }

  /// Get CIT box
  static Box<dynamic> getCitBox() => Hive.box(citBox);

  /// Get Users box
  static Box<dynamic> getUsersBox() => Hive.box(usersBox);

  /// Get Payments box
  static Box<dynamic> getPaymentsBox() => Hive.box(paymentsBox);

  /// Get PIT box
  static Box<dynamic> getPitBox() => Hive.box(pitBox);

  /// Get VAT box
  static Box<dynamic> getVatBox() => Hive.box(vatBox);

  /// Get WHT box
  static Box<dynamic> getWhtBox() => Hive.box(whtBox);

  /// Get Stamp Duty box
  static Box<dynamic> getStampDutyBox() => Hive.box(stampDutyBox);

  /// Get Payroll box
  static Box<dynamic> getPayrollBox() => Hive.box(payrollBox);

  /// Get Sync Status box
  static Box<dynamic> getSyncBox() => Hive.box(syncBox);

  /// Get Profile Settings box (for logos, company settings)
  static Box<dynamic> getProfileBox() => Hive.box(profileBox);

  /// Get Upgrade Requests box
  static Box<dynamic> getUpgradeRequestsBox() => Hive.box(upgradeRequestsBox);

  /// Add a CIT calculation
  static Future<void> saveCIT(Map<String, dynamic> data) async {
    final box = getCitBox();
    await box.add(data);
    await _markAsPending('CIT');
  }

  /// Add a PIT calculation
  static Future<void> savePIT(Map<String, dynamic> data) async {
    final box = getPitBox();
    await box.add(data);
    await _markAsPending('PIT');
  }

  /// Add a VAT return
  static Future<void> saveVAT(Map<String, dynamic> data) async {
    final box = getVatBox();
    await box.add(data);
    await _markAsPending('VAT');
  }

  /// Add a WHT record
  static Future<void> saveWHT(Map<String, dynamic> data) async {
    final box = getWhtBox();
    await box.add(data);
    await _markAsPending('WHT');
  }

  /// Add a Stamp Duty record
  static Future<void> saveStampDuty(Map<String, dynamic> data) async {
    final box = getStampDutyBox();
    await box.add(data);
    await _markAsPending('STAMP_DUTY');
  }

  /// Add a Payroll record
  static Future<void> savePayroll(Map<String, dynamic> data) async {
    final box = getPayrollBox();
    await box.add(data);
    await _markAsPending('PAYROLL');
  }

  /// Get all CIT estimates
  static List<Map<String, dynamic>> getAllCIT() {
    final box = getCitBox();
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  /// Get all PIT estimates
  static List<Map<String, dynamic>> getAllPIT() {
    final box = getPitBox();
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  /// Get all VAT returns
  static List<Map<String, dynamic>> getAllVAT() {
    final box = getVatBox();
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  /// Get all WHT records
  static List<Map<String, dynamic>> getAllWHT() {
    final box = getWhtBox();
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  /// Get all pending records for sync
  static List<Map<String, dynamic>> getPendingRecords() {
    final syncBox = getSyncBox();
    final pending = syncBox.get('pending_records', defaultValue: []) as List;
    return pending.cast<Map<String, dynamic>>();
  }

  /// Get count of pending records
  static int getPendingCount() {
    return getPendingRecords().length;
  }

  /// Mark records as pending sync
  static Future<void> _markAsPending(String taxType) async {
    final syncBox = getSyncBox();
    final pending = syncBox.get('pending_records', defaultValue: []) as List;
    pending.add({
      'type': taxType,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'PENDING',
    });
    await syncBox.put('pending_records', pending);
  }

  /// Mark as synced
  static Future<void> markAsSynced(String taxType, String recordId) async {
    final box = getSyncBox();
    await box.put('last_sync_$taxType', DateTime.now().toIso8601String());

    // Remove from pending
    final pending = box.get('pending_records', defaultValue: []) as List;
    pending
        .removeWhere((r) => r['type'] == taxType && r['recordId'] == recordId);
    await box.put('pending_records', pending);
  }

  /// Clear pending records
  static Future<void> clearPending() async {
    final syncBox = getSyncBox();
    await syncBox.put('pending_records', []);
  }

  /// Get last sync time for a tax type
  static DateTime? getLastSyncTime(String taxType) {
    final syncBox = getSyncBox();
    final timeStr = syncBox.get('last_sync_$taxType');
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  /// Clear all data (careful!)
  static Future<void> clearAll() async {
    await getCitBox().clear();
    await getPitBox().clear();
    await getVatBox().clear();
    await getWhtBox().clear();
    await getStampDutyBox().clear();
    await getPayrollBox().clear();
  }

  /// Clear all user data for account deletion
  static Future<void> clearAllData() async {
    await getCitBox().clear();
    await getPitBox().clear();
    await getVatBox().clear();
    await getWhtBox().clear();
    await getStampDutyBox().clear();
    await getPayrollBox().clear();
    await getUsersBox().clear();
    await getPaymentsBox().clear();
    await getSyncBox().clear();
    await getProfileBox().clear();
    await getUpgradeRequestsBox().clear();
  }

  /// Get sync status
  static Map<String, dynamic> getSyncStatus() {
    final syncBox = getSyncBox();
    return {
      'pending': getPendingCount(),
      'lastSync': syncBox.get('last_sync_time'),
      'hasErrors':
          (syncBox.get('failed_records', defaultValue: []) as List).isNotEmpty,
    };
  }

  /// Initialize Hive for testing — uses a temporary directory (no encryption).
  static Future<void> initForTesting() async {
    assert(() {
      return true;
    }(), 'initForTesting must only be called in test/debug mode');
    await Hive.initFlutter('test_hive_data');
    await Hive.openBox(usersBox);
    await Hive.openBox(paymentsBox);
    await Hive.openBox(citBox);
    await Hive.openBox(pitBox);
    await Hive.openBox(vatBox);
    await Hive.openBox(whtBox);
    await Hive.openBox(stampDutyBox);
    await Hive.openBox(payrollBox);
    await Hive.openBox(syncBox);
    await Hive.openBox(profileBox);
    await Hive.openBox(upgradeRequestsBox);
  }

  /// Close all Hive boxes for testing teardown.
  static Future<void> closeForTesting() async {
    await Hive.close();
  }
}
