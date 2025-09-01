import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';
import 'package:cc_workout_app/features/rep_maxes/services/rep_max_calculation_service.dart';
import 'package:cc_workout_app/features/rep_maxes/screens/rep_maxes_screen.dart';

import 'rep_maxes_screen_test.mocks.dart';

@GenerateMocks([RepMaxCalculationService])
void main() {
  group('RepMaxesScreen', () {
    late MockRepMaxCalculationService mockService;

    setUp(() {
      mockService = MockRepMaxCalculationService();
    });

    final sampleRepMaxTable = {
      LiftType.squat: {
        1: RepMax(
          userId: 'user1',
          lift: LiftType.squat,
          reps: 1,
          weightKg: 200.0,
          lastPerformedAt: DateTime(2023, 1, 1),
        ),
        5: RepMax(
          userId: 'user1',
          lift: LiftType.squat,
          reps: 5,
          weightKg: 180.0,
          lastPerformedAt: DateTime(2023, 1, 2),
        ),
      },
      LiftType.bench: {
        1: RepMax(
          userId: 'user1',
          lift: LiftType.bench,
          reps: 1,
          weightKg: 150.0,
          lastPerformedAt: DateTime(2023, 1, 3),
        ),
      },
      LiftType.deadlift: <int, RepMax>{},
    };

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          repMaxCalculationServiceProvider.overrideWithValue(mockService),
        ],
        child: const MaterialApp(home: RepMaxesScreen()),
      );
    }

    testWidgets('should display app bar with title', (
      tester,
    ) async {
      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => sampleRepMaxTable);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Rep Maxes'), findsOneWidget);
    });

    testWidgets('should display error state when error occurs', (tester) async {
      const errorMessage = 'Failed to load data';
      when(mockService.getFullRepMaxTable()).thenThrow(Exception(errorMessage));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to load rep maxes'), findsOneWidget);
      expect(find.textContaining(errorMessage), findsOneWidget);
    });

    testWidgets('should display empty state when no data exists', (
      tester,
    ) async {
      final emptyRepMaxTable = {
        for (final liftType in LiftType.values) liftType: <int, RepMax>{},
      };

      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => emptyRepMaxTable);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.text('No Rep Maxes Yet'), findsOneWidget);
      expect(
        find.text('Start logging your lifts to see your rep maxes here!'),
        findsOneWidget,
      );
    });

    testWidgets('should display rep max table with data', (tester) async {
      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => sampleRepMaxTable);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Best Weight Per Rep Range'), findsOneWidget);
      expect(
        find.text('Your personal records for each rep count'),
        findsOneWidget,
      );

      for (final liftType in LiftType.values) {
        expect(find.text(liftType.displayName), findsOneWidget);
      }

      expect(find.text('Reps'), findsWidgets);
      expect(find.text('Best Weight'), findsWidgets);

      expect(find.text('200.0 kg'), findsOneWidget);
      expect(find.text('180.0 kg'), findsOneWidget);
      expect(find.text('150.0 kg'), findsOneWidget);
    });

    testWidgets('should display empty message for lift types with no data', (
      tester,
    ) async {
      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => sampleRepMaxTable);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('No data yet - start logging deadlift lifts!'),
        findsOneWidget,
      );
    });

    testWidgets('should display all rep ranges (1-10) in tables', (
      tester,
    ) async {
      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => sampleRepMaxTable);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      for (int i = 1; i <= 10; i++) {
        expect(find.text(i.toString()), findsWidgets);
      }
    });

    testWidgets('should support pull to refresh', (tester) async {
      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => sampleRepMaxTable);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should show dash for missing rep max entries', (tester) async {
      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => sampleRepMaxTable);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('—'), findsWidgets);
    });
  });
}
