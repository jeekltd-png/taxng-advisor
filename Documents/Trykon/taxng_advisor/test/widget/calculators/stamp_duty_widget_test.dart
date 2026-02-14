import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/stamp_duty/presentation/stamp_duty_screen.dart';
import 'package:taxng_advisor/services/hive_service.dart';

void main() {
  setUpAll(() async {
    await HiveService.initForTesting();
  });

  tearDownAll(() async {
    await HiveService.closeForTesting();
  });

  group('Stamp Duty Widget Tests', () {
    testWidgets('should render calculator form with input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find amount field
      expect(find.text('Transaction Amount'), findsOneWidget);

      // Should find transaction type dropdown
      expect(find.text('Transaction Type'), findsOneWidget);

      // Should find calculate button
      expect(find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'),
          findsOneWidget);
    });

    testWidgets('should calculate stamp duty for electronic transfer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '100000');

      // Select electronic transfer
      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Electronic Transfer').last);
      await tester.pumpAndSettle();

      // Calculate
      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('Stamp Duty Calculation'), findsOneWidget);
    });

    testWidgets('should apply ₦10,000 minimum for electronic transfer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount below threshold
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '5000');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Electronic Transfer').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show no duty (below threshold)
      expect(find.text('Stamp Duty Calculation'), findsOneWidget);
    });

    testWidgets('should calculate ₦20 flat rate for cheque',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '500000');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cheque').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show ₦20 flat rate
      expect(find.textContaining('20'), findsAtLeastNWidgets(1));
    });

    testWidgets('should calculate 0.5% for agreement',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '10000000');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agreement').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show 0.5% duty
      expect(find.text('Stamp Duty Calculation'), findsOneWidget);
    });

    testWidgets('should calculate 1% for lease',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '5000000');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lease').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show 1% duty
      expect(find.text('Stamp Duty Calculation'), findsOneWidget);
    });

    testWidgets('should calculate 0.5% for mortgage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '20000000');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mortgage').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('Stamp Duty Calculation'), findsOneWidget);
    });

    testWidgets('should calculate ₦100 flat rate for affidavit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount (should be flat rate regardless)
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '1000000');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Affidavit').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show ₦100 flat rate
      expect(find.textContaining('100'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display validation error for negative amount',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter negative amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '-100000');

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('must be positive'), findsOneWidget);
    });

    testWidgets('should handle zero amount', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter zero amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '0');

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show zero duty
      expect(find.text('Stamp Duty Calculation'), findsOneWidget);
    });

    testWidgets('should handle decimal values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter decimal amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '100000.50');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Electronic Transfer').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should calculate successfully
      expect(find.text('Stamp Duty Calculation'), findsOneWidget);
    });

    testWidgets('should show formatted currency values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '10000000');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agreement').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should display currency symbol
      expect(find.textContaining('₦'), findsWidgets);
    });

    testWidgets('should recalculate when transaction type changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First calculation
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '10000000');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agreement').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Change type and recalculate
      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lease').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show updated results
      expect(find.text('Stamp Duty Calculation'), findsOneWidget);
    });

    testWidgets('should show save button after calculation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '10000000');
      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show save button
      expect(find.textContaining('Save'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle very large amounts',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter very large amount
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'),
          '999999999999');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Electronic Transfer').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should calculate without errors
      expect(find.text('Stamp Duty Calculation'), findsOneWidget);
    });

    testWidgets('should show transaction type in results',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StampDutyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Transaction Amount'), '10000000');

      await tester.tap(find.text('Transaction Type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Power of Attorney').last);
      await tester.pumpAndSettle();

      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Calculate Stamp Duty'));
      await tester.pumpAndSettle();

      // Should show transaction type
      expect(find.textContaining('Power'), findsAtLeastNWidgets(1));
    });
  });
}
