import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/lifts/screens/add_lift_screen.dart';
import 'package:cc_workout_app/features/lifts/screens/edit_lift_screen.dart';
import 'package:cc_workout_app/features/lifts/screens/history_screen.dart';
import 'base_robot.dart';

/// Robot class for testing lift-related UI interactions
///
/// This robot provides a high-level API for testing lift entry flows,
/// making tests more readable and maintainable.
class LiftRobot extends BaseRobot {
  const LiftRobot(super.tester);

  // Finders for lift form elements
  Finder get liftTypeDropdown => find.byKey(const Key('lift_type_dropdown'));
  Finder get repsField => find.byKey(const Key('reps_field'));
  Finder get weightField => find.byKey(const Key('weight_field'));
  Finder get dateField => find.byKey(const Key('date_field'));
  Finder get saveButton => find.byKey(const Key('save_button'));
  Finder get cancelButton => find.byKey(const Key('cancel_button'));
  Finder get deleteButton => find.byKey(const Key('delete_button'));

  // History screen elements
  Finder get historyList => find.byKey(const Key('history_list'));
  Finder get emptyHistoryMessage => find.byKey(const Key('empty_history_message'));
  Finder get addLiftFab => find.byKey(const Key('add_lift_fab'));

  // Rep maxes elements
  Finder get repMaxesTable => find.byKey(const Key('rep_maxes_table'));
  Finder get emptyRepMaxesMessage => find.byKey(const Key('empty_rep_maxes_message'));

  // Form validation
  Finder repsErrorText(String error) => find.text(error);
  Finder weightErrorText(String error) => find.text(error);
  Finder dateErrorText(String error) => find.text(error);

  // Loading and error states
  @override
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  @override
  Finder get errorSnackBar => find.byType(SnackBar);

  /// Select a lift type from the dropdown
  Future<void> selectLiftType(LiftType liftType) async {
    await tester.tap(liftTypeDropdown);
    await tester.pumpAndSettle();

    await tester.tap(find.text(liftType.displayName));
    await tester.pumpAndSettle();
  }

  /// Enter number of reps
  Future<void> enterReps(String reps) async {
    await tester.enterText(repsField, reps);
    await tester.pumpAndSettle();
  }

  /// Enter weight in kg
  Future<void> enterWeight(String weight) async {
    await tester.enterText(weightField, weight);
    await tester.pumpAndSettle();
  }

  /// Select a date
  Future<void> selectDate(DateTime date) async {
    await tester.tap(dateField);
    await tester.pumpAndSettle();

    // This would need to be customized based on the actual date picker implementation
    // For now, we'll assume a simple tap on the date field
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  /// Save the lift entry
  Future<void> tapSave() async {
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  /// Cancel the lift entry
  Future<void> tapCancel() async {
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
  }

  /// Delete the lift entry
  Future<void> tapDelete() async {
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
  }

  /// Complete lift entry flow
  Future<void> createLiftEntry({
    required LiftType liftType,
    required String reps,
    required String weight,
    DateTime? date,
  }) async {
    await selectLiftType(liftType);
    await enterReps(reps);
    await enterWeight(weight);

    if (date != null) {
      await selectDate(date);
    }

    await tapSave();
  }

  /// Tap on a lift entry in the history list
  Future<void> tapLiftEntryInHistory(int index) async {
    final listItem = find.byKey(Key('lift_entry_$index'));
    await tester.tap(listItem);
    await tester.pumpAndSettle();
  }

  /// Tap the add lift FAB
  Future<void> tapAddLiftFab() async {
    await tester.tap(addLiftFab);
    await tester.pumpAndSettle();
  }

  // Verification methods

  /// Verify that we're on the add lift screen
  void expectToBeOnAddLiftScreen() {
    expect(find.byType(AddLiftScreen), findsOneWidget);
    expect(saveButton, findsOneWidget);
  }

  /// Verify that we're on the edit lift screen
  void expectToBeOnEditLiftScreen() {
    expect(find.byType(EditLiftScreen), findsOneWidget);
    expect(saveButton, findsOneWidget);
    expect(deleteButton, findsOneWidget);
  }

  /// Verify that we're on the history screen
  void expectToBeOnHistoryScreen() {
    expect(find.byType(HistoryScreen), findsOneWidget);
  }

  /// Verify that a loading indicator is shown
  void expectLoadingIndicator() {
    expect(loadingIndicator, findsOneWidget);
  }

  /// Verify that no loading indicator is shown
  void expectNoLoadingIndicator() {
    expect(loadingIndicator, findsNothing);
  }

  /// Verify that an error message is displayed
  @override
  void expectErrorMessage(String message) {
    expect(find.text(message), findsOneWidget);
  }

  /// Verify that validation errors are shown
  void expectRepsValidationError(String error) {
    expect(repsErrorText(error), findsOneWidget);
  }

  void expectWeightValidationError(String error) {
    expect(weightErrorText(error), findsOneWidget);
  }

  void expectDateValidationError(String error) {
    expect(dateErrorText(error), findsOneWidget);
  }

  /// Verify that the save button is enabled
  void expectSaveButtonEnabled() {
    final button = tester.widget<ElevatedButton>(saveButton);
    expect(button.onPressed, isNotNull);
  }

  /// Verify that the save button is disabled
  void expectSaveButtonDisabled() {
    final button = tester.widget<ElevatedButton>(saveButton);
    expect(button.onPressed, isNull);
  }

  /// Verify lift type selection
  void expectLiftTypeSelected(LiftType liftType) {
    expect(find.text(liftType.displayName), findsOneWidget);
  }

  /// Verify empty history state
  void expectEmptyHistory() {
    expect(emptyHistoryMessage, findsOneWidget);
    expect(historyList, findsNothing);
  }

  /// Verify history has entries
  void expectHistoryHasEntries(int count) {
    expect(historyList, findsOneWidget);

    // Find lift entry items
    for (int i = 0; i < count; i++) {
      expect(find.byKey(Key('lift_entry_$i')), findsOneWidget);
    }
  }

  /// Verify rep maxes table is displayed
  void expectRepMaxesTable() {
    expect(repMaxesTable, findsOneWidget);
  }

  /// Verify empty rep maxes state
  void expectEmptyRepMaxes() {
    expect(emptyRepMaxesMessage, findsOneWidget);
  }

  /// Verify specific rep max value
  void expectRepMaxValue(LiftType liftType, int reps, String weight) {
    final repMaxKey = Key('rep_max_${liftType.value}_$reps');
    expect(find.byKey(repMaxKey), findsOneWidget);
    expect(find.text(weight), findsOneWidget);
  }
}