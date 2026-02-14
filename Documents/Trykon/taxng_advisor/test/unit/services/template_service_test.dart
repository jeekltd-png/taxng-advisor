import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/models/calculation_template.dart';

/// Unit tests for CalculationTemplate model.
/// Note: Service-level integration tests that require Hive initialization
/// are tested separately in integration tests where the Flutter binding
/// and path_provider are available.

void main() {
  group('CalculationTemplate Model - Creation', () {
    test('should create template with required fields', () {
      final template = CalculationTemplate(
        id: 'model_test',
        name: 'Test Template',
        taxType: 'CIT',
        templateData: {'turnover': 1000000.0},
        category: 'Monthly',
        createdAt: DateTime(2026, 1, 15),
      );

      expect(template.id, equals('model_test'));
      expect(template.name, equals('Test Template'));
      expect(template.taxType, equals('CIT'));
      expect(template.category, equals('Monthly'));
      expect(template.usageCount, equals(0));
      expect(template.lastUsedAt, isNull);
    });

    test('should create template with all fields', () {
      final now = DateTime.now();
      final template = CalculationTemplate(
        id: 'full_test',
        name: 'Full Template',
        taxType: 'VAT',
        templateData: {'outputVat': 500000.0, 'inputVat': 300000.0},
        category: 'Quarterly',
        description: 'Full description',
        createdAt: now,
        lastUsedAt: now,
        usageCount: 10,
      );

      expect(template.description, equals('Full description'));
      expect(template.usageCount, equals(10));
      expect(template.lastUsedAt, equals(now));
    });

    test('should handle empty template data', () {
      final template = CalculationTemplate(
        id: 'empty_data',
        name: 'Empty Data Template',
        taxType: 'WHT',
        templateData: {},
        category: 'Custom',
        createdAt: DateTime.now(),
      );

      expect(template.templateData, isEmpty);
    });
  });

  group('CalculationTemplate Model - toMap()', () {
    test('should convert to map correctly', () {
      final template = CalculationTemplate(
        id: 'map_test',
        name: 'Map Test',
        taxType: 'VAT',
        templateData: {'outputVat': 50000.0},
        category: 'Quarterly',
        description: 'Test description',
        createdAt: DateTime(2026, 2, 1),
        usageCount: 5,
      );

      final map = template.toMap();

      expect(map['id'], equals('map_test'));
      expect(map['name'], equals('Map Test'));
      expect(map['taxType'], equals('VAT'));
      expect(map['templateData']['outputVat'], equals(50000.0));
      expect(map['category'], equals('Quarterly'));
      expect(map['description'], equals('Test description'));
      expect(map['usageCount'], equals(5));
    });

    test('should serialize dates to ISO8601', () {
      final dateTime = DateTime(2026, 6, 15, 10, 30, 45);
      final template = CalculationTemplate(
        id: 'date_test',
        name: 'Date Test',
        taxType: 'CIT',
        templateData: {},
        category: 'Monthly',
        createdAt: dateTime,
      );

      final map = template.toMap();
      expect(map['createdAt'], equals('2026-06-15T10:30:45.000'));
    });

    test('should handle null lastUsedAt', () {
      final template = CalculationTemplate(
        id: 'null_date',
        name: 'Null Date Test',
        taxType: 'PIT',
        templateData: {},
        category: 'Annual',
        createdAt: DateTime.now(),
      );

      final map = template.toMap();
      expect(map['lastUsedAt'], isNull);
    });
  });

  group('CalculationTemplate Model - fromMap()', () {
    test('should create from map correctly', () {
      final map = {
        'id': 'from_map',
        'name': 'From Map Test',
        'taxType': 'WHT',
        'templateData': {'amount': 1000000.0},
        'category': 'Custom',
        'description': 'Created from map',
        'createdAt': '2026-01-20T10:30:00.000',
        'lastUsedAt': '2026-02-01T15:00:00.000',
        'usageCount': 10,
      };

      final template = CalculationTemplate.fromMap(map);

      expect(template.id, equals('from_map'));
      expect(template.name, equals('From Map Test'));
      expect(template.taxType, equals('WHT'));
      expect(template.usageCount, equals(10));
      expect(template.lastUsedAt, isNotNull);
    });

    test('should parse dates correctly', () {
      final map = {
        'id': 'parse_date',
        'name': 'Parse Date',
        'taxType': 'CIT',
        'templateData': {},
        'category': 'Monthly',
        'createdAt': '2026-12-25T15:45:30.000',
        'usageCount': 0,
      };

      final template = CalculationTemplate.fromMap(map);
      expect(template.createdAt.year, equals(2026));
      expect(template.createdAt.month, equals(12));
      expect(template.createdAt.day, equals(25));
    });

    test('should handle missing optional fields', () {
      final map = {
        'id': 'minimal',
        'name': 'Minimal',
        'taxType': 'VAT',
        'templateData': {},
        'category': 'Other',
        'createdAt': '2026-01-01T00:00:00.000',
      };

      final template = CalculationTemplate.fromMap(map);
      expect(template.description, isNull);
      expect(template.lastUsedAt, isNull);
      expect(template.usageCount, equals(0));
    });
  });

  group('CalculationTemplate Model - copyWith()', () {
    test('should copy with modifications', () {
      final original = CalculationTemplate(
        id: 'copy_test',
        name: 'Original',
        taxType: 'PIT',
        templateData: {},
        category: 'Annual',
        createdAt: DateTime.now(),
        usageCount: 3,
      );

      final modified = original.copyWith(
        name: 'Modified',
        usageCount: 10,
      );

      expect(modified.name, equals('Modified'));
      expect(modified.usageCount, equals(10));
      expect(modified.id, equals(original.id)); // Unchanged
      expect(modified.taxType, equals(original.taxType)); // Unchanged
    });

    test('should copy without modifications', () {
      final original = CalculationTemplate(
        id: 'copy_no_change',
        name: 'Original',
        taxType: 'CIT',
        templateData: {'turnover': 50000000.0},
        category: 'Monthly',
        description: 'Original description',
        createdAt: DateTime(2026, 1, 1),
        usageCount: 5,
      );

      final copy = original.copyWith();

      expect(copy.id, equals(original.id));
      expect(copy.name, equals(original.name));
      expect(copy.taxType, equals(original.taxType));
      expect(copy.category, equals(original.category));
      expect(copy.description, equals(original.description));
      expect(copy.usageCount, equals(original.usageCount));
    });

    test('should update lastUsedAt independently', () {
      final original = CalculationTemplate(
        id: 'last_used_test',
        name: 'Test',
        taxType: 'VAT',
        templateData: {},
        category: 'Quarterly',
        createdAt: DateTime(2026, 1, 1),
        lastUsedAt: DateTime(2026, 1, 15),
      );

      final newLastUsed = DateTime(2026, 2, 1);
      final modified = original.copyWith(lastUsedAt: newLastUsed);

      expect(modified.lastUsedAt, equals(newLastUsed));
      expect(original.lastUsedAt, equals(DateTime(2026, 1, 15)));
    });
  });

  group('CalculationTemplate Model - Roundtrip Serialization', () {
    test('should preserve all data through serialization', () {
      final original = CalculationTemplate(
        id: 'roundtrip_test',
        name: 'Roundtrip Test',
        taxType: 'PAYE',
        templateData: {
          'grossSalary': 500000.0,
          'pension': 8.0,
          'nhf': 2.5,
        },
        category: 'Payroll',
        description: 'Monthly payroll template',
        createdAt: DateTime(2026, 3, 15, 10, 30, 45),
        lastUsedAt: DateTime(2026, 4, 1, 14, 0, 0),
        usageCount: 25,
      );

      final map = original.toMap();
      final restored = CalculationTemplate.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.taxType, equals(original.taxType));
      expect(restored.category, equals(original.category));
      expect(restored.description, equals(original.description));
      expect(restored.usageCount, equals(original.usageCount));
      expect(restored.templateData['grossSalary'],
          equals(original.templateData['grossSalary']));
      expect(restored.templateData['pension'],
          equals(original.templateData['pension']));
    });

    test('should handle complex template data', () {
      final original = CalculationTemplate(
        id: 'complex_data',
        name: 'Complex Data',
        taxType: 'CIT',
        templateData: {
          'turnover': 100000000.0,
          'profit': 20000000.0,
          'allowances': [1000000.0, 500000.0],
          'metadata': {
            'year': 2026,
            'quarter': 'Q1',
          }
        },
        category: 'Annual',
        createdAt: DateTime.now(),
      );

      final map = original.toMap();
      final restored = CalculationTemplate.fromMap(map);

      expect(restored.templateData['turnover'], equals(100000000.0));
      expect(restored.templateData['profit'], equals(20000000.0));
    });
  });

  group('CalculationTemplate Model - Tax Types', () {
    final taxTypes = ['CIT', 'PIT', 'VAT', 'WHT', 'PAYE', 'STAMP'];

    for (final taxType in taxTypes) {
      test('should handle $taxType tax type', () {
        final template = CalculationTemplate(
          id: 'tax_type_${taxType.toLowerCase()}',
          name: '$taxType Template',
          taxType: taxType,
          templateData: {},
          category: 'Standard',
          createdAt: DateTime.now(),
        );

        expect(template.taxType, equals(taxType));

        final map = template.toMap();
        final restored = CalculationTemplate.fromMap(map);
        expect(restored.taxType, equals(taxType));
      });
    }
  });

  group('CalculationTemplate Model - Categories', () {
    final categories = [
      'Monthly',
      'Quarterly',
      'Annual',
      'Custom',
      'Payroll',
      'Other'
    ];

    for (final category in categories) {
      test('should handle $category category', () {
        final template = CalculationTemplate(
          id: 'category_${category.toLowerCase()}',
          name: '$category Template',
          taxType: 'CIT',
          templateData: {},
          category: category,
          createdAt: DateTime.now(),
        );

        expect(template.category, equals(category));

        final map = template.toMap();
        final restored = CalculationTemplate.fromMap(map);
        expect(restored.category, equals(category));
      });
    }
  });
}

