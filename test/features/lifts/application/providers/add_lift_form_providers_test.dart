import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/lifts/application/providers/add_lift_form_providers.dart';

void main() {
  group('AddLiftFormNotifier', () {
    late ProviderContainer container;
    late AddLiftFormNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(addLiftFormProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has today as performed date', () {
      final state = container.read(addLiftFormProvider);

      expect(state.performedAt, isNotNull);
      expect(state.performedAt!.day, equals(DateTime.now().day));
      expect(state.liftType, isNull);
      expect(state.reps, isNull);
      expect(state.weightKg, isNull);
    });

    test('setLiftType updates lift type and clears error', () {
      notifier.setLiftType(LiftType.squat);

      final state = container.read(addLiftFormProvider);
      expect(state.liftType, equals(LiftType.squat));
      expect(state.liftTypeError, isNull);
    });

    test('setLiftType with null sets error', () {
      notifier.setLiftType(null);

      final state = container.read(addLiftFormProvider);
      expect(state.liftType, isNull);
      expect(state.liftTypeError, equals('Lift type is required'));
    });

    test('setReps with valid input updates reps', () {
      notifier.setReps('5');

      final state = container.read(addLiftFormProvider);
      expect(state.reps, equals(5));
      expect(state.repsError, isNull);
    });

    test('setReps with invalid range shows error', () {
      notifier.setReps('15');

      final state = container.read(addLiftFormProvider);
      expect(state.reps, equals(15));
      expect(state.repsError, equals('Maximum 10 reps allowed'));
    });

    test('setReps with empty string shows required error', () {
      notifier.setReps('');

      final state = container.read(addLiftFormProvider);
      expect(state.reps, isNull);
      expect(state.repsError, equals('Reps is required'));
    });

    test('setReps with non-numeric input shows error', () {
      notifier.setReps('abc');

      final state = container.read(addLiftFormProvider);
      expect(state.reps, isNull);
      expect(state.repsError, equals('Please enter a valid whole number'));
    });

    test('setWeight with valid input updates weight', () {
      notifier.setWeight('100.5');

      final state = container.read(addLiftFormProvider);
      expect(state.weightKg, equals(100.5));
      expect(state.weightError, isNull);
    });

    test('setWeight with zero shows error', () {
      notifier.setWeight('0');

      final state = container.read(addLiftFormProvider);
      expect(state.weightKg, equals(0.0));
      expect(state.weightError, contains('greater than 0'));
    });

    test('setWeight with excessive weight shows error', () {
      notifier.setWeight('1500');

      final state = container.read(addLiftFormProvider);
      expect(state.weightKg, equals(1500.0));
      expect(state.weightError, contains('cannot exceed 1000'));
    });

    test('setWeight with empty string shows required error', () {
      notifier.setWeight('');

      final state = container.read(addLiftFormProvider);
      expect(state.weightKg, isNull);
      expect(state.weightError, equals('Weight is required'));
    });

    test('setPerformedAt with future date shows error', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      notifier.setPerformedAt(futureDate);

      final state = container.read(addLiftFormProvider);
      expect(state.performedAt, equals(futureDate));
      expect(state.dateError, equals('Date cannot be in the future'));
    });

    test('setPerformedAt with valid date clears error', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      notifier.setPerformedAt(pastDate);

      final state = container.read(addLiftFormProvider);
      expect(state.performedAt, equals(pastDate));
      expect(state.dateError, isNull);
    });

    test('isValid returns true when all fields are valid', () {
      notifier.setLiftType(LiftType.squat);
      notifier.setReps('5');
      notifier.setWeight('100');
      notifier.setPerformedAt(DateTime.now());

      final state = container.read(addLiftFormProvider);
      expect(state.isValid, isTrue);
    });

    test('isValid returns false when any field is invalid', () {
      notifier.setLiftType(LiftType.squat);
      notifier.setReps('15'); // Invalid reps
      notifier.setWeight('100');
      notifier.setPerformedAt(DateTime.now());

      final state = container.read(addLiftFormProvider);
      expect(state.isValid, isFalse);
    });

    test('clearForm resets to initial state', () {
      notifier.setLiftType(LiftType.squat);
      notifier.setReps('5');
      notifier.setWeight('100');

      notifier.clearForm();

      final state = container.read(addLiftFormProvider);
      expect(state.liftType, isNull);
      expect(state.reps, isNull);
      expect(state.weightKg, isNull);
      expect(state.performedAt, isNotNull); // Should be set to today
    });

    test('toLiftEntry returns valid LiftEntry when form is complete', () {
      const userId = 'test-user-id';
      notifier.setLiftType(LiftType.squat);
      notifier.setReps('5');
      notifier.setWeight('100.5');
      notifier.setPerformedAt(DateTime(2024, 1, 15));

      final liftEntry = notifier.toLiftEntry(userId);

      expect(liftEntry, isNotNull);
      expect(liftEntry!.userId, equals(userId));
      expect(liftEntry.lift, equals(LiftType.squat));
      expect(liftEntry.reps, equals(5));
      expect(liftEntry.weightKg, equals(100.5));
      expect(liftEntry.performedAt, equals(DateTime(2024, 1, 15)));
    });

    test('toLiftEntry returns null when form is incomplete', () {
      const userId = 'test-user-id';
      notifier.setLiftType(LiftType.squat);
      // Missing reps, weight, and date

      final liftEntry = notifier.toLiftEntry(userId);

      expect(liftEntry, isNull);
    });
  });
}
