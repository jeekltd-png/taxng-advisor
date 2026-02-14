import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/services/validation_service.dart';

void main() {
  group('ValidationService - Rule Registration', () {
    setUp(() {
      // Clear any existing rules by registering empty lists
      ValidationService.registerRules('TEST', []);
    });

    test('should register validation rules for a calculator', () {
      final rules = [
        ValidationRule(
          fieldName: 'testField',
          severity: ValidationSeverity.error,
          validate: (data) => RuleValidationResult(isValid: true),
        ),
      ];

      ValidationService.registerRules('TEST', rules);

      final result = ValidationService.validate('TEST', {'testField': 'value'});
      expect(result.isValid, isTrue);
    });

    test('should validate with no rules registered', () {
      final result =
          ValidationService.validate('UNKNOWN', {'anyField': 'value'});
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
    });
  });

  group('ValidationService - CIT Validation Rules', () {
    setUp(() {
      ValidationService.registerRules('CIT', ValidationService.getCITRules());
    });

    test('should pass validation with valid CIT data', () {
      final result = ValidationService.validate('CIT', {
        'turnover': 50000000.0,
        'profit': 10000000.0,
      });

      expect(result.isValid, isTrue);
      expect(result.hasErrors, isFalse);
    });

    test('should fail validation with zero turnover', () {
      final result = ValidationService.validate('CIT', {
        'turnover': 0.0,
        'profit': 5000000.0,
      });

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('turnover'), isTrue);
    });

    test('should fail validation with negative turnover', () {
      final result = ValidationService.validate('CIT', {
        'turnover': -1000000.0,
        'profit': 5000000.0,
      });

      expect(result.isValid, isFalse);
    });

    test('should fail validation with zero profit', () {
      final result = ValidationService.validate('CIT', {
        'turnover': 50000000.0,
        'profit': 0.0,
      });

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('profit'), isTrue);
    });

    test('should warn when turnover exceeds 1 billion', () {
      final result = ValidationService.validate('CIT', {
        'turnover': 2000000000.0,
        'profit': 500000000.0,
      });

      expect(result.hasWarnings, isTrue);
      expect(result.warnings.containsKey('turnover'), isTrue);
    });

    test('should warn when profit exceeds turnover', () {
      final result = ValidationService.validate('CIT', {
        'turnover': 50000000.0,
        'profit': 60000000.0,
      });

      expect(result.hasWarnings, isTrue);
      expect(result.warnings.containsKey('profit'), isTrue);
    });
  });

  group('ValidationService - PIT Validation Rules', () {
    setUp(() {
      ValidationService.registerRules('PIT', ValidationService.getPITRules());
    });

    test('should pass validation with valid PIT data', () {
      final result = ValidationService.validate('PIT', {
        'grossIncome': 5000000.0,
        'reliefs': 500000.0,
      });

      expect(result.isValid, isTrue);
    });

    test('should fail validation with negative gross income', () {
      final result = ValidationService.validate('PIT', {
        'grossIncome': -1000000.0,
      });

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('grossIncome'), isTrue);
    });

    test('should warn when reliefs exceed 25% of gross income', () {
      final result = ValidationService.validate('PIT', {
        'grossIncome': 5000000.0,
        'reliefs': 2000000.0, // 40% of gross income
      });

      expect(result.hasWarnings, isTrue);
      expect(result.warnings.containsKey('reliefs'), isTrue);
    });

    test('should not warn when reliefs are within 25%', () {
      final result = ValidationService.validate('PIT', {
        'grossIncome': 5000000.0,
        'reliefs': 1000000.0, // 20% of gross income
      });

      expect(result.hasWarnings, isFalse);
    });
  });

  group('ValidationService - VAT Validation Rules', () {
    setUp(() {
      ValidationService.registerRules('VAT', ValidationService.getVATRules());
    });

    test('should pass validation with valid VAT data', () {
      final result = ValidationService.validate('VAT', {
        'standardSales': 10000000.0,
        'zeroRatedSales': 0.0,
        'exemptSales': 0.0,
        'totalInputVat': 500000.0,
        'exemptInputVat': 100000.0,
      });

      expect(result.isValid, isTrue);
    });

    test('should fail validation with negative standard sales', () {
      final result = ValidationService.validate('VAT', {
        'standardSales': -1000000.0,
      });

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('standardSales'), isTrue);
    });

    test('should fail validation with negative zero-rated sales', () {
      final result = ValidationService.validate('VAT', {
        'zeroRatedSales': -100000.0,
      });

      expect(result.isValid, isFalse);
    });

    test('should fail validation with negative exempt sales', () {
      final result = ValidationService.validate('VAT', {
        'exemptSales': -50000.0,
      });

      expect(result.isValid, isFalse);
    });

    test('should fail when exempt input VAT exceeds total input VAT', () {
      final result = ValidationService.validate('VAT', {
        'totalInputVat': 100000.0,
        'exemptInputVat': 150000.0,
      });

      expect(result.isValid, isFalse);
    });

    test('should warn when input VAT significantly exceeds output VAT', () {
      final result = ValidationService.validate('VAT', {
        'standardSales': 1000000.0, // Output VAT = 75,000
        'totalInputVat': 200000.0, // Significantly higher
      });

      expect(result.hasWarnings, isTrue);
    });
  });

  group('ValidationService - WHT Validation Rules', () {
    setUp(() {
      ValidationService.registerRules('WHT', ValidationService.getWHTRules());
    });

    test('should pass validation with valid WHT data', () {
      final result = ValidationService.validate('WHT', {
        'amount': 1000000.0,
        'type': 'dividends',
      });

      expect(result.isValid, isTrue);
    });

    test('should fail validation with zero amount', () {
      final result = ValidationService.validate('WHT', {
        'amount': 0.0,
        'type': 'dividends',
      });

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('amount'), isTrue);
    });

    test('should fail validation with negative amount', () {
      final result = ValidationService.validate('WHT', {
        'amount': -500000.0,
        'type': 'interest',
      });

      expect(result.isValid, isFalse);
    });

    test('should fail validation without payment type', () {
      final result = ValidationService.validate('WHT', {
        'amount': 1000000.0,
        'type': null,
      });

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('type'), isTrue);
    });
  });

  group('ValidationService - PAYE Validation Rules', () {
    setUp(() {
      ValidationService.registerRules('PAYE', ValidationService.getPAYERules());
    });

    test('should pass validation with valid PAYE data', () {
      final result = ValidationService.validate('PAYE', {
        'monthlyGross': 500000.0,
      });

      expect(result.isValid, isTrue);
    });

    test('should fail validation with zero monthly gross', () {
      final result = ValidationService.validate('PAYE', {
        'monthlyGross': 0.0,
      });

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('monthlyGross'), isTrue);
    });

    test('should fail validation with negative monthly gross', () {
      final result = ValidationService.validate('PAYE', {
        'monthlyGross': -100000.0,
      });

      expect(result.isValid, isFalse);
    });

    test('should warn when salary is below minimum wage', () {
      final result = ValidationService.validate('PAYE', {
        'monthlyGross': 25000.0,
      });

      expect(result.hasWarnings, isTrue);
      expect(result.warnings.containsKey('monthlyGross'), isTrue);
    });

    test('should not warn when salary is at minimum wage', () {
      final result = ValidationService.validate('PAYE', {
        'monthlyGross': 30000.0,
      });

      expect(result.hasWarnings, isFalse);
    });
  });

  group('ValidationService - Stamp Duty Validation Rules', () {
    setUp(() {
      ValidationService.registerRules(
          'STAMP', ValidationService.getStampDutyRules());
    });

    test('should pass validation with valid Stamp Duty data', () {
      final result = ValidationService.validate('STAMP', {
        'transactionAmount': 5000000.0,
      });

      expect(result.isValid, isTrue);
    });

    test('should fail validation with zero transaction amount', () {
      final result = ValidationService.validate('STAMP', {
        'transactionAmount': 0.0,
      });

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('transactionAmount'), isTrue);
    });

    test('should fail validation with negative transaction amount', () {
      final result = ValidationService.validate('STAMP', {
        'transactionAmount': -1000000.0,
      });

      expect(result.isValid, isFalse);
    });

    test('should warn when transaction exceeds 10 million', () {
      final result = ValidationService.validate('STAMP', {
        'transactionAmount': 20000000.0,
      });

      expect(result.hasWarnings, isTrue);
      expect(result.warnings.containsKey('transactionAmount'), isTrue);
    });
  });

  group('ValidationResult Model', () {
    test('should create valid result with no errors', () {
      final result = ValidationResult(
        isValid: true,
        errors: {},
        warnings: {},
      );

      expect(result.isValid, isTrue);
      expect(result.hasErrors, isFalse);
      expect(result.hasWarnings, isFalse);
    });

    test('should detect errors correctly', () {
      final result = ValidationResult(
        isValid: false,
        errors: {'field1': 'Error message'},
        warnings: {},
      );

      expect(result.isValid, isFalse);
      expect(result.hasErrors, isTrue);
      expect(result.hasWarnings, isFalse);
    });

    test('should detect warnings correctly', () {
      final result = ValidationResult(
        isValid: true,
        errors: {},
        warnings: {'field1': 'Warning message'},
      );

      expect(result.isValid, isTrue);
      expect(result.hasErrors, isFalse);
      expect(result.hasWarnings, isTrue);
    });

    test('should get error message for field', () {
      final result = ValidationResult(
        isValid: false,
        errors: {'turnover': 'Turnover is required'},
        warnings: {},
      );

      expect(
          result.getErrorMessage('turnover'), equals('Turnover is required'));
      expect(result.getErrorMessage('nonexistent'), equals(''));
    });

    test('should get warning message for field', () {
      final result = ValidationResult(
        isValid: true,
        errors: {},
        warnings: {'amount': 'Amount is unusually high'},
      );

      expect(result.getWarningMessage('amount'),
          equals('Amount is unusually high'));
      expect(result.getWarningMessage('nonexistent'), equals(''));
    });

    test('should get all errors', () {
      final result = ValidationResult(
        isValid: false,
        errors: {
          'field1': 'Error 1',
          'field2': 'Error 2',
        },
        warnings: {},
      );

      final allErrors = result.getAllErrors();
      expect(allErrors.length, equals(2));
      expect(allErrors.contains('Error 1'), isTrue);
      expect(allErrors.contains('Error 2'), isTrue);
    });

    test('should get all warnings', () {
      final result = ValidationResult(
        isValid: true,
        errors: {},
        warnings: {
          'field1': 'Warning 1',
          'field2': 'Warning 2',
          'field3': 'Warning 3',
        },
      );

      final allWarnings = result.getAllWarnings();
      expect(allWarnings.length, equals(3));
    });
  });

  group('ValidationRule Model', () {
    test('should create rule with required fields', () {
      final rule = ValidationRule(
        fieldName: 'testField',
        severity: ValidationSeverity.error,
        validate: (data) => RuleValidationResult(isValid: true),
      );

      expect(rule.fieldName, equals('testField'));
      expect(rule.severity, equals(ValidationSeverity.error));
    });

    test('should execute validation function correctly', () {
      final rule = ValidationRule(
        fieldName: 'amount',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['amount'] as double?;
          if (value == null || value <= 0) {
            return RuleValidationResult(
              isValid: false,
              message: 'Amount must be positive',
            );
          }
          return RuleValidationResult(isValid: true);
        },
      );

      final failResult = rule.validate({'amount': -100.0});
      expect(failResult.isValid, isFalse);
      expect(failResult.message, equals('Amount must be positive'));

      final passResult = rule.validate({'amount': 100.0});
      expect(passResult.isValid, isTrue);
    });
  });

  group('RuleValidationResult Model', () {
    test('should create valid result', () {
      final result = RuleValidationResult(isValid: true);
      expect(result.isValid, isTrue);
      expect(result.message, equals(''));
    });

    test('should create invalid result with message', () {
      final result = RuleValidationResult(
        isValid: false,
        message: 'Validation failed',
      );
      expect(result.isValid, isFalse);
      expect(result.message, equals('Validation failed'));
    });
  });

  group('ValidationSeverity Enum', () {
    test('should have error and warning severities', () {
      expect(ValidationSeverity.values.length, equals(2));
      expect(
          ValidationSeverity.values.contains(ValidationSeverity.error), isTrue);
      expect(ValidationSeverity.values.contains(ValidationSeverity.warning),
          isTrue);
    });
  });

  group('ValidationService - Multiple Rules Per Field', () {
    test('should evaluate all rules for a field', () {
      ValidationService.registerRules('MULTI', [
        ValidationRule(
          fieldName: 'value',
          severity: ValidationSeverity.error,
          validate: (data) {
            final value = data['value'] as double?;
            if (value == null || value <= 0) {
              return RuleValidationResult(
                isValid: false,
                message: 'Value must be positive',
              );
            }
            return RuleValidationResult(isValid: true);
          },
        ),
        ValidationRule(
          fieldName: 'value',
          severity: ValidationSeverity.warning,
          validate: (data) {
            final value = data['value'] as double?;
            if (value != null && value > 1000000) {
              return RuleValidationResult(
                isValid: false,
                message: 'Value is unusually high',
              );
            }
            return RuleValidationResult(isValid: true);
          },
        ),
      ]);

      // Test with negative value (error)
      final errorResult =
          ValidationService.validate('MULTI', {'value': -100.0});
      expect(errorResult.isValid, isFalse);
      expect(errorResult.hasErrors, isTrue);

      // Test with high value (warning only)
      final warningResult =
          ValidationService.validate('MULTI', {'value': 2000000.0});
      expect(warningResult.isValid, isTrue);
      expect(warningResult.hasWarnings, isTrue);

      // Test with normal value (no issues)
      final validResult =
          ValidationService.validate('MULTI', {'value': 50000.0});
      expect(validResult.isValid, isTrue);
      expect(validResult.hasErrors, isFalse);
      expect(validResult.hasWarnings, isFalse);
    });
  });
}
