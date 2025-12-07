// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rep_max.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepMax _$RepMaxFromJson(Map<String, dynamic> json) => _RepMax(
  userId: json['userId'] as String,
  lift: $enumDecode(_$LiftTypeEnumMap, json['lift']),
  reps: (json['reps'] as num).toInt(),
  weightKg: (json['weightKg'] as num).toDouble(),
  lastPerformedAt: DateTime.parse(json['lastPerformedAt'] as String),
);

Map<String, dynamic> _$RepMaxToJson(_RepMax instance) => <String, dynamic>{
  'userId': instance.userId,
  'lift': _$LiftTypeEnumMap[instance.lift]!,
  'reps': instance.reps,
  'weightKg': instance.weightKg,
  'lastPerformedAt': instance.lastPerformedAt.toIso8601String(),
};

const _$LiftTypeEnumMap = {
  LiftType.squat: 'squat',
  LiftType.bench: 'bench',
  LiftType.deadlift: 'deadlift',
};
