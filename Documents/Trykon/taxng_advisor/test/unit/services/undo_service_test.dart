import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/services/undo_service.dart';

/// Unit tests for UndoService models and enums
/// Note: Service-level integration tests that require Hive initialization
/// are tested separately in integration tests where the Flutter binding
/// and path_provider are available.

void main() {
  group('UndoOperation Model', () {
    test('should create UndoOperation with required fields', () {
      final operation = UndoOperation(
        id: 'test_op_1',
        type: UndoOperationType.delete,
        timestamp: DateTime(2026, 1, 15, 10, 30),
        data: {'key': 'value'},
        description: 'Test delete operation',
      );

      expect(operation.id, equals('test_op_1'));
      expect(operation.type, equals(UndoOperationType.delete));
      expect(operation.description, equals('Test delete operation'));
      expect(operation.timestamp, equals(DateTime(2026, 1, 15, 10, 30)));
      expect(operation.data['key'], equals('value'));
    });

    test('should convert to map correctly', () {
      final operation = UndoOperation(
        id: 'map_test',
        type: UndoOperationType.batchOperation,
        timestamp: DateTime(2026, 2, 1),
        data: {'count': 5, 'items': []},
        description: 'Batch operation',
      );

      final map = operation.toMap();

      expect(map['id'], equals('map_test'));
      expect(map['type'], equals('UndoOperationType.batchOperation'));
      expect(map['description'], equals('Batch operation'));
      expect(map.containsKey('timestamp'), isTrue);
      expect(map.containsKey('data'), isTrue);
    });

    test('should create from map correctly', () {
      final map = {
        'id': 'from_map_test',
        'type': 'UndoOperationType.delete',
        'timestamp': '2026-01-20T14:00:00.000',
        'data': {'taxType': 'CIT', 'key': '123'},
        'description': 'Deleted CIT calculation',
      };

      final operation = UndoOperation.fromMap(map);

      expect(operation.id, equals('from_map_test'));
      expect(operation.type, equals(UndoOperationType.delete));
      expect(operation.data['taxType'], equals('CIT'));
      expect(operation.description, equals('Deleted CIT calculation'));
    });

    test('should handle roundtrip serialization', () {
      final original = UndoOperation(
        id: 'roundtrip_test',
        type: UndoOperationType.edit,
        timestamp: DateTime(2026, 3, 15, 14, 30, 45),
        data: {
          'taxType': 'VAT',
          'oldValue': 100.0,
          'newValue': 200.0,
        },
        description: 'Edited VAT calculation',
      );

      final map = original.toMap();
      final restored = UndoOperation.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.type, equals(original.type));
      expect(restored.description, equals(original.description));
      expect(restored.data['taxType'], equals(original.data['taxType']));
      expect(restored.data['oldValue'], equals(original.data['oldValue']));
      expect(restored.data['newValue'], equals(original.data['newValue']));
    });

    test('should handle complex nested data', () {
      final operation = UndoOperation(
        id: 'complex_data_test',
        type: UndoOperationType.batchOperation,
        timestamp: DateTime.now(),
        data: {
          'calculations': [
            {'id': '1', 'type': 'CIT', 'amount': 100000},
            {'id': '2', 'type': 'PIT', 'amount': 50000},
          ],
          'count': 2,
          'metadata': {
            'user': 'test_user',
            'timestamp': DateTime.now().toIso8601String(),
          }
        },
        description: 'Batch delete',
      );

      final map = operation.toMap();
      final restored = UndoOperation.fromMap(map);

      expect(restored.data['count'], equals(2));
      expect((restored.data['calculations'] as List).length, equals(2));
    });
  });

  group('UndoOperationType Enum', () {
    test('should have all expected types', () {
      expect(UndoOperationType.values.length, equals(3));
      expect(
          UndoOperationType.values.contains(UndoOperationType.delete), isTrue);
      expect(
          UndoOperationType.values.contains(UndoOperationType.batchOperation),
          isTrue);
      expect(UndoOperationType.values.contains(UndoOperationType.edit), isTrue);
    });

    test('should convert to string correctly', () {
      expect(UndoOperationType.delete.toString(), contains('delete'));
      expect(UndoOperationType.batchOperation.toString(),
          contains('batchOperation'));
      expect(UndoOperationType.edit.toString(), contains('edit'));
    });

    test('should parse from string correctly', () {
      const deleteStr = 'UndoOperationType.delete';
      const batchStr = 'UndoOperationType.batchOperation';
      const editStr = 'UndoOperationType.edit';

      expect(
        UndoOperationType.values.firstWhere((e) => e.toString() == deleteStr),
        equals(UndoOperationType.delete),
      );
      expect(
        UndoOperationType.values.firstWhere((e) => e.toString() == batchStr),
        equals(UndoOperationType.batchOperation),
      );
      expect(
        UndoOperationType.values.firstWhere((e) => e.toString() == editStr),
        equals(UndoOperationType.edit),
      );
    });
  });

  group('UndoOperation Data Validation', () {
    test('should handle empty data map', () {
      final operation = UndoOperation(
        id: 'empty_data',
        type: UndoOperationType.delete,
        timestamp: DateTime.now(),
        data: {},
        description: 'Empty data test',
      );

      expect(operation.data.isEmpty, isTrue);
      expect(operation.toMap()['data'], equals({}));
    });

    test('should preserve data types in map conversion', () {
      final operation = UndoOperation(
        id: 'type_test',
        type: UndoOperationType.edit,
        timestamp: DateTime.now(),
        data: {
          'stringValue': 'test',
          'intValue': 42,
          'doubleValue': 3.14,
          'boolValue': true,
          'listValue': [1, 2, 3],
        },
        description: 'Type preservation test',
      );

      final map = operation.toMap();
      expect(map['data']['stringValue'], isA<String>());
      expect(map['data']['intValue'], isA<int>());
      expect(map['data']['doubleValue'], isA<double>());
      expect(map['data']['boolValue'], isA<bool>());
      expect(map['data']['listValue'], isA<List>());
    });

    test('should handle null-safe access patterns', () {
      final operation = UndoOperation(
        id: 'null_safe',
        type: UndoOperationType.delete,
        timestamp: DateTime.now(),
        data: {'key1': 'value1'},
        description: 'Null safe test',
      );

      expect(operation.data['nonexistent'], isNull);
      expect(operation.data['key1'], equals('value1'));
    });
  });

  group('UndoOperation Timestamp Handling', () {
    test('should serialize timestamp to ISO8601 format', () {
      final timestamp = DateTime(2026, 6, 15, 10, 30, 45);
      final operation = UndoOperation(
        id: 'timestamp_test',
        type: UndoOperationType.delete,
        timestamp: timestamp,
        data: {},
        description: 'Timestamp test',
      );

      final map = operation.toMap();
      expect(map['timestamp'], equals('2026-06-15T10:30:45.000'));
    });

    test('should parse timestamp from ISO8601 format', () {
      final map = {
        'id': 'parse_timestamp',
        'type': 'UndoOperationType.delete',
        'timestamp': '2026-12-25T15:45:30.000',
        'data': {},
        'description': 'Parse test',
      };

      final operation = UndoOperation.fromMap(map);
      expect(operation.timestamp.year, equals(2026));
      expect(operation.timestamp.month, equals(12));
      expect(operation.timestamp.day, equals(25));
      expect(operation.timestamp.hour, equals(15));
      expect(operation.timestamp.minute, equals(45));
      expect(operation.timestamp.second, equals(30));
    });
  });
}
