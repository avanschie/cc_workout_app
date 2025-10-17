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

/// Test notifier that avoids timers and complex dependencies
class TestRepMaxTableNotifier extends RepMaxTableNotifier {
  final RepMaxCalculationService _service;

  TestRepMaxTableNotifier(this._service);

  @override
  Future<Map<LiftType, Map<int, RepMax>>> build() async {
    // Don't watch other providers in test to avoid complex dependencies
    return await _service.getFullRepMaxTable();
  }

  @override
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _service.getFullRepMaxTable();
    });
  }
}

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
          // Override the notifier provider to avoid timer issues in tests
          repMaxTableNotifierProvider.overrideWith(
            () => TestRepMaxTableNotifier(mockService),
          ),
        ],
        child: const MaterialApp(home: RepMaxesScreen()),
      );
    }

    testWidgets('should display app bar with title', (tester) async {
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

    testWidgets('should display table even when completely empty', (
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

      // Should still show table headers
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);

      // All cells should show dashes for empty data
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('should display rep max table with data', (tester) async {
      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => sampleRepMaxTable);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the table header
      expect(find.text('Reps'), findsOneWidget);

      // Check for lift type headers in the compact table
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);

      // Check for weight values in the table
      expect(find.text('200 kg'), findsOneWidget);
      expect(find.text('180 kg'), findsOneWidget);
      expect(find.text('150 kg'), findsOneWidget);
    });

    testWidgets(
      'should display table with empty cells for lift types with no data',
      (tester) async {
        when(
          mockService.getFullRepMaxTable(),
        ).thenAnswer((_) async => sampleRepMaxTable);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // The table should show all lift column headers
        expect(find.text('Squat'), findsOneWidget);
        expect(find.text('Bench'), findsOneWidget);
        expect(find.text('Deadlift'), findsOneWidget);

        // Empty cells are represented with "—" dash
        expect(find.text('—'), findsWidgets);
      },
    );

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
