import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/lifts/providers/lift_entries_providers.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';
import 'package:cc_workout_app/core/constants/validation.dart';

/// Provider for tracking the current navigation tab index
/// 0 = Rep Maxes, 1 = History
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for tracking the lift entry being edited
final selectedLiftEntryProvider = StateProvider<LiftEntry?>((ref) => null);

/// Form state for editing lift entries
class EditLiftFormState {
  final LiftType? liftType;
  final int? reps;
  final double? weightKg;
  final DateTime? performedAt;
  final String? liftTypeError;
  final String? repsError;
  final String? weightError;
  final String? dateError;
  final bool showDeleteConfirmation;

  const EditLiftFormState({
    this.liftType,
    this.reps,
    this.weightKg,
    this.performedAt,
    this.liftTypeError,
    this.repsError,
    this.weightError,
    this.dateError,
    this.showDeleteConfirmation = false,
  });

  EditLiftFormState copyWith({
    LiftType? liftType,
    int? reps,
    double? weightKg,
    DateTime? performedAt,
    Object? liftTypeError = _undefined,
    Object? repsError = _undefined,
    Object? weightError = _undefined,
    Object? dateError = _undefined,
    bool? showDeleteConfirmation,
  }) {
    return EditLiftFormState(
      liftType: liftType ?? this.liftType,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      performedAt: performedAt ?? this.performedAt,
      liftTypeError: liftTypeError == _undefined
          ? this.liftTypeError
          : liftTypeError as String?,
      repsError: repsError == _undefined
          ? this.repsError
          : repsError as String?,
      weightError: weightError == _undefined
          ? this.weightError
          : weightError as String?,
      dateError: dateError == _undefined
          ? this.dateError
          : dateError as String?,
      showDeleteConfirmation:
          showDeleteConfirmation ?? this.showDeleteConfirmation,
    );
  }

  bool get isValid {
    return liftType != null &&
        reps != null &&
        weightKg != null &&
        performedAt != null &&
        liftTypeError == null &&
        repsError == null &&
        weightError == null &&
        dateError == null;
  }

  LiftEntry? toLiftEntry(String entryId, String userId) {
    if (!isValid) return null;

    return LiftEntry(
      id: entryId,
      userId: userId,
      lift: liftType!,
      reps: reps!,
      weightKg: weightKg!,
      performedAt: performedAt!,
      createdAt: DateTime.now(),
    );
  }

  factory EditLiftFormState.fromLiftEntry(LiftEntry entry) {
    return EditLiftFormState(
      liftType: entry.lift,
      reps: entry.reps,
      weightKg: entry.weightKg,
      performedAt: entry.performedAt,
    );
  }
}

const _undefined = Object();

/// Notifier for edit lift form state management
class EditLiftFormNotifier extends AutoDisposeNotifier<EditLiftFormState> {
  @override
  EditLiftFormState build() {
    // Initialize with selected lift entry if available
    final selectedEntry = ref.watch(selectedLiftEntryProvider);
    if (selectedEntry != null) {
      return EditLiftFormState.fromLiftEntry(selectedEntry);
    }
    return const EditLiftFormState();
  }

  void initializeWithEntry(LiftEntry entry) {
    state = EditLiftFormState.fromLiftEntry(entry);
  }

  void setLiftType(LiftType? liftType) {
    state = state.copyWith(
      liftType: liftType,
      liftTypeError: liftType == null ? 'Lift type is required' : null,
    );
  }

  void setReps(String repsText) {
    if (repsText.isEmpty) {
      state = state.copyWith(reps: null, repsError: 'Reps is required');
      return;
    }

    final cleanText = repsText.trim();
    if (cleanText.isEmpty) {
      state = state.copyWith(reps: null, repsError: 'Reps is required');
      return;
    }

    final reps = int.tryParse(cleanText);
    if (reps == null) {
      state = state.copyWith(
        reps: null,
        repsError: 'Please enter a valid whole number',
      );
      return;
    }

    String? error;
    if (reps < ValidationConstants.minReps) {
      error = 'Minimum ${ValidationConstants.minReps} rep required';
    } else if (reps > ValidationConstants.maxReps) {
      error = 'Maximum ${ValidationConstants.maxReps} reps allowed';
    }

    state = state.copyWith(reps: reps, repsError: error);
  }

  void setWeight(String weightText) {
    if (weightText.isEmpty) {
      state = state.copyWith(weightKg: null, weightError: 'Weight is required');
      return;
    }

    final cleanText = weightText.trim().replaceAll(',', '.');
    if (cleanText.isEmpty) {
      state = state.copyWith(weightKg: null, weightError: 'Weight is required');
      return;
    }

    final weight = double.tryParse(cleanText);
    if (weight == null) {
      state = state.copyWith(
        weightKg: null,
        weightError: 'Please enter a valid number (e.g., 100 or 100.5)',
      );
      return;
    }

    String? error;
    if (weight <= ValidationConstants.minWeight) {
      error = 'Weight must be greater than ${ValidationConstants.minWeight} kg';
    } else if (weight > ValidationConstants.maxWeight) {
      error = 'Weight cannot exceed ${ValidationConstants.maxWeight} kg';
    } else if (weight.toString().split('.').length > 1 &&
        weight.toString().split('.')[1].length > 2) {
      error = 'Weight can have at most 2 decimal places';
    }

    state = state.copyWith(weightKg: weight, weightError: error);
  }

  void setPerformedAt(DateTime? date) {
    if (date == null) {
      state = state.copyWith(
        performedAt: null,
        dateError: ValidationConstants.dateRequiredError,
      );
      return;
    }

    String? error;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final performedDate = DateTime(date.year, date.month, date.day);

    if (performedDate.isAfter(today)) {
      error = 'Date cannot be in the future';
    }

    state = state.copyWith(performedAt: date, dateError: error);
  }

  void showDeleteConfirmation() {
    state = state.copyWith(showDeleteConfirmation: true);
  }

  void hideDeleteConfirmation() {
    state = state.copyWith(showDeleteConfirmation: false);
  }

  void clearForm() {
    state = const EditLiftFormState();
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
      newState = newState.copyWith(
        dateError: ValidationConstants.dateRequiredError,
      );
    }

    state = newState;
  }
}

final editLiftFormProvider =
    AutoDisposeNotifierProvider<EditLiftFormNotifier, EditLiftFormState>(() {
      return EditLiftFormNotifier();
    });

/// AsyncNotifier for managing the history list with chronological sorting
class HistoryListNotifier extends AutoDisposeAsyncNotifier<List<LiftEntry>> {
  @override
  Future<List<LiftEntry>> build() async {
    final repository = ref.watch(liftEntriesRepositoryProvider);
    final entries = await repository.getAllLiftEntries();

    // Sort chronologically (newest first)
    entries.sort((a, b) => b.performedAt.compareTo(a.performedAt));
    return entries;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(liftEntriesRepositoryProvider);
      final entries = await repository.getAllLiftEntries();

      // Sort chronologically (newest first)
      entries.sort((a, b) => b.performedAt.compareTo(a.performedAt));
      return entries;
    });
  }

  Future<void> deleteEntry(LiftEntry entry) async {
    final currentEntries = state.valueOrNull ?? [];

    // Optimistic update - remove entry immediately
    final optimisticEntries = currentEntries
        .where((e) => e.id != entry.id)
        .toList();
    state = AsyncValue.data(optimisticEntries);

    try {
      final repository = ref.read(liftEntriesRepositoryProvider);
      await repository.deleteLiftEntry(entry.id);

      // Invalidate related providers after successful delete
      _invalidateRelatedProviders();
    } catch (error, stackTrace) {
      // Rollback on error - restore the original state
      state = AsyncValue.data(currentEntries);
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void _invalidateRelatedProviders() {
    ref.invalidate(liftEntriesProvider);
    ref.invalidate(liftEntriesByTypeProvider);
    // Invalidate rep maxes since they depend on lift entries
    ref.invalidate(allRepMaxesProvider);
    ref.invalidate(repMaxesByLiftProvider);
    ref.invalidate(fullRepMaxTableProvider);
    ref.invalidate(repMaxNotifierProvider);
    ref.invalidate(repMaxTableNotifierProvider);
  }
}

final historyListProvider =
    AutoDisposeAsyncNotifierProvider<HistoryListNotifier, List<LiftEntry>>(() {
      return HistoryListNotifier();
    });

/// Controller for orchestrating history operations
class HistoryController {
  final Ref ref;

  HistoryController(this.ref);

  /// Initialize edit flow with a lift entry
  void startEdit(LiftEntry entry) {
    ref.read(selectedLiftEntryProvider.notifier).state = entry;
    ref.read(editLiftFormProvider.notifier).initializeWithEntry(entry);
  }

  /// Cancel edit flow
  void cancelEdit() {
    ref.read(selectedLiftEntryProvider.notifier).state = null;
    ref.read(editLiftFormProvider.notifier).clearForm();
  }

  /// Save the edited lift entry
  Future<void> saveEdit() async {
    final formState = ref.read(editLiftFormProvider);
    final selectedEntry = ref.read(selectedLiftEntryProvider);

    if (selectedEntry == null || !formState.isValid) {
      throw Exception('Invalid form state or no entry selected');
    }

    final updatedEntry = formState.toLiftEntry(
      selectedEntry.id,
      selectedEntry.userId,
    );
    if (updatedEntry == null) {
      throw Exception('Failed to create updated entry');
    }

    final updateNotifier = ref.read(updateLiftEntryProvider.notifier);
    await updateNotifier.updateLiftEntry(updatedEntry);

    // Refresh history list after update
    ref.read(historyListProvider.notifier).refresh();

    // Clear edit state
    cancelEdit();
  }

  /// Delete a lift entry with confirmation
  Future<void> deleteEntry(LiftEntry entry) async {
    final historyNotifier = ref.read(historyListProvider.notifier);
    await historyNotifier.deleteEntry(entry);

    // Clear edit state if this entry was being edited
    final selectedEntry = ref.read(selectedLiftEntryProvider);
    if (selectedEntry?.id == entry.id) {
      cancelEdit();
    }
  }

  /// Show delete confirmation dialog
  void showDeleteConfirmation() {
    ref.read(editLiftFormProvider.notifier).showDeleteConfirmation();
  }

  /// Hide delete confirmation dialog
  void hideDeleteConfirmation() {
    ref.read(editLiftFormProvider.notifier).hideDeleteConfirmation();
  }

  /// Switch to history tab
  void navigateToHistory() {
    ref.read(navigationIndexProvider.notifier).state = 1;
  }

  /// Switch to rep maxes tab
  void navigateToRepMaxes() {
    ref.read(navigationIndexProvider.notifier).state = 0;
  }
}

final historyControllerProvider = Provider<HistoryController>((ref) {
  return HistoryController(ref);
});
