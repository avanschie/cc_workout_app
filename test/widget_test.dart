import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:cc_workout_app/main.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';
import 'package:cc_workout_app/features/rep_maxes/services/rep_max_calculation_service.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([RepMaxCalculationService])
void main() {
  testWidgets('App displays main screen with empty state', (
    WidgetTester tester,
  ) async {
    final mockService = MockRepMaxCalculationService();
    final emptyRepMaxTable = {
      for (final liftType in LiftType.values) liftType: <int, RepMax>{},
    };

    when(
      mockService.getFullRepMaxTable(),
    ).thenAnswer((_) async => emptyRepMaxTable);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repMaxCalculationServiceProvider.overrideWithValue(mockService),
        ],
        child: const MainApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Powerlifting Tracker'), findsOneWidget);
    expect(find.text('Your Rep Maxes'), findsOneWidget);
    expect(
      find.text('Start logging lifts to build your rep max records'),
      findsOneWidget,
    );
    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Deadlift'), findsOneWidget);
    expect(
      find.text('—'),
      findsWidgets,
    ); // Should show dashes for empty entries
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('App displays main screen with rep max data', (
    WidgetTester tester,
  ) async {
    final mockService = MockRepMaxCalculationService();
    final sampleRepMaxTable = {
      LiftType.squat: {
        1: RepMax(
          userId: 'user1',
          lift: LiftType.squat,
          reps: 1,
          weightKg: 200.0,
          lastPerformedAt: DateTime(2023, 1, 1),
        ),
      },
      LiftType.bench: <int, RepMax>{},
      LiftType.deadlift: <int, RepMax>{},
    };

    when(
      mockService.getFullRepMaxTable(),
    ).thenAnswer((_) async => sampleRepMaxTable);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repMaxCalculationServiceProvider.overrideWithValue(mockService),
        ],
        child: const MainApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Powerlifting Tracker'), findsOneWidget);
    expect(find.text('Your Rep Maxes'), findsOneWidget);
    expect(find.text('Personal records for each rep count'), findsOneWidget);
    expect(find.text('200.0 kg'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
