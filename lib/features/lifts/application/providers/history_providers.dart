import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/features/lifts/domain/entities/lift_entry.dart';
import 'package:cc_workout_app/features/lifts/application/providers/lift_entries_providers.dart';
import 'package:cc_workout_app/features/rep_maxes/application/providers/rep_max_providers.dart';
import 'package:cc_workout_app/features/lifts/application/forms/lift_form_state.dart';
import 'package:cc_workout_app/features/lifts/application/forms/lift_form_mixin.dart';

/// Provider for tracking the current navigation tab index
/// 0 = Rep Maxes, 1 = History
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for tracking the lift entry being edited
final selectedLiftEntryProvider = StateProvider<LiftEntry?>((ref) => null);

/// Notifier for edit lift form state management
class EditLiftFormNotifier extends AutoDisposeNotifier<LiftFormState>
    with LiftFormMixin {
  @override
  LiftFormState build() {
    // Initialize with selected lift entry if available
    final selectedEntry = ref.watch(selectedLiftEntryProvider);
    if (selectedEntry != null) {
      return LiftFormState.fromLiftEntry(selectedEntry);
    }
    return const LiftFormState.empty();
  }

  void initializeWithEntry(LiftEntry entry) {
    state = LiftFormState.fromLiftEntry(entry);
  }

  void clearForm() {
    state = const LiftFormState.empty();
  }

  LiftEntry? toLiftEntry(String entryId, String userId) {
    return state.toUpdatedLiftEntry(entryId, userId);
  }
}

final editLiftFormProvider =
    AutoDisposeNotifierProvider<EditLiftFormNotifier, LiftFormState>(() {
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
  HistoryController(this.ref);

  final Ref ref;

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
    final formNotifier = ref.read(editLiftFormProvider.notifier);
    final selectedEntry = ref.read(selectedLiftEntryProvider);

    if (selectedEntry == null || !formState.isValid) {
      throw Exception('Invalid form state or no entry selected');
    }

    final updatedEntry = formNotifier.toLiftEntry(
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
