import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';
import 'package:cc_workout_app/shared/forms/lift_form_state.dart';
import 'package:cc_workout_app/shared/forms/lift_form_mixin.dart';

class AddLiftFormNotifier extends AutoDisposeNotifier<LiftFormState>
    with LiftFormMixin {
  @override
  LiftFormState build() {
    return LiftFormState.forAdding();
  }

  void clearForm() {
    state = LiftFormState.forAdding();
  }

  LiftEntry? toLiftEntry(String userId) {
    return state.toNewLiftEntry(userId);
  }
}

final addLiftFormProvider =
    AutoDisposeNotifierProvider<AddLiftFormNotifier, LiftFormState>(() {
      return AddLiftFormNotifier();
    });
