import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/features/lifts/domain/services/lift_management_service.dart';
import 'package:cc_workout_app/features/lifts/application/providers/lift_entries_providers.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/lifts/domain/entities/lift_entry.dart';

/// Provider for the lift management service
final liftManagementServiceProvider = Provider<LiftManagementService>((ref) {
  return LiftManagementService();
});

/// Provider for workout suggestions based on recent training history
final workoutSuggestionsProvider = FutureProvider<List<WorkoutSuggestion>>((
  ref,
) async {
  final service = ref.read(liftManagementServiceProvider);
  final entries = await ref.watch(liftEntriesProvider.future);

  return service.generateWorkoutSuggestions(entries);
});

/// Provider for progress analysis across all lift types
final progressAnalysisProvider =
    FutureProvider<Map<LiftType, ProgressAnalysis>>((ref) async {
      final service = ref.read(liftManagementServiceProvider);
      final entries = await ref.watch(liftEntriesProvider.future);

      return service.analyzeProgress(entries);
    });

/// Provider for total training volume over the last 30 days
final recentTrainingVolumeProvider = FutureProvider<double>((ref) async {
  final service = ref.read(liftManagementServiceProvider);
  final entries = await ref.watch(liftEntriesProvider.future);

  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  final recentEntries = service.filterByDateRange(
    entries,
    thirtyDaysAgo,
    DateTime.now(),
  );

  return service.calculateTotalVolume(recentEntries);
});

/// Provider for workout frequency over the last 8 weeks
final workoutFrequencyProvider = FutureProvider<double>((ref) async {
  final service = ref.read(liftManagementServiceProvider);
  final entries = await ref.watch(liftEntriesProvider.future);

  final eightWeeksAgo = DateTime.now().subtract(const Duration(days: 56));

  return service.calculateWorkoutFrequency(
    entries,
    eightWeeksAgo,
    DateTime.now(),
  );
});

/// Provider for heaviest lifts per type
final heaviestLiftsProvider = FutureProvider<Map<LiftType, LiftEntry>>((
  ref,
) async {
  final service = ref.read(liftManagementServiceProvider);
  final entries = await ref.watch(liftEntriesProvider.future);

  return service.getHeaviestLiftPerType(entries);
});

/// Provider for most recent lifts per type
final mostRecentLiftsProvider = FutureProvider<Map<LiftType, LiftEntry>>((
  ref,
) async {
  final service = ref.read(liftManagementServiceProvider);
  final entries = await ref.watch(liftEntriesProvider.future);

  return service.getMostRecentEntryPerLift(entries);
});

/// Family provider for average weight by lift type
final averageWeightProvider = FutureProvider.family<double, LiftType>((
  ref,
  liftType,
) async {
  final service = ref.read(liftManagementServiceProvider);
  final entries = await ref.watch(liftEntriesProvider.future);

  return service.calculateAverageWeight(entries, liftType);
});

/// Family provider for filtered lift entries by date range
final liftEntriesInDateRangeProvider =
    FutureProvider.family<List<LiftEntry>, DateRange>((ref, dateRange) async {
      final service = ref.read(liftManagementServiceProvider);
      final entries = await ref.watch(liftEntriesProvider.future);

      return service.filterByDateRange(entries, dateRange.start, dateRange.end);
    });

/// Data class for date range filtering
class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
