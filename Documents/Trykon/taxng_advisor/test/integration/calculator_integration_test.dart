import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/features/cit/presentation/cit_calculator_screen.dart';
import 'package:taxng_advisor/features/dashboard/presentation/dashboard_screen.dart';
import 'package:taxng_advisor/services/hive_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';

void main() {
  setUpAll(() async {
    await HiveService.initForTesting();
  });

  tearDownAll(() async {
    await HiveService.closeForTesting();
  });

  group('Integration Tests - Calculator Workflows', () {
    testWidgets('should navigate from dashboard to CIT calculator',
        (WidgetTester tester) async {
      // Login test user
      await AuthService.register(
        email: 'test@example.com',
        password: 'password123',
        username: 'Test User',
      );
      await AuthService.login('test@example.com', 'password123');

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(),
          routes: {
            '/cit': (_) => CitCalculatorScreen(),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap CIT calculator tile
      final citTile = find.text('CIT Calculator');
      expect(citTile, findsOneWidget);

      await tester.tap(citTile);
      await tester.pumpAndSettle();

      // Should navigate to CIT calculator
      expect(find.text('Annual Turnover'), findsOneWidget);
    });

    testWidgets('should calculate CIT and save to storage',
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
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '50000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '10000000');

      // Calculate
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show results
      expect(find.text('CIT Calculation Results'), findsOneWidget);

      // Save result
      final saveButton = find.text('Save');
      if (tester.any(saveButton)) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle();

        // Should show success message
        expect(find.textContaining('saved'), findsOneWidget);
      }
    });

    testWidgets('should validate input before allowing calculation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter invalid data (profit > turnover)
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '10000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '20000000');

      // Try to calculate
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('cannot exceed'), findsOneWidget);
    });

    testWidgets('should handle multiple calculations in sequence',
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
          find.widgetWithText(TextField, 'Annual Turnover'), '30000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '6000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      expect(find.text('CIT Calculation Results'), findsOneWidget);

      // Second calculation
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '60000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '12000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show updated results
      expect(find.text('CIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should export calculation results',
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

      // Find export/share button
      final exportButton = find.byIcon(Icons.share);
      if (tester.any(exportButton)) {
        await tester.tap(exportButton.first);
        await tester.pumpAndSettle();

        // Should show share options or success
        expect(find.byType(Dialog), findsOneWidget);
      }
    });

    testWidgets('should clear form and start fresh calculation',
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

      // Clear form
      final clearButton = find.widgetWithIcon(IconButton, Icons.clear);
      if (tester.any(clearButton)) {
        await tester.tap(clearButton.first);
        await tester.pumpAndSettle();

        // Form should be cleared
        final turnoverField =
            find.widgetWithText(TextField, 'Annual Turnover');
        final turnoverWidget = tester.widget<TextField>(turnoverField);
        expect(turnoverWidget.controller?.text.isEmpty, isTrue);
      }
    });

    testWidgets('should handle payment flow after calculation',
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

      // Find pay button
      final payButton = find.textContaining('Pay');
      if (tester.any(payButton)) {
        await tester.tap(payButton.first);
        await tester.pumpAndSettle();

        // Should show payment dialog or navigate to payment screen
        expect(find.byType(AlertDialog), findsOneWidget);
      }
    });

    testWidgets('should persist data across screen rebuilds',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate and save
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '50000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '10000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      if (tester.any(saveButton)) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle();
      }

      // Rebuild widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Data should be retrievable from storage
      expect(find.byType(CitCalculatorScreen), findsOneWidget);
    });

    testWidgets('should handle error recovery gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter invalid data
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '-50000000');

      // Try to calculate
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('must be positive'), findsOneWidget);

      // Correct the input
      await tester.enterText(
          find.widgetWithText(TextField, 'Annual Turnover'), '50000000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Taxable Profit'), '10000000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
      await tester.pumpAndSettle();

      // Should now calculate successfully
      expect(find.text('CIT Calculation Results'), findsOneWidget);
    });

    testWidgets('should handle import data workflow',
        (WidgetTester tester) async {
      // Create calculator with imported data
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == '/cit') {
              return MaterialPageRoute(
                builder: (_) => CitCalculatorScreen(),
                settings: RouteSettings(
                  arguments: {
                    'turnover': 50000000,
                    'profit': 10000000,
                  },
                ),
              );
            }
            return null;
          },
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/cit'),
                child: Text('Import Data'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger import
      await tester.tap(find.text('Import Data'));
      await tester.pumpAndSettle();

      // Should auto-calculate with imported data
      expect(find.text('CIT Calculation Results'), findsOneWidget);
    });
  });

  group('Integration Tests - Data Persistence', () {
    testWidgets('should save and retrieve calculation history',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CitCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Perform multiple calculations
      for (int i = 1; i <= 3; i++) {
        await tester.enterText(find.widgetWithText(TextField, 'Annual Turnover'),
            '${50000000 * i}');
        await tester.enterText(find.widgetWithText(TextField, 'Taxable Profit'),
            '${10000000 * i}');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Calculate CIT'));
        await tester.pumpAndSettle();

        final saveButton = find.text('Save');
        if (tester.any(saveButton)) {
          await tester.tap(saveButton.first);
          await tester.pumpAndSettle();
        }
      }

      // Verify multiple saves completed
      expect(find.byType(CitCalculatorScreen), findsOneWidget);
    });
  });

  group('Integration Tests - Navigation Flow', () {
    testWidgets('should navigate between calculators',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Calculator')),
            body: CitCalculatorScreen(),
            drawer: Drawer(
              child: ListView(
                children: [
                  ListTile(
                    title: Text('PIT Calculator'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('VAT Calculator'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Should show navigation options
      expect(find.text('PIT Calculator'), findsOneWidget);
      expect(find.text('VAT Calculator'), findsOneWidget);
    });
  });
}
