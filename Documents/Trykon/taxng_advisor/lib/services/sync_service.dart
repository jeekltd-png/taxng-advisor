import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'hive_service.dart';

class SyncService {
  static final _connectivity = Connectivity();
  static const String _baseUrl = 'https://api.taxng-advisor.com';
  static const String _authTokenKey = 'auth_token';
  static bool _isSyncing = false;

  /// Stream of connectivity changes
  static Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }

  /// Initialize sync listener
  static void initializeSyncListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      if (isOnline && !_isSyncing) {
        print('🟢 Device is online - Starting sync...');
        performSync();
      } else if (!isOnline) {
        print('🔴 Device is offline - Sync paused');
      }
    });
  }

  /// Check if device is online
  static Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Get online status as stream
  static Future<ConnectivityResult> getConnectivityStatus() async {
    return await _connectivity.checkConnectivity();
  }

  /// Perform sync operation
  static Future<void> performSync() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    try {
      _isSyncing = true;
      print('🔄 Starting sync...');

      // Get pending records from Hive
      final pending = HiveService.getPendingRecords();

      if (pending.isEmpty) {
        print('✅ No pending records to sync');
        _isSyncing = false;
        return;
      }

      print('📤 Uploading ${pending.length} pending records...');

      // Upload each pending record
      int successCount = 0;
      for (var record in pending) {
        final success = await _uploadRecord(record);
        if (success) successCount++;
      }

      print('✅ Sync completed: $successCount/${pending.length} records synced');
      _isSyncing = false;
    } catch (e) {
      print('❌ Sync failed: $e');
      _isSyncing = false;
    }
  }

  /// Upload individual record to server
  static Future<bool> _uploadRecord(Map<String, dynamic> record) async {
    final taxType = record['type'] as String;

    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('⚠️  No auth token available, cannot upload $taxType');
        return false;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/tax-returns/$taxType'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'type': taxType,
              'data': record,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Upload timeout for $taxType'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Synced $taxType record');
        await HiveService.markAsSynced(taxType, record['id'] ?? 'unknown');
        return true;
      } else {
        print(
            '⚠️  Server error for $taxType: ${response.statusCode} - ${response.body}');
        await _markAsFailed(record, 'HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Failed to sync $taxType record: $e');
      await _markAsFailed(record, e.toString());
      return false;
    }
  }

  /// Mark record as failed sync
  static Future<void> _markAsFailed(
      Map<String, dynamic> record, String error) async {
    final syncBox = HiveService.getSyncBox();
    final failed = syncBox.get('failed_records', defaultValue: []) as List;
    failed.add({
      ...record,
      'failedAt': DateTime.now().toIso8601String(),
      'error': error,
      'retryCount': (record['retryCount'] ?? 0) + 1,
    });
    await syncBox.put('failed_records', failed);
  }

  /// Pull remote data from server
  static Future<void> pullRemoteData() async {
    if (!await isOnline()) {
      print('📴 Offline - cannot pull remote data');
      return;
    }

    try {
      print('📥 Pulling data from server...');

      final token = await _getAuthToken();
      if (token == null) {
        print('⚠️  No auth token available for pulling data');
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/tax-returns'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        int mergedCount = 0;
        for (var record in data) {
          await _mergeRecord(record);
          mergedCount++;
        }

        print('✅ Pulled and merged $mergedCount records from server');
      } else {
        print(
            '⚠️  Failed to pull remote data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Failed to pull remote data: $e');
    }
  }

  /// Merge remote record with local data
  static Future<void> _mergeRecord(Map<String, dynamic> remoteRecord) async {
    try {
      final type = remoteRecord['type'] as String?;
      if (type == null) {
        print('⚠️  Remote record has no type field');
        return;
      }

      final boxName = _getBoxNameForType(type);
      if (boxName == null) {
        print('⚠️  Unknown tax type: $type');
        return;
      }

      // use HiveService accessors instead of direct Hive.box lookup
      dynamic box;
      switch (boxName) {
        case 'cit_estimates':
          box = HiveService.getCitBox();
          break;
        case 'pit_estimates':
          box = HiveService.getPitBox();
          break;
        case 'vat_returns':
          box = HiveService.getVatBox();
          break;
        case 'wht_records':
          box = HiveService.getWhtBox();
          break;
        case 'stamp_duty_records':
          box = HiveService.getStampDutyBox();
          break;
        case 'payroll_records':
          box = HiveService.getPayrollBox();
          break;
        default:
          print('⚠️  Unknown box name: $boxName');
          return;
      }

      final localRecords = box.values.cast<Map<String, dynamic>>().toList();

      final recordId = remoteRecord['id'] ?? remoteRecord['timestamp'];
      final existingIndex = localRecords
          .indexWhere((r) => (r['id'] ?? r['timestamp']) == recordId);

      if (existingIndex >= 0) {
        // Update existing
        final local = localRecords[existingIndex];
        final localTime =
            _parseDateTime(local['modifiedAt'] ?? local['timestamp']);
        final remoteTime = _parseDateTime(
            remoteRecord['modifiedAt'] ?? remoteRecord['timestamp']);

        if (remoteTime.isAfter(localTime)) {
          await box.putAt(existingIndex, remoteRecord);
          print('📝 Updated $type record from server');
        }
      } else {
        // Add new
        await box.add(remoteRecord);
        print('➕ Added new $type record from server');
      }
    } catch (e) {
      print('❌ Failed to merge record: $e');
    }
  }

  /// Parse datetime safely
  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Get box name for tax type
  static String? _getBoxNameForType(String type) {
    switch (type.toUpperCase()) {
      case 'CIT':
        return 'cit_estimates';
      case 'PIT':
        return 'pit_estimates';
      case 'VAT':
        return 'vat_returns';
      case 'WHT':
        return 'wht_records';
      case 'STAMP_DUTY':
        return 'stamp_duty_records';
      case 'PAYROLL':
        return 'payroll_records';
      default:
        return null;
    }
  }

  /// Get or refresh auth token
  static Future<String?> _getAuthToken() async {
    final storage = FlutterSecureStorage();

    try {
      var token = await storage.read(key: _authTokenKey);

      if (token == null || _isTokenExpired(token)) {
        print('🔑 Token expired or missing, refreshing...');
        token = await _refreshAuthToken();
        if (token != null) {
          await storage.write(key: _authTokenKey, value: token);
        }
      }

      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  /// Check if token is expired
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(
        utf8.decode(
            base64Url.decode(parts[1] + '=' * (4 - parts[1].length % 4))),
      );
      final exp = payload['exp'] as int?;

      if (exp == null) return true;

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          .isBefore(DateTime.now());
    } catch (e) {
      return true;
    }
  }

  /// Refresh auth token from server
  static Future<String?> _refreshAuthToken() async {
    try {
      // This is a placeholder - implement based on your auth service
      // For now, return null to indicate no token available
      print('⚠️  Token refresh not implemented');
      return null;
    } catch (e) {
      print('❌ Failed to refresh token: $e');
      return null;
    }
  }

  /// Force manual sync
  static Future<void> manualSync() async {
    print('🔄 Manual sync triggered');
    await performSync();
  }

  /// Get sync status
  static Map<String, dynamic> getSyncStatus() {
    return HiveService.getSyncStatus();
  }

  /// Clear all pending records
  static Future<void> clearPending() async {
    await HiveService.clearPending();
    print('🗑️  Cleared all pending records');
  }

  /// Get failed records
  static List<Map<String, dynamic>> getFailedRecords() {
    final syncBox = HiveService.getSyncBox();
    final failed = syncBox.get('failed_records', defaultValue: []) as List;
    return failed.cast<Map<String, dynamic>>();
  }
}
