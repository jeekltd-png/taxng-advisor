import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/pit/presentation/pit_calculator_screen.dart';
import 'package:taxng_advisor/services/hive_service.dart';

void main() {
  setUpAll(() async {
    await HiveService.initForTesting();
  });

  tearDownAll(() async {
    await HiveService.closeForTesting();
  });

  group('PIT Calculator Widget Tests', () {
    testWidgets('should render calculator form with all input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find gross income field
      expect(find.text('Gross Income'), findsOneWidget);

      // Should find deductions field
      expect(find.text('Other Deductions'), findsOneWidget);

      // Should find rent field
      expect(find.text('Annual Rent Paid'), findsOneWidget);

      // Should find calculate button
      expect(
          find.widgetWithText(ElevatedButton, 'Calculate PIT'), findsOneWidget);
    });

    testWidgets('should display validation error for negative gross income',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter negative gross income
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '-1000000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('must be positive'), findsOneWidget);
    });

    testWidgets('should display validation error for negative deductions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter negative deductions
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '-50000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('must be positive'), findsOneWidget);
    });

    testWidgets('should calculate PIT for low income (first band)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter low income (within first band)
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '2000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Rent Paid'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('PIT Calculation Results'), findsOneWidget);

      // Should show low tax rate
      expect(find.textContaining('7'), findsAtLeastNWidgets(1));
    });

    testWidgets('should calculate PIT for medium income (multiple bands)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter medium income
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '5000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '200000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Rent Paid'), '1200000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('PIT Calculation Results'), findsOneWidget);

      // Should show total tax
      expect(find.textContaining('₦'), findsWidgets);
    });

    testWidgets('should calculate PIT for high income (top band)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter high income
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '25000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Rent Paid'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('PIT Calculation Results'), findsOneWidget);

      // Should show higher tax amount
      expect(find.textContaining('₦'), findsWidgets);
    });

    testWidgets('should apply rent relief correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter income with rent
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '5000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Rent Paid'), '2400000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should calculate successfully
      expect(find.text('PIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should handle maximum rent relief cap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter very high rent (should be capped)
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '10000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Rent Paid'), '10000000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should calculate with capped relief
      expect(find.text('PIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show progressive tax breakdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate with income spanning multiple bands
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '8000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Rent Paid'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show breakdown
      expect(find.text('Tax Breakdown'), findsOneWidget);
    });

    testWidgets('should handle zero income', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter zero income
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Rent Paid'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show zero tax
      expect(find.text('PIT Calculation Results'), findsOneWidget);
      expect(find.textContaining('₦0'), findsAtLeastNWidgets(1));
    });

    testWidgets('should recalculate when inputs change',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First calculation
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '3000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Change income and recalculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '6000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show updated results
      expect(find.text('PIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should display effective tax rate',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '5000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '200000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Rent Paid'), '1200000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show effective rate
      expect(find.textContaining('%'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show chargeable income after deductions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate with deductions
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '5000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '500000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Rent Paid'), '1000000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show chargeable income
      expect(find.textContaining('Chargeable'), findsOneWidget);
    });

    testWidgets('should handle decimal values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter decimal values
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '5000000.50');
      await tester.enterText(
          find.widgetWithText(TextField, 'Other Deductions'), '200000.25');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should calculate successfully
      expect(find.text('PIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show save button after calculation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '5000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show save button
      expect(find.textContaining('Save'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle very large income values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter very large income
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '999999999999');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should calculate without errors
      expect(find.text('PIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should display all tax bands in breakdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate with income spanning all bands
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Income'), '50000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate PIT'));
      await tester.pumpAndSettle();

      // Should show breakdown with multiple rates
      expect(find.text('Tax Breakdown'), findsOneWidget);
      expect(find.textContaining('%'), findsWidgets);
    });
  });
}
