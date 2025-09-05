import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/shared/widgets/rep_max_table_widget.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/shared/constants/lift_colors.dart';

void main() {
  group('RepMaxTableWidget', () {
    Widget buildWidget(Map<LiftType, Map<int, RepMax>> repMaxTable) {
      return MaterialApp(
        home: Scaffold(body: RepMaxTableWidget(repMaxTable: repMaxTable)),
      );
    }

    testWidgets('displays colored indicators in headers', (tester) async {
      final repMaxTable = <LiftType, Map<int, RepMax>>{};

      await tester.pumpWidget(buildWidget(repMaxTable));

      // Check that colored indicators are present for each lift type
      for (final liftType in LiftType.values) {
        final coloredIndicator = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  LiftColors.getColor(liftType) &&
              widget.constraints?.maxWidth == 4,
        );
        expect(coloredIndicator, findsOneWidget);
      }
    });

    testWidgets('displays lift type names in headers', (tester) async {
      final repMaxTable = <LiftType, Map<int, RepMax>>{};

      await tester.pumpWidget(buildWidget(repMaxTable));

      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
    });

    testWidgets('applies colored styling to cells with data', (tester) async {
      final repMaxTable = {
        LiftType.squat: {
          1: RepMax(
            userId: 'test-user',
            lift: LiftType.squat,
            reps: 1,
            weightKg: 100.0,
            lastPerformedAt: DateTime(2024, 1, 1),
          ),
        },
        LiftType.bench: <int, RepMax>{},
        LiftType.deadlift: <int, RepMax>{},
      };

      await tester.pumpWidget(buildWidget(repMaxTable));

      // Find containers with colored backgrounds (cells with data)
      final coloredCells = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                LiftColors.squat.withValues(alpha: 0.08),
      );

      expect(coloredCells, findsOneWidget);
    });

    testWidgets('displays weight values correctly', (tester) async {
      final repMaxTable = {
        LiftType.squat: {
          1: RepMax(
            userId: 'test-user',
            lift: LiftType.squat,
            reps: 1,
            weightKg: 100.5,
            lastPerformedAt: DateTime(2024, 1, 1),
          ),
        },
        LiftType.bench: <int, RepMax>{},
        LiftType.deadlift: <int, RepMax>{},
      };

      await tester.pumpWidget(buildWidget(repMaxTable));

      expect(find.text('100.5 kg'), findsOneWidget);
    });

    testWidgets('displays em dash for empty cells', (tester) async {
      final repMaxTable = <LiftType, Map<int, RepMax>>{
        LiftType.squat: <int, RepMax>{},
        LiftType.bench: <int, RepMax>{},
        LiftType.deadlift: <int, RepMax>{},
      };

      await tester.pumpWidget(buildWidget(repMaxTable));

      // Should find many em dashes for empty cells
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('displays rep numbers 1-10', (tester) async {
      final repMaxTable = <LiftType, Map<int, RepMax>>{};

      await tester.pumpWidget(buildWidget(repMaxTable));

      for (int i = 1; i <= 10; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });
  });
}
