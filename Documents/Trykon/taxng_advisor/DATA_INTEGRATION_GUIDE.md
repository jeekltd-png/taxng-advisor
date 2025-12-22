# TaxNG Advisor - Data Integration & Sync Guide

## Overview
This guide explains how data is formatted, stored locally, synced in real-time, and integrated with the TaxNG Advisor application.

---

## Part 1: Data Format Specifications

### 1.1 CIT Return Data Format

**JSON Format (for API/Database):**
```json
{
  "id": "CIT_2025_001",
  "type": "CIT",
  "businessName": "ABC Enterprises Ltd",
  "taxYear": 2025,
  "filingStatus": "SUBMITTED",
  "data": {
    "turnover": 75000000,
    "profit": 15000000,
    "deductibleExpenses": 60000000,
    "depreciation": 2500000,
    "otherDeductions": 500000
  },
  "calculation": {
    "category": "Medium",
    "rate": 0.20,
    "taxPayable": 3000000,
    "effectiveRate": 0.04,
    "penalties": 0,
    "totalLiability": 3000000
  },
  "timestamps": {
    "created": "2025-12-15T10:30:00Z",
    "modified": "2025-12-15T10:45:00Z",
    "synced": "2025-12-15T11:00:00Z"
  },
  "status": "SAVED"
}
```

**Dart Model (In-App):**
```dart
class CitReturn {
  final String id;
  final String businessName;
  final int taxYear;
  final double turnover;
  final double profit;
  final CitResult calculationResult;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final SyncStatus syncStatus;

  CitReturn({
    required this.id,
    required this.businessName,
    required this.taxYear,
    required this.turnover,
    required this.profit,
    required this.calculationResult,
    required this.createdAt,
    required this.modifiedAt,
    required this.syncStatus,
  });

  // Serialize to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'businessName': businessName,
    'taxYear': taxYear,
    'turnover': turnover,
    'profit': profit,
    'calculation': calculationResult.toMap(),
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'syncStatus': syncStatus.toString(),
  };

  // Deserialize from JSON
  factory CitReturn.fromJson(Map<String, dynamic> json) => CitReturn(
    id: json['id'] as String,
    businessName: json['businessName'] as String,
    taxYear: json['taxYear'] as int,
    turnover: json['turnover'] as double,
    profit: json['profit'] as double,
    calculationResult: CitResult.fromMap(json['calculation']),
    createdAt: DateTime.parse(json['createdAt'] as String),
    modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    syncStatus: SyncStatus.values.byName(json['syncStatus']),
  );
}

enum SyncStatus {
  LOCAL,           // Only on device
  PENDING,         // Waiting to sync
  SYNCED,          // Synchronized
  CONFLICT,        // Has conflicts with server
  FAILED,          // Sync failed
}
```

### 1.2 All Tax Types - Data Formats

**PIT Return Format:**
```json
{
  "type": "PIT",
  "taxpayerName": "John Doe",
  "taxYear": 2025,
  "data": {
    "grossIncome": 5000000,
    "otherDeductions": [200000, 150000],
    "annualRentPaid": 1200000,
    "totalDeductions": 350000,
    "chargeableIncome": 4650000
  },
  "calculation": {
    "totalTax": 825000,
    "rentRelief": 240000,
    "effectiveRate": 0.165,
    "breakdown": {
      "band_0_to_300k": 0,
      "band_300k_to_600k": 45000,
      "band_600k_to_1m": 120000,
      "band_1m_to_1_5m": 150000,
      "band_1_5m_to_3m": 360000,
      "band_above_3m": 150000
    }
  }
}
```

**VAT Return Format:**
```json
{
  "type": "VAT",
  "businessName": "Tech Solutions Ltd",
  "period": "2025_Q1",
  "data": {
    "supplies": [
      {
        "description": "Software Development",
        "amount": 5000000,
        "type": "STANDARD"
      },
      {
        "description": "Exported Services",
        "amount": 2000000,
        "type": "ZERO_RATED"
      },
      {
        "description": "Financial Services",
        "amount": 1000000,
        "type": "EXEMPT"
      }
    ],
    "totalSales": 8000000,
    "totalInputVat": 850000,
    "exemptInputVat": 0
  },
  "calculation": {
    "outputVat": 525000,
    "recoverableInput": 525000,
    "netPayable": 0,
    "refundEligible": 0
  }
}
```

**WHT Return Format:**
```json
{
  "type": "WHT",
  "payerName": "ABC Limited",
  "period": "2025_DECEMBER",
  "records": [
    {
      "payeeName": "John Smith Consulting",
      "amount": 1000000,
      "paymentType": "PROFESSIONAL_FEES",
      "rate": 0.10,
      "whtCalculated": 100000,
      "netAmount": 900000,
      "dateOfPayment": "2025-12-10",
      "referenceNumber": "WHT_001"
    },
    {
      "payeeName": "Property Owner Ltd",
      "amount": 500000,
      "paymentType": "RENT",
      "rate": 0.10,
      "whtCalculated": 50000,
      "netAmount": 450000,
      "dateOfPayment": "2025-12-05",
      "referenceNumber": "WHT_002"
    }
  ],
  "totalWht": 150000
}
```

---

## Part 2: Local Storage Structure (Hive)

### 2.1 Hive Box Structure

**Folder Location:** `documents/Hive/` (Android), `Library/Hive/` (iOS), Local app data (Web)

```
Hive Database Structure:
├── cit_estimates/
│   ├── [0] → {turnover, profit, category, rate, taxPayable, calculatedAt}
│   ├── [1] → {...}
│   └── [2] → {...}
├── pit_estimates/
│   ├── [0] → {grossIncome, chargeableIncome, totalTax, rentRelief, breakdown}
│   └── [1] → {...}
├── vat_returns/
│   ├── [0] → {vatableSales, zeroRatedSales, outputVat, recoverableInput}
│   └── [1] → {...}
├── wht_records/
│   ├── [0] → {amount, type, rate, wht, netAmount}
│   └── [1] → {...}
├── stamp_duty_records/
│   ├── [0] → {amount, type, duty, netAmount}
│   └── [1] → {...}
└── sync_status/
    └── metadata → {lastSync, pendingUploads, conflicts}
```

### 2.2 Hive Box Initialization Code

```dart
// lib/services/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String citBox = 'cit_estimates';
  static const String pitBox = 'pit_estimates';
  static const String vatBox = 'vat_returns';
  static const String whtBox = 'wht_records';
  static const String stampDutyBox = 'stamp_duty_records';
  static const String syncBox = 'sync_status';

  /// Initialize Hive and open all boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Open all boxes
    await Hive.openBox(citBox);
    await Hive.openBox(pitBox);
    await Hive.openBox(vatBox);
    await Hive.openBox(whtBox);
    await Hive.openBox(stampDutyBox);
    await Hive.openBox(syncBox);
  }

  /// Add a CIT calculation
  static Future<void> saveCIT(CitResult result) async {
    final box = Hive.box(citBox);
    await box.add(result.toMap());
    await _markAsPending('CIT');
  }

  /// Add a PIT calculation
  static Future<void> savePIT(PitResult result) async {
    final box = Hive.box(pitBox);
    await box.add(result.toMap());
    await _markAsPending('PIT');
  }

  /// Get all pending records for sync
  static List<Map<String, dynamic>> getPendingRecords() {
    final syncBox = Hive.box(syncBox);
    final pending = syncBox.get('pending_records', defaultValue: []) as List;
    return pending.cast<Map<String, dynamic>>();
  }

  /// Mark records as pending sync
  static Future<void> _markAsPending(String taxType) async {
    final box = Hive.box(syncBox);
    final pending = box.get('pending_records', defaultValue: []) as List;
    pending.add({
      'type': taxType,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'PENDING',
    });
    await box.put('pending_records', pending);
  }

  /// Mark as synced
  static Future<void> markAsSynced(String taxType, String recordId) async {
    final box = Hive.box(syncBox);
    await box.put('last_sync_$taxType', DateTime.now().toIso8601String());
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await Hive.box(citBox).clear();
    await Hive.box(pitBox).clear();
    await Hive.box(vatBox).clear();
    await Hive.box(whtBox).clear();
    await Hive.box(stampDutyBox).clear();
  }
}
```

---

## Part 3: Offline & Real-Time Sync Architecture

### 3.1 Sync Strategy (Offline-First)

```
┌──────────────────────────────────────────────────────────┐
│           TaxNG Advisor Sync Architecture                │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  LOCAL (Device - Always Available)                  │ │
│  │  ├─ Hive Database                                   │ │
│  │  ├─ Pending Records Queue                           │ │
│  │  └─ Sync Status Tracker                             │ │
│  └─────────────────────────────────────────────────────┘ │
│                      ↕ (Sync)                            │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  REMOTE (Server - When Connected)                   │ │
│  │  ├─ Backend API                                     │ │
│  │  ├─ Database (Firebase, PostgreSQL, etc.)           │ │
│  │  └─ Cloud Storage                                   │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  Sync Flow:                                              │
│  1. User enters data → Saved to LOCAL Hive              │
│  2. Mark as "PENDING"                                   │
│  3. When online → Sync with REMOTE                      │
│  4. Receive confirmation → Mark as "SYNCED"            │
│  5. If conflict → Flag for manual resolution            │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

### 3.2 Real-Time Sync Service

```dart
// lib/services/sync_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SyncService {
  static final _connectivity = Connectivity();
  static const String _baseUrl = 'https://api.taxng-advisor.com';

  /// Initialize sync listener
  static void initializeSyncListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.wifi || 
          result == ConnectivityResult.mobile) {
        // Device is online
        _performSync();
      }
    });
  }

  /// Check if device is online
  static Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Perform sync operation
  static Future<void> _performSync() async {
    try {
      print('🔄 Starting sync...');
      
      // Get pending records from Hive
      final pending = HiveService.getPendingRecords();
      
      if (pending.isEmpty) {
        print('✅ No pending records to sync');
        return;
      }

      // Upload each pending record
      for (var record in pending) {
        await _uploadRecord(record);
      }

      print('✅ Sync completed successfully');
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }

  /// Upload individual record
  static Future<void> _uploadRecord(Map<String, dynamic> record) async {
    final taxType = record['type'] as String;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/tax-returns/$taxType'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode(record),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Upload timeout'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mark as synced
        final recordId = record['id'] ?? record['timestamp'];
        await HiveService.markAsSynced(taxType, recordId);
        print('✅ Synced $taxType record');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Failed to sync record: $e');
      await _markAsFailed(record);
    }
  }

  /// Get authentication token
  static Future<String> _getAuthToken() async {
    // Implementation depends on your auth method
    // Could be stored in secure storage
    return 'your_auth_token_here';
  }

  /// Mark record as failed
  static Future<void> _markAsFailed(Map<String, dynamic> record) async {
    final box = Hive.box('sync_status');
    final failed = box.get('failed_records', defaultValue: []) as List;
    failed.add({
      ...record,
      'failedAt': DateTime.now().toIso8601String(),
      'retryCount': (record['retryCount'] ?? 0) + 1,
    });
    await box.put('failed_records', failed);
  }

  /// Pull remote data (for syncing from server to device)
  static Future<void> pullRemoteData() async {
    if (!await isOnline()) {
      print('📴 Offline - cannot pull remote data');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tax-returns'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        
        // Merge with local data
        for (var record in data) {
          await _mergeRecord(record);
        }
        
        print('✅ Pulled ${data.length} records from server');
      }
    } catch (e) {
      print('❌ Failed to pull remote data: $e');
    }
  }

  /// Merge remote record with local data
  static Future<void> _mergeRecord(Map<String, dynamic> remoteRecord) async {
    final type = remoteRecord['type'] as String;
    final box = Hive.box('${type.toLowerCase()}_estimates');
    
    // Check if local record exists
    final localRecords = box.values.cast<Map<String, dynamic>>().toList();
    final existingIndex = localRecords.indexWhere(
      (r) => r['id'] == remoteRecord['id'],
    );

    if (existingIndex >= 0) {
      // Compare timestamps - keep newer version
      final local = localRecords[existingIndex];
      final localTime = DateTime.parse(local['modifiedAt'] as String);
      final remoteTime = DateTime.parse(remoteRecord['modifiedAt'] as String);
      
      if (remoteTime.isAfter(localTime)) {
        await box.putAt(existingIndex, remoteRecord);
        print('📝 Updated $type record with remote version');
      }
    } else {
      // New record - add it
      await box.add(remoteRecord);
      print('➕ Added new $type record from server');
    }
  }
}
```

---

## Part 4: Implementation Steps

### Step 1: Add Connectivity Plugin

**pubspec.yaml:**
```yaml
dependencies:
  connectivity_plus: ^5.0.0
  http: ^1.1.0
```

**Install:**
```bash
flutter pub get
```

### Step 2: Initialize Sync Service in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.initialize();

  // Initialize sync service
  SyncService.initializeSyncListener();

  // Listen for initial connection status
  if (await SyncService.isOnline()) {
    await SyncService.pullRemoteData();
  }

  runApp(const TaxNgApp());
}
```

### Step 3: Update Calculator Screens to Use Sync

```dart
// lib/features/cit/presentation/cit_calculator_screen.dart

void _calculateCIT() {
  if (_formKey.currentState!.validate()) {
    final turnover = double.parse(_turnoverController.text);
    final profit = double.parse(_profitController.text);

    final result = CitCalculator.calculate(
      turnover: turnover,
      profit: profit,
    );

    // 1. Save to local Hive
    HiveService.saveCIT(result);

    // 2. Show sync status
    _showSyncStatus();

    // 3. Try to sync if online
    if (await SyncService.isOnline()) {
      SyncService._performSync();
    }

    setState(() => _showResults = true);
  }
}

void _showSyncStatus() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: FutureBuilder<bool>(
        future: SyncService.isOnline(),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return const Text('✅ Saved and syncing to server...');
          } else {
            return const Text('💾 Saved offline - will sync when online');
          }
        },
      ),
    ),
  );
}
```

### Step 4: Create Sync Status UI Widget

```dart
// lib/widgets/sync_status_indicator.dart

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  late StreamSubscription _connectivitySubscription;
  bool _isOnline = false;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeStatus();
    _listenToConnectivity();
  }

  void _initializeStatus() async {
    final isOnline = await SyncService.isOnline();
    final pending = HiveService.getPendingRecords().length;
    
    setState(() {
      _isOnline = isOnline;
      _pendingCount = pending;
    });
  }

  void _listenToConnectivity() {
    _connectivitySubscription = 
      Connectivity().onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      
      setState(() {
        _isOnline = isOnline;
      });

      if (isOnline) {
        // Trigger sync when coming online
        SyncService._performSync();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green[50] : Colors.orange[50],
        border: Border.all(
          color: _isOnline ? Colors.green : Colors.orange,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: _isOnline ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _isOnline
                ? 'Online - Syncing'
                : 'Offline - ${ _pendingCount} pending',
            style: TextStyle(
              fontSize: 12,
              color: _isOnline ? Colors.green[700] : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 5: Add to Dashboard

```dart
// lib/features/dashboard/presentation/dashboard_screen.dart

Column(
  children: [
    // Add sync status at top
    const SyncStatusIndicator(),
    const SizedBox(height: 16),
    
    // Rest of dashboard...
  ],
)
```

---

## Part 5: Backend API Specification

### 5.1 REST API Endpoints

**POST /api/tax-returns/CIT**
```
Request:
{
  "businessName": "ABC Enterprises",
  "taxYear": 2025,
  "turnover": 75000000,
  "profit": 15000000,
  "calculation": {...}
}

Response (201):
{
  "id": "CIT_2025_001",
  "status": "RECEIVED",
  "message": "CIT return filed successfully",
  "timestamp": "2025-12-15T11:00:00Z"
}
```

**GET /api/tax-returns**
```
Request: GET with Bearer token

Response (200):
[
  {
    "id": "CIT_2025_001",
    "type": "CIT",
    "businessName": "ABC Enterprises",
    "taxYear": 2025,
    "status": "FILED",
    "modifiedAt": "2025-12-15T11:00:00Z"
  },
  {...}
]
```

**PUT /api/tax-returns/{id}**
```
Request: Update existing return with new calculation

Response (200): Updated record
```

### 5.2 Backend Authentication

```dart
// Token-based auth (JWT)
Future<String> _getAuthToken() async {
  final storage = FlutterSecureStorage();
  var token = await storage.read(key: 'auth_token');
  
  if (token == null || _isTokenExpired(token)) {
    token = await _refreshAuthToken();
    await storage.write(key: 'auth_token', value: token);
  }
  
  return token;
}

bool _isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(parts[1]))
    );
    final exp = payload['exp'] as int;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
      .isBefore(DateTime.now());
  } catch (e) {
    return true;
  }
}
```

---

## Part 6: Conflict Resolution Strategy

### 6.1 Handle Sync Conflicts

```dart
class ConflictResolver {
  /// Resolve conflicts when timestamps differ
  static Future<Map<String, dynamic>> resolve({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  }) async {
    final localTime = DateTime.parse(local['modifiedAt'] as String);
    final remoteTime = DateTime.parse(remote['modifiedAt'] as String);
    
    // Latest timestamp wins
    if (remoteTime.isAfter(localTime)) {
      return remote; // Use remote version
    } else {
      return local; // Keep local version
    }
  }

  /// Manual conflict resolution UI
  static Future<Map<String, dynamic>?> showConflictDialog({
    required BuildContext context,
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  }) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Conflict Detected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Local version differs from server.'),
            const Text('Choose which version to keep:'),
            const SizedBox(height: 16),
            Text('Local: ${local['modifiedAt']}'),
            Text('Remote: ${remote['modifiedAt']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, local),
            child: const Text('Use Local'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, remote),
            child: const Text('Use Remote'),
          ),
        ],
      ),
    );
  }
}
```

---

## Part 7: Data Privacy & Security

### 7.1 Encryption for Storage

```dart
// lib/services/encryption_service.dart

import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final _key = encrypt.Key.fromLength(32);
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  /// Encrypt sensitive data before storage
  static String encryptData(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt data from storage
  static String decryptData(String encryptedData) {
    final decrypted = _encrypter.decrypt64(encryptedData, iv: _iv);
    return decrypted;
  }

  /// Store encrypted token
  static Future<void> storeEncryptedToken(String token) async {
    final storage = FlutterSecureStorage();
    final encrypted = encryptData(token);
    await storage.write(key: 'auth_token_encrypted', value: encrypted);
  }

  /// Retrieve encrypted token
  static Future<String?> getEncryptedToken() async {
    final storage = FlutterSecureStorage();
    final encrypted = await storage.read(key: 'auth_token_encrypted');
    return encrypted != null ? decryptData(encrypted) : null;
  }
}
```

---

## Summary Table

| Component | Purpose | Storage | Sync |
|-----------|---------|---------|------|
| **Hive Boxes** | Local persistence | Device | Manual trigger |
| **Sync Service** | Real-time sync | Server | Auto on connectivity |
| **Encryption** | Data security | Secure storage | Encrypted in transit |
| **Conflict Resolution** | Handle duplicates | Manual/Automatic | Latest wins |
| **Connectivity Monitor** | Connection status | In-memory | Continuous |

---

## Quick Reference: Implementation Checklist

- [ ] Add connectivity_plus & http packages
- [ ] Create HiveService for local storage
- [ ] Create SyncService for remote sync
- [ ] Initialize sync listener in main.dart
- [ ] Add SyncStatusIndicator widget to dashboard
- [ ] Implement API endpoints on backend
- [ ] Add encryption for sensitive data
- [ ] Test offline → online sync flow
- [ ] Implement conflict resolution UI
- [ ] Add error handling & retry logic
- [ ] Test on multiple devices
- [ ] Monitor sync performance

---

## Example: Complete User Journey

```
1️⃣  USER OPENS APP (Offline)
    └─ App loads from Hive
    └─ Shows offline indicator

2️⃣  USER ENTERS CIT DATA
    └─ Enters turnover & profit
    └─ Clicks Calculate
    └─ Result saved to local Hive
    └─ Status: "SAVED (Offline)"

3️⃣  DEVICE GOES ONLINE
    └─ SyncService detects connectivity
    └─ Retrieves pending records
    └─ Uploads to server via API
    └─ Server validates & stores
    └─ Status: "SYNCED ✓"

4️⃣  USER NAVIGATES DASHBOARD
    └─ SyncStatusIndicator shows ✓
    └─ Calculation appears in history
    └─ Full offline-to-cloud journey complete

5️⃣  USER OPENS APP ON DIFFERENT DEVICE
    └─ Pulls remote data via API
    └─ Shows all calculations
    └─ Syncs local changes back
    └─ Data stays consistent across devices
```

This architecture ensures robust offline functionality with automatic sync when connectivity is restored!