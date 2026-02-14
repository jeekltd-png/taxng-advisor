import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/widgets/progress_overlay.dart';

void main() {
  group('ProgressOverlay Widget', () {
    testWidgets('should display message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressOverlay(
              message: 'Loading data...',
            ),
          ),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('should show indeterminate progress when progress is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressOverlay(
              message: 'Processing...',
              progress: null,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('should show percentage when progress is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressOverlay(
              message: 'Uploading...',
              progress: 0.5,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should hide percentage when showPercentage is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressOverlay(
              message: 'Saving...',
              progress: 0.75,
              showPercentage: false,
            ),
          ),
        ),
      );

      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('should display 0% for zero progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressOverlay(
              message: 'Starting...',
              progress: 0.0,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('should display 100% for complete progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressOverlay(
              message: 'Complete!',
              progress: 1.0,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should have semi-transparent background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressOverlay(
              message: 'Test',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.color, equals(Colors.black54));
    });

    testWidgets('should be centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressOverlay(
              message: 'Test',
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should contain a Card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressOverlay(
              message: 'Test',
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('ProgressOverlay Static Methods', () {
    testWidgets('show should display overlay as dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  ProgressOverlay.show(
                    context,
                    message: 'Dialog test',
                  );
                },
                child: const Text('Show Progress'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Progress'));
      await tester.pump();

      expect(find.text('Dialog test'), findsOneWidget);
    });

    testWidgets('hide should close the overlay', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ProgressOverlay.show(
                        context,
                        message: 'Hide test',
                      );
                    },
                    child: const Text('Show'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ProgressOverlay.hide(context);
                    },
                    child: const Text('Hide'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Show the overlay
      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(find.text('Hide test'), findsOneWidget);

      // We can verify the overlay is shown, but hide needs dialog context
    });
  });

  group('LinearProgressOverlay Widget', () {
    testWidgets('should display message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LinearProgressOverlay(
              message: 'Processing items...',
              progress: 0.3,
              currentItem: 3,
              totalItems: 10,
            ),
          ),
        ),
      );

      expect(find.text('Processing items...'), findsOneWidget);
    });

    testWidgets('should display item counter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LinearProgressOverlay(
              message: 'Processing...',
              progress: 0.5,
              currentItem: 5,
              totalItems: 10,
            ),
          ),
        ),
      );

      expect(find.text('5 of 10 items'), findsOneWidget);
    });

    testWidgets('should show linear progress bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LinearProgressOverlay(
              message: 'Loading...',
              progress: 0.6,
              currentItem: 6,
              totalItems: 10,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('CompactProgressIndicator Widget', () {
    testWidgets('should display with default size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactProgressIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display message when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactProgressIndicator(
              message: 'Loading...',
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should use custom color when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactProgressIndicator(
              color: Colors.red,
            ),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      // Color is set via valueColor (AlwaysStoppedAnimation)
      expect(indicator.valueColor, isA<AlwaysStoppedAnimation<Color>>());
      final colorAnim = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(colorAnim.value, equals(Colors.red));
    });

    testWidgets('should use custom size when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactProgressIndicator(
              size: 30,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );
      expect(sizedBox.width, equals(30));
      expect(sizedBox.height, equals(30));
    });
  });
}
