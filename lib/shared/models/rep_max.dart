import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

part 'rep_max.freezed.dart';
part 'rep_max.g.dart';

@freezed
class RepMax with _$RepMax {
  const factory RepMax({
    required String userId,
    required LiftType lift,
    required int reps,
    required double weightKg,
    required DateTime lastPerformedAt,
  }) = _RepMax;

  factory RepMax.fromJson(Map<String, dynamic> json) => _$RepMaxFromJson(json);

  factory RepMax.fromSupabaseRow(Map<String, dynamic> row) {
    return RepMax(
      userId: row['user_id'] as String,
      lift: LiftType.fromString(row['lift'] as String),
      reps: row['reps'] as int,
      weightKg: (row['weight_kg'] as num).toDouble(),
      lastPerformedAt: DateTime.parse(row['performed_at'] as String),
    );
  }
}
