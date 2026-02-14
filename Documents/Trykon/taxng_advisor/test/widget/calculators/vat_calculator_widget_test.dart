import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/vat/presentation/vat_calculator_screen.dart';
import 'package:taxng_advisor/services/hive_service.dart';

void main() {
  setUpAll(() async {
    await HiveService.initForTesting();
  });

  tearDownAll(() async {
    await HiveService.closeForTesting();
  });

  group('VAT Calculator Widget Tests', () {
    testWidgets('should render calculator form with all input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find vateable sales field
      expect(find.text('Vatable Sales'), findsOneWidget);

      // Should find zero-rated sales field
      expect(find.text('Zero-Rated Sales'), findsOneWidget);

      // Should find exempt sales field
      expect(find.text('Exempt Sales'), findsOneWidget);

      // Should find input VAT field
      expect(find.text('Input VAT'), findsOneWidget);

      // Should find calculate button
      expect(
          find.widgetWithText(ElevatedButton, 'Calculate VAT'), findsOneWidget);
    });

    testWidgets('should calculate VAT for standard supplies',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter standard vatable sales
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '10000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Zero-Rated Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exempt Sales'), '0');
      await tester.enterText(find.widgetWithText(TextField, 'Input VAT'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('VAT Calculation Results'), findsOneWidget);

      // Should show 7.5% output VAT
      expect(find.textContaining('750,000'), findsOneWidget);
    });

    testWidgets('should calculate VAT with zero-rated supplies',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter zero-rated sales
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Zero-Rated Sales'), '5000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exempt Sales'), '0');
      await tester.enterText(find.widgetWithText(TextField, 'Input VAT'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show zero output VAT
      expect(find.text('VAT Calculation Results'), findsOneWidget);
      expect(find.textContaining('₦0'), findsWidgets);
    });

    testWidgets('should calculate VAT with exempt supplies',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter exempt sales
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Zero-Rated Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exempt Sales'), '3000000');
      await tester.enterText(find.widgetWithText(TextField, 'Input VAT'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('VAT Calculation Results'), findsOneWidget);
    });

    testWidgets('should handle input VAT deduction correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter sales with input VAT
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '10000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Zero-Rated Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exempt Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Input VAT'), '500000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show net VAT payable
      expect(find.text('VAT Calculation Results'), findsOneWidget);
      expect(find.textContaining('Net VAT'), findsOneWidget);
    });

    testWidgets('should show refund when input VAT exceeds output VAT',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter scenario where input > output
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '1000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Zero-Rated Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exempt Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Input VAT'), '200000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show refund eligible
      expect(find.text('VAT Calculation Results'), findsOneWidget);
      expect(find.textContaining('Refund'), findsOneWidget);
    });

    testWidgets('should display validation error for negative values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter negative vatable sales
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '-1000000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('must be positive'), findsOneWidget);
    });

    testWidgets('should calculate VAT for mixed supply types',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter mixed supplies
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '5000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Zero-Rated Sales'), '3000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exempt Sales'), '2000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Input VAT'), '250000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show combined results
      expect(find.text('VAT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show output VAT at 7.5% rate',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '10000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show 7.5% rate
      expect(find.textContaining('7.5'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle zero values in all fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter all zeros
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Zero-Rated Sales'), '0');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exempt Sales'), '0');
      await tester.enterText(find.widgetWithText(TextField, 'Input VAT'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show zero results
      expect(find.text('VAT Calculation Results'), findsOneWidget);
    });

    testWidgets('should handle decimal values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter decimal values
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '10000000.50');
      await tester.enterText(
          find.widgetWithText(TextField, 'Input VAT'), '250000.25');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should calculate successfully
      expect(find.text('VAT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show formatted currency values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '10000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should display currency symbol
      expect(find.textContaining('₦'), findsWidgets);
    });

    testWidgets('should recalculate when values change',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First calculation
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '5000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Change values and recalculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '10000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show updated results
      expect(find.text('VAT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show save button after calculation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '10000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should show save button
      expect(find.textContaining('Save'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle very large values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VatCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter very large values
      await tester.enterText(
          find.widgetWithText(TextField, 'Vatable Sales'), '999999999999');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate VAT'));
      await tester.pumpAndSettle();

      // Should calculate without errors
      expect(find.text('VAT Calculation Results'), findsOneWidget);
    });
  });
}
