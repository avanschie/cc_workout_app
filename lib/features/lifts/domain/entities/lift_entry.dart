import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/core/constants/validation.dart';

part 'lift_entry.freezed.dart';
part 'lift_entry.g.dart';

@freezed
sealed class LiftEntry with _$LiftEntry {
  const factory LiftEntry({
    required String id,
    required String userId,
    required LiftType lift,
    required int reps,
    required double weightKg,
    required DateTime performedAt,
    required DateTime createdAt,
  }) = _LiftEntry;

  const LiftEntry._();

  factory LiftEntry.fromJson(Map<String, dynamic> json) =>
      _$LiftEntryFromJson(json);

  factory LiftEntry.fromSupabaseRow(Map<String, dynamic> row) {
    return LiftEntry(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      lift: LiftType.fromString(row['lift'] as String),
      reps: row['reps'] as int,
      weightKg: (row['weight_kg'] as num).toDouble(),
      performedAt: DateTime.parse(row['performed_at'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabaseRow() {
    final row = <String, dynamic>{
      'user_id': userId,
      'lift': lift.value,
      'reps': reps,
      'weight_kg': weightKg,
      'performed_at': performedAt.toIso8601String().split('T')[0], // Date only
    };

    // Only include ID if it's not empty (for updates)
    if (id.isNotEmpty) {
      row['id'] = id;
    }

    // Only include created_at if it's not the default
    if (createdAt != DateTime.fromMillisecondsSinceEpoch(0)) {
      row['created_at'] = createdAt.toIso8601String();
    }

    return row;
  }

  bool get isValid {
    return _validateReps() == null &&
        _validateWeight() == null &&
        _validateDate() == null;
  }

  String? _validateReps() {
    if (reps < ValidationConstants.minReps ||
        reps > ValidationConstants.maxReps) {
      return ValidationConstants.repsRangeError;
    }
    return null;
  }

  String? _validateWeight() {
    if (weightKg <= ValidationConstants.minWeight) {
      return ValidationConstants.weightRangeError;
    }
    if (weightKg > ValidationConstants.maxWeight) {
      return ValidationConstants.weightMaxError;
    }
    return null;
  }

  String? _validateDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final performedDate = DateTime(
      performedAt.year,
      performedAt.month,
      performedAt.day,
    );

    if (performedDate.isAfter(today)) {
      return 'Date cannot be in the future';
    }
    return null;
  }

  String? validateReps() => _validateReps();
  String? validateWeight() => _validateWeight();
  String? validateDate() => _validateDate();
}
