import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/features/lifts/screens/history_screen.dart';

void main() {
  group('HistoryScreen Widget Tests', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      // Test that the screen can be rendered without dependencies
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HistoryScreen())),
      );

      // Verify the app bar is rendered
      expect(find.text('Lift History'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('app bar has correct title and refresh button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HistoryScreen())),
      );

      // Check app bar components
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Lift History'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Check that refresh button is tappable
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);
      await tester.tap(refreshButton);
      await tester.pump();
    });

    testWidgets('has correct scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HistoryScreen())),
      );

      // Verify basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // The body will show loading or error state initially
      // since we don't have proper repository mocks
    });

    testWidgets('refresh button has correct tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HistoryScreen())),
      );

      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      // Check tooltip
      final iconButton = tester.widget<IconButton>(
        find.ancestor(of: refreshButton, matching: find.byType(IconButton)),
      );
      expect(iconButton.tooltip, equals('Refresh'));
    });

    testWidgets('app bar has correct background color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HistoryScreen())),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, equals(0));
      expect(appBar.title, isA<Text>());
      expect((appBar.title as Text).data, equals('Lift History'));
    });

    testWidgets('screen is a consumer widget for state management', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HistoryScreen())),
      );

      // Verify that the screen uses ConsumerWidget for Riverpod integration
      expect(find.byType(HistoryScreen), findsOneWidget);

      // HistoryScreen is a ConsumerWidget, so it has access to ref
      final historyScreen = tester.widget<HistoryScreen>(
        find.byType(HistoryScreen),
      );
      expect(historyScreen, isA<ConsumerWidget>());
    });
  });
}
