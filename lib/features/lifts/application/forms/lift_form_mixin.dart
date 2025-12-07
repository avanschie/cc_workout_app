import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/lifts/application/forms/lift_form_state.dart';
import 'package:cc_workout_app/features/lifts/application/forms/lift_form_validator.dart';

/// Mixin that provides common form state management methods
mixin LiftFormMixin on Notifier<LiftFormState> {
  void setLiftType(LiftType? liftType) {
    final error = LiftFormValidator.validateLiftType(liftType);
    state = state.copyWith(liftType: liftType, liftTypeError: error);
  }

  void setReps(String repsText) {
    final validation = LiftFormValidator.validateRepsText(repsText);
    state = state.copyWith(reps: validation.reps, repsError: validation.error);
  }

  void setWeight(String weightText) {
    final validation = LiftFormValidator.validateWeightText(weightText);
    state = state.copyWith(
      weightKg: validation.weight,
      weightError: validation.error,
    );
  }

  void setPerformedAt(DateTime? date) {
    final error = LiftFormValidator.validateDate(date);
    state = state.copyWith(performedAt: date, dateError: error);
  }

  void validateAll() {
    var newState = state;

    if (state.liftType == null) {
      newState = newState.copyWith(liftTypeError: 'Lift type is required');
    }
    if (state.reps == null) {
      newState = newState.copyWith(repsError: 'Reps is required');
    }
    if (state.weightKg == null) {
      newState = newState.copyWith(weightError: 'Weight is required');
    }
    if (state.performedAt == null) {
      newState = newState.copyWith(dateError: 'Date is required');
    }

    state = newState;
  }

  /// Methods specific to edit forms (optional to implement)
  void showDeleteConfirmation() {
    state = state.copyWith(showDeleteConfirmation: true);
  }

  void hideDeleteConfirmation() {
    state = state.copyWith(showDeleteConfirmation: false);
  }
}
