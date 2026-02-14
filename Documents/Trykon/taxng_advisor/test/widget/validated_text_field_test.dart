import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/widgets/validated_text_field.dart';
import 'package:taxng_advisor/services/validation_service.dart';

void main() {
  setUp(() {
    // Register test validation rules
    ValidationService.registerRules('TEST', [
      ValidationRule(
        fieldName: 'testField',
        severity: ValidationSeverity.error,
        validate: (data) {
          final value = data['testField'] as double?;
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
        fieldName: 'testField',
        severity: ValidationSeverity.warning,
        validate: (data) {
          final value = data['testField'] as double?;
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
  });

  group('ValidatedTextField Widget', () {
    testWidgets('should render with label', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Test Amount',
              fieldName: 'testField',
              calculatorKey: 'TEST',
              getFormData: () =>
                  {'testField': double.tryParse(controller.text)},
            ),
          ),
        ),
      );

      expect(find.text('Test Amount'), findsOneWidget);
    });

    testWidgets('should render with prefix text', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Amount',
              fieldName: 'testField',
              calculatorKey: 'TEST',
              getFormData: () =>
                  {'testField': double.tryParse(controller.text)},
              prefixText: '₦',
            ),
          ),
        ),
      );

      expect(find.text('₦'), findsOneWidget);
    });

    testWidgets('should render with hint text', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Amount',
              fieldName: 'testField',
              calculatorKey: 'TEST',
              getFormData: () =>
                  {'testField': double.tryParse(controller.text)},
              hintText: 'Enter amount',
            ),
          ),
        ),
      );

      expect(find.text('Enter amount'), findsOneWidget);
    });

    testWidgets('should accept keyboard type', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Amount',
              fieldName: 'testField',
              calculatorKey: 'TEST',
              getFormData: () =>
                  {'testField': double.tryParse(controller.text)},
              keyboardType: TextInputType.number,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, equals(TextInputType.number));
    });

    testWidgets('should allow text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Amount',
              fieldName: 'testField',
              calculatorKey: 'TEST',
              getFormData: () =>
                  {'testField': double.tryParse(controller.text)},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '1000');
      expect(controller.text, equals('1000'));
    });

    testWidgets('should be disabled when enabled is false',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Amount',
              fieldName: 'testField',
              calculatorKey: 'TEST',
              getFormData: () =>
                  {'testField': double.tryParse(controller.text)},
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('should support multiple lines', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              controller: controller,
              label: 'Description',
              fieldName: 'testField',
              calculatorKey: 'TEST',
              getFormData: () => {'testField': controller.text},
              maxLines: 3,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, equals(3));
    });
  });

  group('ValidationSummary Widget', () {
    testWidgets('should display errors with red styling',
        (WidgetTester tester) async {
      final result = ValidationResult(
        isValid: false,
        errors: {'field1': 'Error message 1'},
        warnings: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationSummary(
              result: result,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Error message 1'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should display warnings with orange styling',
        (WidgetTester tester) async {
      final result = ValidationResult(
        isValid: true,
        errors: {},
        warnings: {'field1': 'Warning message 1'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationSummary(
              result: result,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Warning message 1'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should display multiple errors', (WidgetTester tester) async {
      final result = ValidationResult(
        isValid: false,
        errors: {
          'field1': 'Error 1',
          'field2': 'Error 2',
          'field3': 'Error 3',
        },
        warnings: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationSummary(
              result: result,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Error 1'), findsOneWidget);
      expect(find.text('Error 2'), findsOneWidget);
      expect(find.text('Error 3'), findsOneWidget);
    });

    testWidgets('should call onDismiss when close button is pressed',
        (WidgetTester tester) async {
      bool dismissed = false;
      final result = ValidationResult(
        isValid: false,
        errors: {'field1': 'Error'},
        warnings: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationSummary(
              result: result,
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });
  });

  group('ValidationIndicator Widget', () {
    testWidgets('should show green check for valid state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationIndicator(
              isValid: true,
              hasWarnings: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show orange warning for warning state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationIndicator(
              isValid: true,
              hasWarnings: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should show red error for invalid state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationIndicator(
              isValid: false,
              hasWarnings: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should display message when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidationIndicator(
              isValid: true,
              hasWarnings: false,
              message: 'Form is valid',
            ),
          ),
        ),
      );

      expect(find.text('Form is valid'), findsOneWidget);
    });
  });
}
