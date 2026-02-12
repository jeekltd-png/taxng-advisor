import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:taxng_advisor/services/tax_analytics_service.dart';
import 'package:taxng_advisor/services/hive_service.dart';

/// Types of operations that can be undone
enum UndoOperationType {
  delete,
  batchOperation,
  edit,
}

/// Model for an undoable operation
class UndoOperation {
  final String id;
  final UndoOperationType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final String description;

  UndoOperation({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.data,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'description': description,
    };
  }

  factory UndoOperation.fromMap(Map<String, dynamic> map) {
    return UndoOperation(
      id: map['id'],
      type: UndoOperationType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      timestamp: DateTime.parse(map['timestamp']),
      data: Map<String, dynamic>.from(map['data']),
      description: map['description'],
    );
  }
}

/// Service for managing undo operations
class UndoService {
  static const String _undoBoxName = 'undo_history';
  static const int _maxHistorySize = 50; // Keep last 50 operations
  static const Duration _maxAge = Duration(hours: 24); // Keep for 24 hours

  /// Record a delete operation
  static Future<String> recordDelete({
    required TaxCalculationItem calculation,
  }) async {
    final operationId = DateTime.now().millisecondsSinceEpoch.toString();

    // Get the full calculation data from Hive
    final parts = calculation.id.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid calculation ID format');
    }

    final taxType = parts[0];
    final key = parts[1];

    Box box;
    switch (taxType) {
      case 'CIT':
        box = Hive.box(HiveService.citBox);
        break;
      case 'PIT':
        box = Hive.box(HiveService.pitBox);
        break;
      case 'VAT':
        box = Hive.box(HiveService.vatBox);
        break;
      case 'WHT':
        box = Hive.box(HiveService.whtBox);
        break;
      case 'PAYE':
        box = Hive.box(HiveService.payrollBox);
        break;
      case 'STAMP':
        box = Hive.box(HiveService.stampDutyBox);
        break;
      default:
        throw Exception('Unknown tax type: $taxType');
    }

    final calculationData = box.get(key);
    if (calculationData == null) {
      throw Exception('Calculation not found');
    }

    final operation = UndoOperation(
      id: operationId,
      type: UndoOperationType.delete,
      timestamp: DateTime.now(),
      data: {
        'calculationId': calculation.id,
        'taxType': taxType,
        'key': key,
        'data': Map<String, dynamic>.from(calculationData),
      },
      description: 'Deleted ${calculation.type} calculation',
    );

    await _saveOperation(operation);
    return operationId;
  }

  /// Record multiple delete operations
  static Future<String> recordBulkDelete({
    required List<TaxCalculationItem> calculations,
  }) async {
    final operationId = DateTime.now().millisecondsSinceEpoch.toString();
    final deletedItems = <Map<String, dynamic>>[];

    for (final calc in calculations) {
      final parts = calc.id.split(':');
      if (parts.length != 2) continue;

      final taxType = parts[0];
      final key = parts[1];

      Box box;
      switch (taxType) {
        case 'CIT':
          box = Hive.box(HiveService.citBox);
          break;
        case 'PIT':
          box = Hive.box(HiveService.pitBox);
          break;
        case 'VAT':
          box = Hive.box(HiveService.vatBox);
          break;
        case 'WHT':
          box = Hive.box(HiveService.whtBox);
          break;
        case 'PAYE':
          box = Hive.box(HiveService.payrollBox);
          break;
        case 'STAMP':
          box = Hive.box(HiveService.stampDutyBox);
          break;
        default:
          continue;
      }

      final calculationData = box.get(key);
      if (calculationData != null) {
        deletedItems.add({
          'calculationId': calc.id,
          'taxType': taxType,
          'key': key,
          'data': Map<String, dynamic>.from(calculationData),
        });
      }
    }

    final operation = UndoOperation(
      id: operationId,
      type: UndoOperationType.delete,
      timestamp: DateTime.now(),
      data: {
        'items': deletedItems,
        'count': deletedItems.length,
      },
      description:
          'Deleted ${deletedItems.length} calculation${deletedItems.length != 1 ? 's' : ''}',
    );

    await _saveOperation(operation);
    return operationId;
  }

  /// Record a batch operation
  static Future<String> recordBatchOperation({
    required List<TaxCalculationItem> calculations,
    required String operationName,
    required Map<String, dynamic> parameters,
  }) async {
    final operationId = DateTime.now().millisecondsSinceEpoch.toString();
    final originalValues = <Map<String, dynamic>>[];

    for (final calc in calculations) {
      final parts = calc.id.split(':');
      if (parts.length != 2) continue;

      final taxType = parts[0];
      final key = parts[1];

      Box box;
      String amountKey;

      switch (taxType) {
        case 'CIT':
          box = Hive.box(HiveService.citBox);
          amountKey = 'taxPayable';
          break;
        case 'PIT':
          box = Hive.box(HiveService.pitBox);
          amountKey = 'totalTax';
          break;
        case 'VAT':
          box = Hive.box(HiveService.vatBox);
          amountKey = 'netPayable';
          break;
        case 'WHT':
          box = Hive.box(HiveService.whtBox);
          amountKey = 'wht';
          break;
        case 'PAYE':
          box = Hive.box(HiveService.payrollBox);
          amountKey = 'monthlyPaye';
          break;
        case 'STAMP':
          box = Hive.box(HiveService.stampDutyBox);
          amountKey = 'duty';
          break;
        default:
          continue;
      }

      final calculationData = box.get(key);
      if (calculationData != null) {
        final data = Map<String, dynamic>.from(calculationData);
        originalValues.add({
          'calculationId': calc.id,
          'taxType': taxType,
          'key': key,
          'amountKey': amountKey,
          'originalAmount': data[amountKey],
        });
      }
    }

    final operation = UndoOperation(
      id: operationId,
      type: UndoOperationType.batchOperation,
      timestamp: DateTime.now(),
      data: {
        'items': originalValues,
        'operationName': operationName,
        'parameters': parameters,
        'count': originalValues.length,
      },
      description:
          '$operationName on ${originalValues.length} calculation${originalValues.length != 1 ? 's' : ''}',
    );

    await _saveOperation(operation);
    return operationId;
  }

  /// Undo an operation by ID
  static Future<bool> undo(String operationId) async {
    try {
      final box = await Hive.openBox(_undoBoxName);
      final operationMap = box.get(operationId);

      if (operationMap == null) {
        return false;
      }

      final operation =
          UndoOperation.fromMap(Map<String, dynamic>.from(operationMap));

      switch (operation.type) {
        case UndoOperationType.delete:
          await _undoDelete(operation);
          break;
        case UndoOperationType.batchOperation:
          await _undoBatchOperation(operation);
          break;
        case UndoOperationType.edit:
          await _undoEdit(operation);
          break;
      }

      // Remove the operation from history after successful undo
      await box.delete(operationId);
      return true;
    } catch (e) {
      debugPrint('Error undoing operation: $e');
      return false;
    }
  }

  /// Undo a delete operation
  static Future<void> _undoDelete(UndoOperation operation) async {
    final items = operation.data['items'];

    if (items != null) {
      // Bulk delete undo
      for (final item in items) {
        await _restoreCalculation(
          item['taxType'],
          item['key'],
          item['data'],
        );
      }
    } else {
      // Single delete undo
      await _restoreCalculation(
        operation.data['taxType'],
        operation.data['key'],
        operation.data['data'],
      );
    }
  }

  /// Restore a calculation to Hive
  static Future<void> _restoreCalculation(
    String taxType,
    String key,
    Map<String, dynamic> data,
  ) async {
    Box box;
    switch (taxType) {
      case 'CIT':
        box = Hive.box(HiveService.citBox);
        break;
      case 'PIT':
        box = Hive.box(HiveService.pitBox);
        break;
      case 'VAT':
        box = Hive.box(HiveService.vatBox);
        break;
      case 'WHT':
        box = Hive.box(HiveService.whtBox);
        break;
      case 'PAYE':
        box = Hive.box(HiveService.payrollBox);
        break;
      case 'STAMP':
        box = Hive.box(HiveService.stampDutyBox);
        break;
      default:
        throw Exception('Unknown tax type: $taxType');
    }

    await box.put(key, data);
  }

  /// Undo a batch operation
  static Future<void> _undoBatchOperation(UndoOperation operation) async {
    final items = operation.data['items'] as List;

    for (final item in items) {
      final taxType = item['taxType'];
      final key = item['key'];
      final amountKey = item['amountKey'];
      final originalAmount = item['originalAmount'];

      Box box;
      switch (taxType) {
        case 'CIT':
          box = Hive.box(HiveService.citBox);
          break;
        case 'PIT':
          box = Hive.box(HiveService.pitBox);
          break;
        case 'VAT':
          box = Hive.box(HiveService.vatBox);
          break;
        case 'WHT':
          box = Hive.box(HiveService.whtBox);
          break;
        case 'PAYE':
          box = Hive.box(HiveService.payrollBox);
          break;
        case 'STAMP':
          box = Hive.box(HiveService.stampDutyBox);
          break;
        default:
          continue;
      }

      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data);
        map[amountKey] = originalAmount;
        await box.put(key, map);
      }
    }
  }

  /// Undo an edit operation
  static Future<void> _undoEdit(UndoOperation operation) async {
    // Implementation for edit undo
    // Similar to delete restore
  }

  /// Save operation to history
  static Future<void> _saveOperation(UndoOperation operation) async {
    final box = await Hive.openBox(_undoBoxName);
    await box.put(operation.id, operation.toMap());
    await _cleanupHistory();
  }

  /// Get recent operations
  static Future<List<UndoOperation>> getRecentOperations(
      {int limit = 10}) async {
    try {
      final box = await Hive.openBox(_undoBoxName);
      final operations = <UndoOperation>[];

      for (final value in box.values) {
        try {
          operations
              .add(UndoOperation.fromMap(Map<String, dynamic>.from(value)));
        } catch (e) {
          debugPrint('Error parsing operation: $e');
        }
      }

      operations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return operations.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting recent operations: $e');
      return [];
    }
  }

  /// Check if an operation can be undone
  static Future<bool> canUndo(String operationId) async {
    try {
      final box = await Hive.openBox(_undoBoxName);
      return box.containsKey(operationId);
    } catch (e) {
      return false;
    }
  }

  /// Clean up old operations
  static Future<void> _cleanupHistory() async {
    try {
      final box = await Hive.openBox(_undoBoxName);
      final operations = <UndoOperation>[];

      for (final value in box.values) {
        try {
          operations
              .add(UndoOperation.fromMap(Map<String, dynamic>.from(value)));
        } catch (e) {
          debugPrint('Error parsing operation: $e');
        }
      }

      // Remove old operations
      final now = DateTime.now();
      for (final op in operations) {
        if (now.difference(op.timestamp) > _maxAge) {
          await box.delete(op.id);
        }
      }

      // Keep only last N operations
      if (box.length > _maxHistorySize) {
        operations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final toRemove = operations.skip(_maxHistorySize);
        for (final op in toRemove) {
          await box.delete(op.id);
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up history: $e');
    }
  }

  /// Clear all undo history
  static Future<void> clearHistory() async {
    try {
      final box = await Hive.openBox(_undoBoxName);
      await box.clear();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}
