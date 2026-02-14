import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/cit/presentation/cit_calculator_screen.dart';
import 'package:taxng_advisor/services/hive_service.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await HiveService.initForTesting();
  });

  tearDownAll(() async {
    await HiveService.closeForTesting();
  });

  group('CIT Calculator Widget Tests', () {
    testWidgets('should render calculator form with input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Should find turnover field
      expect(find.text('Annual Turnover'), findsOneWidget);

      // Should find profit field
      expect(find.text('Taxable Profit'), findsOneWidget);

      // Should find calculate button
      expect(
          find.widgetWithText(ElevatedButton, 'Calculate CIT'), findsOneWidget);
    });

    testWidgets('should display validation error for negative turnover',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and enter negative turnover
      final turnoverField = find.widgetWithText(TextField, 'Annual Turnover');
      await tester.enterText(turnoverField, '-1000000');

      // Trigger validation by tapping calculate
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('must be positive'), findsOneWidget);
    });

    testWidgets('should display validation error for negative profit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and enter negative profit
      final profitField = find.widgetWithText(TextField, 'Taxable Profit');
      await tester.enterText(profitField, '-500000');

      // Trigger validation
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('must be positive'), findsOneWidget);
    });

    testWidgets('should display validation error when profit exceeds turnover',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter turnover
      final turnoverField = find.widgetWithText(TextField, 'Annual Turnover');
      await tester.enterText(turnoverField, '10000000');

      // Enter profit greater than turnover
      final profitField = find.widgetWithText(TextField, 'Taxable Profit');
      await tester.enterText(profitField, '20000000');

      // Trigger validation
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('cannot exceed turnover'), findsOneWidget);
    });

    testWidgets('should calculate and display results for small company',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter small company data (< 25M)
      final turnoverField = find.widgetWithText(TextField, 'Annual Turnover');
      await tester.enterText(turnoverField, '20000000');

      final profitField = find.widgetWithText(TextField, 'Taxable Profit');
      await tester.enterText(profitField, '5000000');

      // Calculate
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('CIT Calculation Results'), findsOneWidget);

      // Should show exempt status
      expect(find.textContaining('Exempt'), findsOneWidget);
    });

    testWidgets('should calculate and display results for medium company',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter medium company data (25M - 100M)
      final turnoverField = find.widgetWithText(TextField, 'Annual Turnover');
      await tester.enterText(turnoverField, '50000000');

      final profitField = find.widgetWithText(TextField, 'Taxable Profit');
      await tester.enterText(profitField, '10000000');

      // Calculate
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('CIT Calculation Results'), findsOneWidget);

      // Should show medium category
      expect(find.textContaining('Medium'), findsOneWidget);

      // Should show tax payable amount
      expect(find.textContaining('₦'), findsWidgets);
    });

    testWidgets('should calculate and display results for large company',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter large company data (> 100M)
      final turnoverField = find.widgetWithText(TextField, 'Annual Turnover');
      await tester.enterText(turnoverField, '150000000');

      final profitField = find.widgetWithText(TextField, 'Taxable Profit');
      await tester.enterText(profitField, '30000000');

      // Calculate
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('CIT Calculation Results'), findsOneWidget);

      // Should show large category
      expect(find.textContaining('Large'), findsOneWidget);

      // Should show 30% rate
      expect(find.textContaining('30'), findsOneWidget);
    });

    testWidgets('should clear form when clear button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter data
      final turnoverField = find.widgetWithText(TextField, 'Annual Turnover');
      await tester.enterText(turnoverField, '50000000');

      final profitField = find.widgetWithText(TextField, 'Taxable Profit');
      await tester.enterText(profitField, '10000000');

      await tester.pumpAndSettle();

      // Find and tap clear button (if exists)
      final clearButton = find.widgetWithIcon(IconButton, Icons.clear);
      if (tester.any(clearButton)) {
        await tester.tap(clearButton.first);
        await tester.pumpAndSettle();

        // Fields should be cleared
        final turnoverWidget = tester.widget<TextField>(turnoverField);
        final profitWidget = tester.widget<TextField>(profitField);

        expect(turnoverWidget.controller?.text.isEmpty, isTrue);
        expect(profitWidget.controller?.text.isEmpty, isTrue);
      }
    });

    testWidgets('should show save button after calculation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter data and calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '50000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '10000000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show save button
      expect(find.textContaining('Save'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle zero profit calculation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter zero profit
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '50000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '0');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show results with zero tax
      expect(find.text('CIT Calculation Results'), findsOneWidget);
      expect(find.textContaining('₦0'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle very large numbers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter very large numbers
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '999999999999');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '500000000000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should calculate without errors
      expect(find.text('CIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should display formatted currency values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate with known values
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '50000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '10000000');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should display currency symbol
      expect(find.textContaining('₦'), findsWidgets);
    });

    testWidgets('should handle decimal input values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter decimal values
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '50000000.50');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '10000000.75');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should calculate successfully
      expect(find.text('CIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should recalculate when values change',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First calculation
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '50000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '10000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      expect(find.text('CIT Calculation Results'), findsOneWidget);

      // Change values and recalculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '20000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '5000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show updated results
      expect(find.text('CIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should show rate information in results',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '50000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '10000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show rate percentage
      expect(find.textContaining('%'), findsAtLeastNWidgets(1));
    });
  });
}
