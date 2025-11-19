import 'package:cc_workout_app/features/lifts/domain/entities/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/core/constants/validation.dart';

/// Service class that encapsulates business logic for lift management
///
/// This service provides high-level operations for managing lift entries,
/// including validation, filtering, sorting, and analysis operations.
/// It separates business logic from UI components and data access layers.
class LiftManagementService {
  /// Validates a lift entry according to business rules
  ///
  /// Returns a map of field names to error messages, or empty map if valid
  Map<String, String> validateLiftEntry(LiftEntry entry) {
    final errors = <String, String>{};

    // Validate reps
    if (entry.reps < ValidationConstants.minReps ||
        entry.reps > ValidationConstants.maxReps) {
      errors['reps'] = ValidationConstants.repsRangeError;
    }

    // Validate weight
    if (entry.weightKg <= ValidationConstants.minWeight) {
      errors['weight'] = ValidationConstants.weightRangeError;
    }
    if (entry.weightKg > ValidationConstants.maxWeight) {
      errors['weight'] = ValidationConstants.weightMaxError;
    }

    // Validate date (cannot be in the future)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final performedDate = DateTime(
      entry.performedAt.year,
      entry.performedAt.month,
      entry.performedAt.day,
    );

    if (performedDate.isAfter(today)) {
      errors['date'] = 'Date cannot be in the future';
    }

    return errors;
  }

  /// Checks if a lift entry is valid
  bool isValidLiftEntry(LiftEntry entry) {
    return validateLiftEntry(entry).isEmpty;
  }

  /// Filters lift entries by lift type
  List<LiftEntry> filterByLiftType(List<LiftEntry> entries, LiftType liftType) {
    return entries.where((entry) => entry.lift == liftType).toList();
  }

  /// Filters lift entries by date range
  List<LiftEntry> filterByDateRange(
    List<LiftEntry> entries,
    DateTime startDate,
    DateTime endDate,
  ) {
    return entries.where((entry) {
      final entryDate = DateTime(
        entry.performedAt.year,
        entry.performedAt.month,
        entry.performedAt.day,
      );
      return entryDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             entryDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Filters lift entries by rep range
  List<LiftEntry> filterByRepRange(
    List<LiftEntry> entries,
    int minReps,
    int maxReps,
  ) {
    return entries.where((entry) {
      return entry.reps >= minReps && entry.reps <= maxReps;
    }).toList();
  }

  /// Sorts lift entries by date (newest first by default)
  List<LiftEntry> sortByDate(List<LiftEntry> entries, {bool ascending = false}) {
    final sorted = List<LiftEntry>.from(entries);
    sorted.sort((a, b) {
      final comparison = a.performedAt.compareTo(b.performedAt);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Sorts lift entries by weight (heaviest first by default)
  List<LiftEntry> sortByWeight(List<LiftEntry> entries, {bool ascending = false}) {
    final sorted = List<LiftEntry>.from(entries);
    sorted.sort((a, b) {
      final comparison = a.weightKg.compareTo(b.weightKg);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Gets the most recent entry for each lift type
  Map<LiftType, LiftEntry> getMostRecentEntryPerLift(List<LiftEntry> entries) {
    final result = <LiftType, LiftEntry>{};

    for (final entry in entries) {
      final existing = result[entry.lift];
      if (existing == null || entry.performedAt.isAfter(existing.performedAt)) {
        result[entry.lift] = entry;
      }
    }

    return result;
  }

  /// Gets the heaviest lift for each lift type
  Map<LiftType, LiftEntry> getHeaviestLiftPerType(List<LiftEntry> entries) {
    final result = <LiftType, LiftEntry>{};

    for (final entry in entries) {
      final existing = result[entry.lift];
      if (existing == null || entry.weightKg > existing.weightKg) {
        result[entry.lift] = entry;
      }
    }

    return result;
  }

  /// Calculates total volume (weight x reps) for a list of entries
  double calculateTotalVolume(List<LiftEntry> entries) {
    return entries.fold<double>(
      0.0,
      (total, entry) => total + (entry.weightKg * entry.reps),
    );
  }

  /// Calculates average weight for a specific lift type
  double calculateAverageWeight(List<LiftEntry> entries, LiftType liftType) {
    final filteredEntries = filterByLiftType(entries, liftType);
    if (filteredEntries.isEmpty) {
      return 0.0;
    }

    final totalWeight = filteredEntries.fold<double>(
      0.0,
      (total, entry) => total + entry.weightKg,
    );

    return totalWeight / filteredEntries.length;
  }

  /// Gets workout frequency (entries per week) over a date range
  double calculateWorkoutFrequency(
    List<LiftEntry> entries,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filteredEntries = filterByDateRange(entries, startDate, endDate);
    final totalDays = endDate.difference(startDate).inDays + 1;
    final totalWeeks = totalDays / 7.0;

    if (totalWeeks <= 0) {
      return 0.0;
    }

    // Count unique workout days
    final workoutDays = <String>{};
    for (final entry in filteredEntries) {
      final dateKey = '${entry.performedAt.year}-${entry.performedAt.month}-${entry.performedAt.day}';
      workoutDays.add(dateKey);
    }

    return workoutDays.length / totalWeeks;
  }

  /// Analyzes progress by comparing recent performance to older performance
  Map<LiftType, ProgressAnalysis> analyzeProgress(
    List<LiftEntry> entries, {
    int recentDays = 30,
    int comparisonDays = 60,
  }) {
    final now = DateTime.now();
    final recentStartDate = now.subtract(Duration(days: recentDays));
    final comparisonStartDate = now.subtract(Duration(days: comparisonDays));

    final recentEntries = filterByDateRange(entries, recentStartDate, now);
    final comparisonEntries = filterByDateRange(
      entries,
      comparisonStartDate,
      recentStartDate,
    );

    final result = <LiftType, ProgressAnalysis>{};

    for (final liftType in LiftType.values) {
      final recentMax = getHeaviestLiftPerType(
        filterByLiftType(recentEntries, liftType),
      )[liftType];

      final comparisonMax = getHeaviestLiftPerType(
        filterByLiftType(comparisonEntries, liftType),
      )[liftType];

      if (recentMax != null && comparisonMax != null) {
        final weightImprovement = recentMax.weightKg - comparisonMax.weightKg;
        final percentImprovement = (weightImprovement / comparisonMax.weightKg) * 100;

        result[liftType] = ProgressAnalysis(
          liftType: liftType,
          recentMaxWeight: recentMax.weightKg,
          previousMaxWeight: comparisonMax.weightKg,
          weightImprovement: weightImprovement,
          percentImprovement: percentImprovement,
        );
      }
    }

    return result;
  }

  /// Creates a suggested workout based on recent training history
  List<WorkoutSuggestion> generateWorkoutSuggestions(List<LiftEntry> entries) {
    final suggestions = <WorkoutSuggestion>[];
    final recentEntries = filterByDateRange(
      entries,
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now(),
    );

    for (final liftType in LiftType.values) {
      final recentLifts = filterByLiftType(recentEntries, liftType);

      if (recentLifts.isEmpty) {
        // Suggest starting with moderate weight
        suggestions.add(WorkoutSuggestion(
          liftType: liftType,
          suggestedWeight: _getStartingWeight(liftType),
          suggestedReps: 5,
          reason: 'No recent training - start with moderate weight',
        ));
      } else {
        // Suggest progression based on recent performance
        final heaviest = recentLifts.reduce(
          (a, b) => a.weightKg > b.weightKg ? a : b,
        );

        final progressionWeight = heaviest.weightKg * 1.05; // 5% increase
        suggestions.add(WorkoutSuggestion(
          liftType: liftType,
          suggestedWeight: progressionWeight,
          suggestedReps: heaviest.reps,
          reason: '5% progression from recent max: ${heaviest.weightKg}kg',
        ));
      }
    }

    return suggestions;
  }

  /// Gets appropriate starting weight for a lift type
  double _getStartingWeight(LiftType liftType) {
    switch (liftType) {
      case LiftType.squat:
        return 60.0;
      case LiftType.bench:
        return 40.0;
      case LiftType.deadlift:
        return 80.0;
    }
  }
}

/// Data class representing progress analysis for a lift type
class ProgressAnalysis {
  const ProgressAnalysis({
    required this.liftType,
    required this.recentMaxWeight,
    required this.previousMaxWeight,
    required this.weightImprovement,
    required this.percentImprovement,
  });

  final LiftType liftType;
  final double recentMaxWeight;
  final double previousMaxWeight;
  final double weightImprovement;
  final double percentImprovement;

  bool get hasImproved => weightImprovement > 0;
  bool get hasRegressed => weightImprovement < 0;
  bool get isStagnant => weightImprovement == 0;
}

/// Data class representing a workout suggestion
class WorkoutSuggestion {
  const WorkoutSuggestion({
    required this.liftType,
    required this.suggestedWeight,
    required this.suggestedReps,
    required this.reason,
  });

  final LiftType liftType;
  final double suggestedWeight;
  final int suggestedReps;
  final String reason;
}