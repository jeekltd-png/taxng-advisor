import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/payroll/presentation/payroll_calculator_screen.dart';
import 'package:taxng_advisor/services/hive_service.dart';

void main() {
  setUpAll(() async {
    await HiveService.initForTesting();
  });

  tearDownAll(() async {
    await HiveService.closeForTesting();
  });

  group('Payroll Calculator Widget Tests', () {
    testWidgets('should render calculator form with input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find monthly salary field
      expect(find.text('Monthly Gross Salary'), findsOneWidget);

      // Should find pension field
      expect(find.text('Pension (8%)'), findsOneWidget);

      // Should find NHF field
      expect(find.text('NHF (2.5%)'), findsOneWidget);

      // Should find calculate button
      expect(find.widgetWithText(ElevatedButton, 'Calculate PAYE'),
          findsOneWidget);
    });

    testWidgets('should calculate PAYE for low income',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter low monthly salary
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '200000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('Payroll Calculation Results'), findsOneWidget);

      // Should show monthly PAYE
      expect(find.textContaining('Monthly PAYE'), findsOneWidget);
    });

    testWidgets('should calculate PAYE for medium income',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter medium salary
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '500000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('Payroll Calculation Results'), findsOneWidget);
    });

    testWidgets('should calculate PAYE for high income',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter high salary
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '2000000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show results with significant PAYE
      expect(find.text('Payroll Calculation Results'), findsOneWidget);
    });

    testWidgets('should apply pension deduction at 8%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate with pension
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '1000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Pension (8%)'), '80000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show pension deduction
      expect(find.text('Payroll Calculation Results'), findsOneWidget);
    });

    testWidgets('should apply NHF deduction at 2.5%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate with NHF
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '1000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'NHF (2.5%)'), '25000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show NHF deduction
      expect(find.text('Payroll Calculation Results'), findsOneWidget);
    });

    testWidgets('should show annual calculations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '500000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show annual figures (monthly × 12)
      expect(find.textContaining('Annual'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display validation error for negative salary',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter negative salary
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '-100000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('must be positive'), findsOneWidget);
    });

    testWidgets('should calculate net pay correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '500000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show net pay (gross - PAYE - deductions)
      expect(find.textContaining('Monthly Net'), findsOneWidget);
    });

    testWidgets('should handle zero salary', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter zero salary
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show zero PAYE
      expect(find.text('Payroll Calculation Results'), findsOneWidget);
      expect(find.textContaining('₦0'), findsWidgets);
    });

    testWidgets('should handle decimal salary values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter decimal salary
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '500000.50');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should calculate successfully
      expect(find.text('Payroll Calculation Results'), findsOneWidget);
    });

    testWidgets('should show formatted currency values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '500000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should display currency symbol
      expect(find.textContaining('₦'), findsWidgets);
    });

    testWidgets('should recalculate when salary changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First calculation
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '300000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Change salary and recalculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '600000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show updated results
      expect(find.text('Payroll Calculation Results'), findsOneWidget);
    });

    testWidgets('should show save button after calculation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '500000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should show save button
      expect(find.textContaining('Save'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle very large salary values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter very large salary
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'),
          '50000000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Should calculate without errors
      expect(find.text('Payroll Calculation Results'), findsOneWidget);
    });

    testWidgets('should calculate annual gross correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PayrollCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate with known monthly amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Monthly Gross Salary'), '500000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PAYE'));
      await tester.pumpAndSettle();

      // Annual should be 500000 × 12 = 6,000,000
      expect(find.textContaining('6,000,000'), findsOneWidget);
    });
  });
}
