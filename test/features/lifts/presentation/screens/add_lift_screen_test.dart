import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/features/lifts/presentation/screens/add_lift_screen.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

void main() {
  group('AddLiftScreen Widget Tests', () {
    testWidgets('displays all required form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddLiftScreen())),
      );

      expect(find.text('Add Lift'), findsOneWidget);
      expect(find.text('Lift Type'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Date Performed'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('lift type dropdown shows all lift types', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddLiftScreen())),
      );

      await tester.tap(find.byType(DropdownButtonFormField<LiftType>));
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
    });

    testWidgets('save button is disabled when form is invalid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddLiftScreen())),
      );

      final saveButton = find.byType(ElevatedButton);
      expect(saveButton, findsOneWidget);

      final buttonWidget = tester.widget<ElevatedButton>(saveButton);
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('can enter reps in text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddLiftScreen())),
      );

      final repsField = find.byType(TextFormField).first;
      await tester.enterText(repsField, '5');
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('can enter weight in text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddLiftScreen())),
      );

      final weightField = find.byType(TextFormField).at(1);
      await tester.enterText(weightField, '100.5');
      await tester.pump();

      expect(find.text('100.5'), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid inputs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddLiftScreen())),
      );

      // Enter invalid reps
      final repsField = find.byType(TextFormField).first;
      await tester.enterText(repsField, '15');
      await tester.pump();

      // Enter invalid weight
      final weightField = find.byType(TextFormField).at(1);
      await tester.enterText(weightField, '0');
      await tester.pump();

      expect(find.textContaining('Maximum 10 reps allowed'), findsOneWidget);
      expect(
        find.textContaining('Weight must be greater than 0'),
        findsOneWidget,
      );
    });

    testWidgets('date picker opens when date field is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddLiftScreen())),
      );

      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
