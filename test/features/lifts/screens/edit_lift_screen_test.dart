import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/features/lifts/screens/edit_lift_screen.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

void main() {
  group('EditLiftScreen Widget Tests', () {
    late LiftEntry testLiftEntry;

    setUp(() {
      testLiftEntry = LiftEntry(
        id: 'test-id-123',
        userId: 'user-123',
        lift: LiftType.squat,
        reps: 5,
        weightKg: 100.0,
        performedAt: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 15),
      );
    });

    testWidgets('displays all required form fields with initial data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: EditLiftScreen(liftEntry: testLiftEntry)),
        ),
      );

      // Allow the widget to initialize
      await tester.pumpAndSettle();

      expect(find.text('Edit Lift'), findsOneWidget);
      expect(find.text('Lift Type'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Date Performed'), findsOneWidget);

      // Check for save and cancel buttons
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Check for delete button in app bar
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('form fields are pre-populated with lift entry data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: EditLiftScreen(liftEntry: testLiftEntry)),
        ),
      );

      // Allow the widget to initialize and form to be populated
      await tester.pumpAndSettle();
      // Wait a bit more for the provider to initialize
      await tester.pump(const Duration(milliseconds: 100));

      // Check that dropdown has the correct value by looking for the dropdown button
      final dropdownButton = find.byType(DropdownButtonFormField<LiftType>);
      expect(dropdownButton, findsOneWidget);

      // Check that form fields show the correct initial values
      final repsFormField = find.byType(TextFormField).first;
      final repsTextField = tester.widget<TextFormField>(repsFormField);
      expect(repsTextField.initialValue, '5');

      final weightFormField = find.byType(TextFormField).at(1);
      final weightTextField = tester.widget<TextFormField>(weightFormField);
      expect(weightTextField.initialValue, '100.0');

      // Check date display
      expect(find.textContaining('Jan 15, 2024'), findsOneWidget); // date
    });

    testWidgets('can modify form field values', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: EditLiftScreen(liftEntry: testLiftEntry)),
        ),
      );

      await tester.pumpAndSettle();

      // Modify reps field
      final repsField = find.byType(TextFormField).first;
      await tester.enterText(repsField, '8');
      await tester.pump();

      expect(find.text('8'), findsOneWidget);

      // Modify weight field
      final weightField = find.byType(TextFormField).at(1);
      await tester.enterText(weightField, '120.5');
      await tester.pump();

      expect(find.text('120.5'), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid inputs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: EditLiftScreen(liftEntry: testLiftEntry)),
        ),
      );

      await tester.pumpAndSettle();

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

    testWidgets('cancel button exists and has correct properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: EditLiftScreen(liftEntry: testLiftEntry)),
        ),
      );

      await tester.pumpAndSettle();

      // Find cancel button
      final cancelButton = find.text('Cancel');
      expect(cancelButton, findsOneWidget);

      // Verify it's clickable (onPressed is not null)
      final buttonWidget = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(buttonWidget.onPressed, isNotNull);
    });

    testWidgets('date picker opens when date field is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: EditLiftScreen(liftEntry: testLiftEntry)),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('delete button shows confirmation dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: EditLiftScreen(liftEntry: testLiftEntry)),
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete button in app bar
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Delete Lift'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this lift?'),
        findsOneWidget,
      );
      expect(find.text('Squat'), findsWidgets); // Multiple instances are ok
      expect(find.text('5 reps × 100.0 kg'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);

      // Should have cancel and delete buttons in dialog
      expect(find.text('Cancel'), findsWidgets); // Multiple cancel buttons
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('delete confirmation dialog can be cancelled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: EditLiftScreen(liftEntry: testLiftEntry)),
        ),
      );

      await tester.pumpAndSettle();

      // Open delete confirmation dialog
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Tap cancel in dialog
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(
        find.text('Are you sure you want to delete this lift?'),
        findsNothing,
      );
    });
  });
}
