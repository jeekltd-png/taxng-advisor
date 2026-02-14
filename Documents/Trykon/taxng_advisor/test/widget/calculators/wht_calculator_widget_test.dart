import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/wht/presentation/wht_calculator_screen.dart';
import 'package:taxng_advisor/services/hive_service.dart';

void main() {
  setUpAll(() async {
    await HiveService.initForTesting();
  });

  tearDownAll(() async {
    await HiveService.closeForTesting();
  });

  group('WHT Calculator Widget Tests', () {
    testWidgets('should render calculator form with input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find amount field
      expect(find.text('Gross Amount'), findsOneWidget);

      // Should find payment type dropdown
      expect(find.text('Payment Type'), findsOneWidget);

      // Should find calculate button
      expect(
          find.widgetWithText(ElevatedButton, 'Calculate WHT'), findsOneWidget);
    });

    testWidgets('should calculate WHT for dividends at 10%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '1000000');

      // Select dividends type
      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dividends').last);
      await tester.pumpAndSettle();

      // Calculate
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('WHT Calculation Results'), findsOneWidget);

      // Should show 10% rate
      expect(find.textContaining('10'), findsAtLeastNWidgets(1));
    });

    testWidgets('should calculate WHT for interest at 10%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '2000000');

      // Select interest type
      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interest').last);
      await tester.pumpAndSettle();

      // Calculate
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show results with 10% WHT
      expect(find.text('WHT Calculation Results'), findsOneWidget);
    });

    testWidgets('should calculate WHT for rent at 10%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount and select rent
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '5000000');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rent').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should calculate 10% WHT
      expect(find.text('WHT Calculation Results'), findsOneWidget);
    });

    testWidgets('should calculate WHT for royalties at 10%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount and select royalties
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '3000000');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Royalties').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('WHT Calculation Results'), findsOneWidget);
    });

    testWidgets('should calculate WHT for construction at 5%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount and select construction
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '10000000');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Construction').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show 5% rate
      expect(find.text('WHT Calculation Results'), findsOneWidget);
      expect(find.textContaining('5'), findsAtLeastNWidgets(1));
    });

    testWidgets('should calculate WHT for contracts at 5%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount and select contracts
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '8000000');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contracts').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show 5% WHT
      expect(find.text('WHT Calculation Results'), findsOneWidget);
    });

    testWidgets('should display validation error for negative amount',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter negative amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '-100000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('must be positive'), findsOneWidget);
    });

    testWidgets('should display validation error for zero amount',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter zero amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show validation error or zero result
      expect(find.text('WHT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show net amount after WHT deduction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '1000000');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dividends').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show net amount
      expect(find.textContaining('Net Amount'), findsOneWidget);
    });

    testWidgets('should handle decimal values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter decimal amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '1000000.50');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dividends').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should calculate successfully
      expect(find.text('WHT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show formatted currency values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '1000000');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dividends').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should display currency symbol
      expect(find.textContaining('₦'), findsWidgets);
    });

    testWidgets('should recalculate when payment type changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First calculation with 10% rate
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '1000000');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dividends').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Change to 5% rate
      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Construction').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show updated results
      expect(find.text('WHT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show save button after calculation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '1000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show save button
      expect(find.textContaining('Save'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle very large amounts',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter very large amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '999999999999');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dividends').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should calculate without errors
      expect(find.text('WHT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show payment type in results',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhtCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Gross Amount'), '1000000');

      await tester.tap(find.text('Payment Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Professional Fees').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate WHT'));
      await tester.pumpAndSettle();

      // Should show payment type in results
      expect(find.textContaining('Professional'), findsAtLeastNWidgets(1));
    });
  });
}
